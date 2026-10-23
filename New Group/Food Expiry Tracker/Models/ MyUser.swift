//
//   MyUser.swift
//  Food Expiry Tracker
//
//  Created by Bhumik Tandon on 3/29/25.
//

import Foundation
import ParseSwift

struct MyUser: ParseUser {
    // Required ParseUser fields
    var originalData: Data?
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    
    var username: String?
    var email: String?
    var password: String?  // You might not need this since Parse handles password management internally

    // Custom fields
    var fullName: String? // Add custom fields as needed
    var favoriteColor: String?

    // A simple init if you need it
    init() { }
}
