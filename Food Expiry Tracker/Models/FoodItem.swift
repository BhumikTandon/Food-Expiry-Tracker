//
//  FoodItem.swift
//  Food Expiry Tracker
//

import Foundation
import ParseSwift

// MARK: - Enums
enum FoodUnit: String, CaseIterable, Codable, Identifiable {
    case pcs = "Pcs"
    case oz = "oz"
    case flOz = "fl oz"
    case gal = "gal"
    case liter = "L"
    case ml = "mL"
    case lbs = "lbs"
    case grams = "g"
    case kg = "kg"
    
    var id: String { rawValue }
}

enum FoodCategory: String, CaseIterable, Codable, Identifiable {
    case dairy = "Dairy"
    case produce = "Produce"
    case meat = "Meat & Seafood"
    case bakery = "Bakery"
    case pantry = "Pantry"
    case beverages = "Beverages"
    case frozen = "Frozen"
    case other = "Other"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .dairy: return "drop.fill"
        case .produce: return "leaf.fill"
        case .meat: return "flame.fill"
        case .bakery: return "square.grid.3x3.square"
        case .pantry: return "archivebox.fill"
        case .beverages: return "cup.and.saucer.fill"
        case .frozen: return "snowflake"
        case .other: return "tag.fill"
        }
    }
}

// MARK: - Parse Model
struct FoodItem: ParseObject {
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?

    // Custom Fields
    var name: String?
    var quantity: Double?
    var unit: String?
    var category: String?
    var expiryDate: Date?
    var user: Pointer<MyUser>?
}

// MARK: - Expiry Status

enum ExpiryStatus: Equatable {
    case noDate, expired, expiringSoon, fresh
}

extension FoodItem {
    /// Items with this many days left or fewer (but not yet expired) count as "expiring soon".
    static let expiringSoonThreshold = 3

    /// Whole calendar days from `now` to the expiry date. Negative means already expired.
    /// Returns nil when the item has no expiry date.
    func daysUntilExpiry(asOf now: Date = Date(), calendar: Calendar = .current) -> Int? {
        guard let expiryDate = expiryDate else { return nil }
        let startOfToday = calendar.startOfDay(for: now)
        let startOfExpiry = calendar.startOfDay(for: expiryDate)
        return calendar.dateComponents([.day], from: startOfToday, to: startOfExpiry).day
    }

    func status(asOf now: Date = Date(), calendar: Calendar = .current) -> ExpiryStatus {
        guard let days = daysUntilExpiry(asOf: now, calendar: calendar) else { return .noDate }
        if days < 0 { return .expired }
        if days <= FoodItem.expiringSoonThreshold { return .expiringSoon }
        return .fresh
    }

    var statusColorName: String {
        switch status() {
        case .noDate: return "gray"
        case .expired: return "red"
        case .expiringSoon: return "orange"
        case .fresh: return "green"
        }
    }

    var statusText: String {
        guard let days = daysUntilExpiry() else { return "No expiry date" }
        if days < 0 { return "Expired (\(abs(days))d ago)" }
        if days == 0 { return "Expires Today" }
        if days == 1 { return "Expires Tomorrow" }
        return "\(days) Days Left"
    }
}
