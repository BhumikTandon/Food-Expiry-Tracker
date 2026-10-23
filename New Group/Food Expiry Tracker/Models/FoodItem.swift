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

    // MARK: - Expiry Status Helpers
    var daysUntilExpiry: Int {
        guard let expiryDate = expiryDate else { return 0 }
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let startOfExpiry = calendar.startOfDay(for: expiryDate)
        return calendar.dateComponents([.day], from: startOfToday, to: startOfExpiry).day ?? 0
    }

    var statusColorName: String {
        let days = daysUntilExpiry
        if days < 0 { return "red" }
        if days <= 3 { return "orange" }
        return "green"
    }

    var statusText: String {
        let days = daysUntilExpiry
        if days < 0 { return "Expired (\(abs(days))d ago)" }
        if days == 0 { return "Expires Today" }
        if days == 1 { return "Expires Tomorrow" }
        return "\(days) Days Left"
    }
}
