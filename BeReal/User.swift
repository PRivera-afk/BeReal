//
//  User.swift
//  BeReal
//
//  Created by Pablo Rivera on 11/23/25.
//

import Foundation
import ParseSwift

struct User: ParseUser {
    // Required by ParseObject protocol
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?
    
    // Required by ParseUser protocol
    var username: String?
    var email: String?
    var emailVerified: Bool?
    var password: String?
    var authData: [String: [String: String]?]?
    
    // Custom properties (add any additional fields you need)
    var displayName: String {
        return username ?? "Unknown"
    }
}
