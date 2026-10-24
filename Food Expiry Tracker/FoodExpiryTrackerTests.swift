//
//  FoodExpiryTrackerTests.swift
//  Food Expiry Tracker
//
//  This file is compiled into the unit-test target only (the Xcode project excludes it from the app).
//

import XCTest
@testable import Food_Expiry_Tracker

final class FoodItemExpiryTests: XCTestCase {

    // A fixed calendar and "now" keep these tests deterministic in any time zone.
    private let calendar: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "UTC")!
        return c
    }()

    private func date(_ year: Int, _ month: Int, _ day: Int, hour: Int = 12) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }

    /// Saturday, Oct 24 2026, 3 pm UTC
    private var now: Date { date(2026, 10, 24, hour: 15) }

    private func item(_ name: String = "Milk", expires: Date?, id: String? = "abc") -> FoodItem {
        var item = FoodItem()
        item.objectId = id
        item.name = name
        item.expiryDate = expires
        return item
    }

    // MARK: - Days and status

    func testDaysUntilExpiryCountsCalendarDays() {
        XCTAssertEqual(item(expires: date(2026, 10, 29)).daysUntilExpiry(asOf: now, calendar: calendar), 5)
        XCTAssertEqual(item(expires: date(2026, 10, 23)).daysUntilExpiry(asOf: now, calendar: calendar), -1)
    }

    func testSameDayIsZeroRegardlessOfTime() {
        XCTAssertEqual(item(expires: date(2026, 10, 24, hour: 0)).daysUntilExpiry(asOf: now, calendar: calendar), 0)
        XCTAssertEqual(item(expires: date(2026, 10, 24, hour: 23)).daysUntilExpiry(asOf: now, calendar: calendar), 0)
    }

    func testMissingExpiryDateIsNotTreatedAsExpiringToday() {
        let undated = item(expires: nil)
        XCTAssertNil(undated.daysUntilExpiry(asOf: now, calendar: calendar))
        XCTAssertEqual(undated.status(asOf: now, calendar: calendar), .noDate)
    }

    func testStatusBoundaries() {
        XCTAssertEqual(item(expires: date(2026, 10, 23)).status(asOf: now, calendar: calendar), .expired)
        XCTAssertEqual(item(expires: date(2026, 10, 24)).status(asOf: now, calendar: calendar), .expiringSoon)
        XCTAssertEqual(item(expires: date(2026, 10, 27)).status(asOf: now, calendar: calendar), .expiringSoon)
        XCTAssertEqual(item(expires: date(2026, 10, 28)).status(asOf: now, calendar: calendar), .fresh)
    }

    func testNoDateStatusText() {
        XCTAssertEqual(item(expires: nil).statusText, "No expiry date")
    }

    // MARK: - Recipe ingredients

    func testRecipeIngredientsSkipExpiredAndPutSoonestFirst() {
        let items = [
            item("Rice", expires: date(2026, 12, 1), id: "1"),
            item("Spinach", expires: date(2026, 10, 25), id: "2"),
            item("Old Yogurt", expires: date(2026, 10, 20), id: "3"),
            item("Chicken", expires: date(2026, 10, 26), id: "4")
        ]
        let names = FoodItemManager.recipeIngredients(from: items, asOf: now, calendar: calendar)
        XCTAssertEqual(names, ["Spinach", "Chicken", "Rice"])
    }

    func testRecipeIngredientsDeduplicateIgnoreBlanksAndRespectLimit() {
        let items = [
            item("Milk", expires: date(2026, 10, 25), id: "1"),
            item("milk", expires: date(2026, 10, 26), id: "2"),
            item("  ", expires: date(2026, 10, 25), id: "3"),
            item("Eggs", expires: date(2026, 10, 27), id: "4"),
            item("Butter", expires: date(2026, 10, 28), id: "5")
        ]
        let names = FoodItemManager.recipeIngredients(from: items, limit: 2, asOf: now, calendar: calendar)
        XCTAssertEqual(names, ["Milk", "Eggs"])
    }

    func testSpoonacularSanitizingStripsQueryBreakingCharacters() {
        XCTAssertEqual(SpoonacularService.sanitized("Mac & Cheese"), "mac cheese")
        XCTAssertEqual(SpoonacularService.sanitized("  Olive   Oil! "), "olive oil")
    }

    // MARK: - Reminders

    func testItemExpiringInFiveDaysGetsTwoMorningReminders() {
        let reminders = NotificationManager.reminders(for: item(expires: date(2026, 10, 29)), now: now, calendar: calendar)
        XCTAssertEqual(reminders.count, 2)
        XCTAssertEqual(reminders.map(\.identifier), ["expiry-abc-soon", "expiry-abc-today"])
        XCTAssertEqual(calendar.component(.day, from: reminders[0].fireDate), 27)
        XCTAssertEqual(calendar.component(.day, from: reminders[1].fireDate), 29)
        XCTAssertTrue(reminders.allSatisfy { calendar.component(.hour, from: $0.fireDate) == NotificationManager.reminderHour })
    }

    func testItemExpiringTomorrowOnlyGetsTheDayOfReminder() {
        let reminders = NotificationManager.reminders(for: item(expires: date(2026, 10, 25)), now: now, calendar: calendar)
        XCTAssertEqual(reminders.map(\.identifier), ["expiry-abc-today"])
    }

    func testNoRemindersForPastOrIncompleteItems() {
        XCTAssertTrue(NotificationManager.reminders(for: item(expires: date(2026, 10, 20)), now: now, calendar: calendar).isEmpty)
        // Expires today, but 9 am has already passed.
        XCTAssertTrue(NotificationManager.reminders(for: item(expires: date(2026, 10, 24)), now: now, calendar: calendar).isEmpty)
        XCTAssertTrue(NotificationManager.reminders(for: item(expires: date(2026, 10, 29), id: nil), now: now, calendar: calendar).isEmpty)
        XCTAssertTrue(NotificationManager.reminders(for: item(expires: nil), now: now, calendar: calendar).isEmpty)
    }
}
