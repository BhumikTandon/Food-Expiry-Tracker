//
//  FoodItem.swift
//  Food Expiry Tracker
//
//  Created by Bhumik Tandon on 3/29/25.
//

import Foundation
import ParseSwift

struct FoodItem: ParseObject, Identifiable {
    // Required ParseObject fields
    var originalData: Data?
    var objectId: String?
    var quantity: Int
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?

    // Custom fields
    var name: String?       // e.g. "Milk"
    var expiryDate: Date?   // Parse can store Date
    var user: MyUser?       // Pointer to the user who owns this item

    // For SwiftUI's Identifiable
    var id: String {
        objectId ?? UUID().uuidString
    }

    init()
}
