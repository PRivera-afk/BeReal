//
//  FeedViewController.swift
//  BeReal
//
//  Created by Pablo Rivera on 11/23/25.
//

import UIKit
import ParseSwift

class FeedViewController: UIViewController {
    
    // MARK: - Properties
    
    private var posts: [Post] = []
    private var isLoadingMorePosts = false
    
    // MARK: - UI Components
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .black
        table.separatorStyle = .none
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let refreshControl = UIRefreshControl()
    
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let logoLabel: UILabel = {
        let label = UILabel()
        label.text = "BeReal."
        label.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let postPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Post a Photo", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.layer.cornerRadius = 12
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupTableView()
        loadPosts()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .black
        
        view.addSubview(headerView)
        headerView.addSubview(logoLabel)
        headerView.addSubview(postPhotoButton)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            // Header View
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 120),
            
            // Logo Label
            logoLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            logoLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 15),
            
            // Post Photo Button
            postPhotoButton.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            postPhotoButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -15),
            postPhotoButton.widthAnchor.constraint(equalToConstant: 200),
            postPhotoButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Table View
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        postPhotoButton.addTarget(self, action: #selector(handlePostPhoto), for: .touchUpInside)
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = true
        
        // Add logout button to header (top left with icon)
        let logoutButton = UIButton(type: .system)
        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.setTitleColor(.white, for: .normal)
        logoutButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        logoutButton.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([
            logoutButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            logoutButton.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 15)
        ])
        
        // Add friends icon (top left)
        let friendsButton = UIButton(type: .system)
        friendsButton.setImage(UIImage(systemName: "person.2.fill"), for: .normal)
        friendsButton.tintColor = .white
        friendsButton.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(friendsButton)
        
        NSLayoutConstraint.activate([
            friendsButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            friendsButton.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 15)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PostCell.self, forCellReuseIdentifier: PostCell.identifier)
        
        // Pull to refresh
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    // MARK: - Data Loading
    
    private func loadPosts(isRefreshing: Bool = false) {
        let skip = isRefreshing ? 0 : posts.count
        
        ParseService.shared.fetchRecentPosts(limit: 10, skip: skip) { [weak self] result in
            guard let self = self else { return }
            
            self.refreshControl.endRefreshing()
            self.isLoadingMorePosts = false
            
            switch result {
            case .success(let fetchedPosts):
                if isRefreshing {
                    self.posts = fetchedPosts
                } else {
                    self.posts.append(contentsOf: fetchedPosts)
                }
                self.tableView.reloadData()
                
            case .failure(let error):
                self.showAlert(title: "Error", message: "Failed to load posts: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func handleLogout() {
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { [weak self] _ in
            self?.performLogout()
        })
        
        present(alert, animated: true)
    }
    
    private func performLogout() {
        ParseService.shared.logout { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.navigateToAuth()
            case .failure(let error):
                self.showAlert(title: "Error", message: "Failed to logout: \(error.localizedDescription)")
            }
        }
    }
    
    @objc private func handlePostPhoto() {
        let postPhotoVC = PostPhotoViewController()
        postPhotoVC.delegate = self
        let navController = UINavigationController(rootViewController: postPhotoVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    @objc private func handleRefresh() {
        loadPosts(isRefreshing: true)
    }
    
    // MARK: - Helpers
    
    private func navigateToAuth() {
        let authVC = AuthViewController()
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = authVC
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension FeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PostCell.identifier, for: indexPath) as? PostCell else {
            return UITableViewCell()
        }
        
        let post = posts[indexPath.row]
        cell.configure(with: post)
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension FeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 600
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.height
        
        // Load more when scrolled to bottom
        if offsetY > contentHeight - height - 100 {
            if !isLoadingMorePosts && posts.count >= 10 {
                isLoadingMorePosts = true
                loadPosts()
            }
        }
    }
}

// MARK: - PostPhotoDelegate

extension FeedViewController: PostPhotoDelegate {
    func didPostPhoto() {
        // Refresh feed after posting
        handleRefresh()
    }
}
