//
//  FoodExpiryTrackerTests.swift
//  
//
//  Created by Ishanshika Arora on 10/22/26.
//

import XCTest
@testable import Food_Expiry_Tracker

final class FoodExpiryTrackerTests: XCTestCase {

    func testExpiryDateCalculation() {
        let calendar = Calendar.current
        let today = Date()
        
        guard let futureDate = calendar.date(byAdding: .day, value: 5, to: today),
              let pastDate = calendar.date(byAdding: .day, value: -2, to: today) else {
            XCTFail("Failed to calculate test dates")
            return
        }
        
        var freshItem = FoodItem()
        freshItem.name = "Fresh Milk"
        freshItem.expiryDate = futureDate
        
        var expiredItem = FoodItem()
        expiredItem.name = "Expired Yogurt"
        expiredItem.expiryDate = pastDate
        
        XCTAssertGreaterThan(freshItem.expiryDate!, today, "Fresh item should expire in the future")
        XCTAssertLessThan(expiredItem.expiryDate!, today, "Expired item date should be in the past")
    }

    func testFoodItemDefaultQuantity() {
        let item = FoodItem()
        XCTAssertEqual(item.quantity, 1, "Default food item quantity should be 1")
    }
}
