//
//  NotificationManager.swift
//  Food Expiry Tracker
//
//  Local reminders before food expires. Everything runs on the device, no push server needed.
//

import Foundation
import UserNotifications

struct ExpiryReminder: Equatable {
    let identifier: String
    let title: String
    let body: String
    let fireDate: Date
}

final class NotificationManager {
    static let shared = NotificationManager()

    static let identifierPrefix = "expiry-"
    /// Reminders go out at this hour of the morning.
    static let reminderHour = 9
    /// The first reminder arrives this many days before the expiry date.
    static let leadDays = 2
    /// iOS keeps at most 64 pending local notifications, so we schedule the soonest ones.
    static let maxPending = 60

    private let center = UNUserNotificationCenter.current()

    // MARK: - Permission

    @discardableResult
    func requestAuthorization() async -> Bool {
        let granted = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
        return granted ?? false
    }

    // MARK: - Planning (pure, covered by unit tests)

    /// Up to two reminders per item: one `leadDays` before expiry and one on the day itself.
    /// Reminders whose time has already passed are skipped.
    static func reminders(
        for item: FoodItem,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> [ExpiryReminder] {
        guard let id = item.objectId,
              let name = item.name,
              let expiryDate = item.expiryDate else { return [] }

        let expiryDay = calendar.startOfDay(for: expiryDate)
        var reminders: [ExpiryReminder] = []

        if let warningDay = calendar.date(byAdding: .day, value: -leadDays, to: expiryDay),
           let fireDate = calendar.date(bySettingHour: reminderHour, minute: 0, second: 0, of: warningDay),
           fireDate > now {
            reminders.append(ExpiryReminder(
                identifier: "\(identifierPrefix)\(id)-soon",
                title: "\(name) expires in \(leadDays) days",
                body: "Use it soon to avoid waste. Check the Recipes tab for ideas.",
                fireDate: fireDate
            ))
        }

        if let fireDate = calendar.date(bySettingHour: reminderHour, minute: 0, second: 0, of: expiryDay),
           fireDate > now {
            reminders.append(ExpiryReminder(
                identifier: "\(identifierPrefix)\(id)-today",
                title: "\(name) expires today",
                body: "Use it today or toss it.",
                fireDate: fireDate
            ))
        }

        return reminders
    }

    // MARK: - Scheduling

    /// Replaces all pending expiry reminders with ones matching `items`.
    /// Called after every fetch and delete, so edits and deletions never leave stale reminders.
    func sync(_ items: [FoodItem], now: Date = Date(), calendar: Calendar = .current) {
        let wanted = Array(
            items
                .flatMap { NotificationManager.reminders(for: $0, now: now, calendar: calendar) }
                .sorted { $0.fireDate < $1.fireDate }
                .prefix(NotificationManager.maxPending)
        )

        let center = self.center
        center.getPendingNotificationRequests { pending in
            let stale = pending
                .map(\.identifier)
                .filter { $0.hasPrefix(NotificationManager.identifierPrefix) }
            center.removePendingNotificationRequests(withIdentifiers: stale)

            for reminder in wanted {
                let content = UNMutableNotificationContent()
                content.title = reminder.title
                content.body = reminder.body
                content.sound = .default

                let components = calendar.dateComponents(
                    [.year, .month, .day, .hour, .minute],
                    from: reminder.fireDate
                )
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                center.add(UNNotificationRequest(identifier: reminder.identifier, content: content, trigger: trigger))
            }
        }
    }

    func cancelAll() {
        let center = self.center
        center.getPendingNotificationRequests { pending in
            let ids = pending
                .map(\.identifier)
                .filter { $0.hasPrefix(NotificationManager.identifierPrefix) }
            center.removePendingNotificationRequests(withIdentifiers: ids)
        }
    }
}
