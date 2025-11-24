//
//  ParseService.swift
//  BeReal
//
//  Created by Pablo Rivera on 11/23/25.
//

import Foundation
import ParseSwift
import UIKit

class ParseService {
    
    static let shared = ParseService()
    
    private init() {}
    
    // MARK: - Authentication
    
    /// Sign up a new user
    func signUp(username: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        var newUser = User()
        newUser.username = username
        newUser.password = password
        
        newUser.signup { result in
            DispatchQueue.main.async {
                completion(result.mapError { $0 as Error })
            }
        }
    }
    
    /// Log in an existing user
    func login(username: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        User.login(username: username, password: password) { result in
            DispatchQueue.main.async {
                completion(result.mapError { $0 as Error })
            }
        }
    }
    
    /// Log out the current user
    func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        User.logout { result in
            DispatchQueue.main.async {
                completion(result.mapError { $0 as Error })
            }
        }
    }
    
    // MARK: - Posts
    
    /// Create and upload a new post
    func createPost(image: UIImage, caption: String?, location: ParseGeoPoint? = nil, completion: @escaping (Result<Post, Error>) -> Void) {
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "ParseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])))
            return
        }
        
        let imageFile = ParseFile(name: "image.jpg", data: imageData)
        
        // Upload the image file first
        imageFile.save { result in
            switch result {
            case .success(let savedFile):
                // Create the post object
                var post = Post()
                post.caption = caption
                post.imageFile = savedFile
                post.user = User.current  // Set the current user directly
                post.location = location
                
                // Save the post
                post.save { result in
                    DispatchQueue.main.async {
                        completion(result.mapError { $0 as Error })
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// Fetch recent posts (limit to most recent 10)
    func fetchRecentPosts(limit: Int = 10, skip: Int = 0, completion: @escaping (Result<[Post], Error>) -> Void) {
        
        let query = Post.query()
            .include("user")
            .order([.descending("createdAt")])
            .limit(limit)
            .skip(skip)
        
        query.find { result in
            DispatchQueue.main.async {
                completion(result.mapError { $0 as Error })
            }
        }
    }
    
    /// Fetch posts for a specific user
    func fetchUserPosts(userId: String, completion: @escaping (Result<[Post], Error>) -> Void) {
        
        let userPointer = Pointer<User>(objectId: userId)
        let query = Post.query()
            .where("user" == userPointer)
            .include("user")
            .order([.descending("createdAt")])
        
        query.find { result in
            DispatchQueue.main.async {
                completion(result.mapError { $0 as Error })
            }
        }
    }
}
