//
//  AppDelegate.swift
//  BeReal
//
//  Created by Pablo Rivera on 11/23/25.
//

import UIKit
import ParseSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // MARK: - Parse Configuration
        // Validate configuration
        ParseConfiguration.validate()
        
        // Initialize Parse SDK with Back4App credentials
        ParseSwift.initialize(
            applicationId: ParseConfiguration.applicationId,
            clientKey: ParseConfiguration.clientKey,
            serverURL: URL(string: ParseConfiguration.serverURL)!
        )
        
        // Enable automatic user for anonymous sessions (optional)
        // User.current?.fetch { _ in }
        
        // Setup the window and initial view controller
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // Check if user is logged in
        if User.current != nil {
            // User is logged in, show feed
            let feedVC = FeedViewController()
            let navigationController = UINavigationController(rootViewController: feedVC)
            window?.rootViewController = navigationController
        } else {
            // No user logged in, show auth screen
            let authVC = AuthViewController()
            window?.rootViewController = authVC
        }
        
        window?.makeKeyAndVisible()
        
        return true
    }
}
