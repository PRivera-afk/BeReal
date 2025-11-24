//
//  PostCell.swift
//  BeReal
//
//  Created by Pablo Rivera on 11/23/25.
//

import UIKit
import ParseSwift

class PostCell: UITableViewCell {
    
    static let identifier = "PostCell"
    
    // MARK: - UI Components
    
    private let userInitialsView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.5, alpha: 1.0)
        view.layer.cornerRadius = 25
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let initialsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let locationTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor(white: 0.7, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let captionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .black
        selectionStyle = .none
        
        contentView.addSubview(userInitialsView)
        userInitialsView.addSubview(initialsLabel)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(locationTimeLabel)
        contentView.addSubview(postImageView)
        contentView.addSubview(captionLabel)
        postImageView.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            // User Initials View
            userInitialsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            userInitialsView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            userInitialsView.widthAnchor.constraint(equalToConstant: 50),
            userInitialsView.heightAnchor.constraint(equalToConstant: 50),
            
            // Initials Label
            initialsLabel.centerXAnchor.constraint(equalTo: userInitialsView.centerXAnchor),
            initialsLabel.centerYAnchor.constraint(equalTo: userInitialsView.centerYAnchor),
            
            // Username Label
            usernameLabel.leadingAnchor.constraint(equalTo: userInitialsView.trailingAnchor, constant: 12),
            usernameLabel.topAnchor.constraint(equalTo: userInitialsView.topAnchor, constant: 2),
            usernameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            
            // Location/Time Label
            locationTimeLabel.leadingAnchor.constraint(equalTo: usernameLabel.leadingAnchor),
            locationTimeLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 4),
            locationTimeLabel.trailingAnchor.constraint(equalTo: usernameLabel.trailingAnchor),
            
            // Post Image View
            postImageView.topAnchor.constraint(equalTo: userInitialsView.bottomAnchor, constant: 12),
            postImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            postImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            postImageView.heightAnchor.constraint(equalTo: postImageView.widthAnchor, multiplier: 1.0),
            
            // Activity Indicator
            activityIndicator.centerXAnchor.constraint(equalTo: postImageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: postImageView.centerYAnchor),
            
            // Caption Label
            captionLabel.topAnchor.constraint(equalTo: postImageView.bottomAnchor, constant: 12),
            captionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            captionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            captionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Configuration
    
    func configure(with post: Post) {
        // Set username
        let username = post.user?.username ?? "Unknown"
        usernameLabel.text = username
        
        // Set initials
        let initials = getInitials(from: username)
        initialsLabel.text = initials
        
        // Set location and time
        var locationTimeText = ""
        if let location = post.location {
            locationTimeText = "San Francisco, SOMA"  // You can enhance this with reverse geocoding
        }
        locationTimeText += locationTimeText.isEmpty ? "" : ", "
        locationTimeText += post.timeAgoDisplay
        locationTimeLabel.text = locationTimeText
        
        // Set caption
        if let caption = post.caption, !caption.isEmpty {
            captionLabel.text = caption
            captionLabel.isHidden = false
        } else {
            captionLabel.isHidden = true
        }
        
        // Load image
        postImageView.image = nil
        activityIndicator.startAnimating()
        
        if let imageFile = post.imageFile {
            loadImage(from: imageFile)
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    private func loadImage(from parseFile: ParseFile) {
        guard let url = parseFile.url else {
            activityIndicator.stopAnimating()
            return
        }
        
        // Download image
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                }
                return
            }
            
            DispatchQueue.main.async {
                self.postImageView.image = image
                self.activityIndicator.stopAnimating()
            }
        }.resume()
    }
    
    private func getInitials(from username: String) -> String {
        let words = username.components(separatedBy: " ")
        if words.count >= 2 {
            let firstInitial = words[0].prefix(1)
            let lastInitial = words[1].prefix(1)
            return "\(firstInitial)\(lastInitial)".uppercased()
        } else {
            return username.prefix(2).uppercased()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        postImageView.image = nil
        captionLabel.text = nil
        usernameLabel.text = nil
        locationTimeLabel.text = nil
        initialsLabel.text = nil
        activityIndicator.stopAnimating()
    }
}
