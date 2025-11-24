//
//  ParseConfiguration.swift
//  BeReal
//
//  Created by Pablo Rivera on 11/23/25.
//

import Foundation

/// Configuration for Parse SDK
/// Replace these values with your Back4App credentials
struct ParseConfiguration {
    
    // MARK: - Back4App Credentials
    // Get these from: https://dashboard.back4app.com → App Settings → Security & Keys
    
    static let applicationId = "DVU98k2Oni6KikCOzRLiXNPeDbrJE5meQHCNXc0Q"
    static let clientKey = "Jrd7kgO0NX0UCnCGKiRQtKFz8B53WK15FgWrh7k8"
    static let serverURL = "https://parseapi.back4app.com"
    
    // MARK: - Validation
    
    static var isConfigured: Bool {
        return applicationId != "YOUR_APP_ID_HERE" && clientKey != "YOUR_CLIENT_KEY_HERE"
    }
    
    static func validate() {
        if !isConfigured {
            fatalError("""
                ⚠️ Parse is not configured!
                
                Please update ParseConfiguration.swift with your Back4App credentials:
                1. Go to https://dashboard.back4app.com
                2. Select your app
                3. Go to App Settings → Security & Keys
                4. Copy your Application ID and Client Key
                5. Update ParseConfiguration.swift
                """)
        }
    }
}
