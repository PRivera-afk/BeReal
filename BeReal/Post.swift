//
//  Post.swift
//  BeReal
//
//  Created by Pablo Rivera on 11/23/25.
//

import Foundation
import ParseSwift

struct Post: ParseObject {
    // Required by ParseObject protocol
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?
    
    // Custom properties
    var caption: String?
    var user: User?  // Changed from Pointer<User>? to User? for easier access
    var imageFile: ParseFile?
    var location: ParseGeoPoint?
    
    // Helper to format time since post
    var timeAgoDisplay: String {
        guard let createdAt = createdAt else { return "" }
        
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.hour, .minute, .day], from: createdAt, to: now)
        
        if let days = components.day, days > 0 {
            return "\(days)d ago"
        } else if let hours = components.hour, hours > 0 {
            return "\(hours)hr late"
        } else if let minutes = components.minute, minutes > 0 {
            return "\(minutes)min late"
        } else {
            return "Just now"
        }
    }
}
