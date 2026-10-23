//
//   MyUser.swift
//  Food Expiry Tracker
//
//  Created by Bhumik Tandon on 3/29/25.
//
import Foundation
import ParseSwift

struct MyUser: ParseUser {
    // MARK: - Required ParseObject Properties
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?

    // MARK: - Required ParseUser Properties
    var username: String?
    var password: String?
    var email: String?
    var emailVerified: Bool?
    var authData: [String: [String: String]?]?

    // MARK: - Custom User Properties
    // Add any custom fields here (e.g., var profileImage: ParseFile?)
}
