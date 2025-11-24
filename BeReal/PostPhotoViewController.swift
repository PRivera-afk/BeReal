//
//  PostPhotoViewController.swift
//  BeReal
//
//  Created by Pablo Rivera on 11/23/25.
//

import UIKit
import PhotosUI
import ParseSwift

protocol PostPhotoDelegate: AnyObject {
    func didPostPhoto()
}

class PostPhotoViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: PostPhotoDelegate?
    private var selectedImage: UIImage?
    private var imageLocation: ParseGeoPoint?
    
    // MARK: - UI Components
    
    private let captionTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Caption"
        textField.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        textField.textColor = .black
        textField.layer.cornerRadius = 8
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let selectPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select Photo", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.8)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .black
        
        view.addSubview(captionTextField)
        view.addSubview(selectPhotoButton)
        view.addSubview(imageView)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            // Caption TextField
            captionTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            captionTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            captionTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            captionTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // Select Photo Button
            selectPhotoButton.topAnchor.constraint(equalTo: captionTextField.bottomAnchor, constant: 20),
            selectPhotoButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            selectPhotoButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            selectPhotoButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Image View
            imageView.topAnchor.constraint(equalTo: selectPhotoButton.bottomAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.0),
            
            // Activity Indicator
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        selectPhotoButton.addTarget(self, action: #selector(handleSelectPhoto), for: .touchUpInside)
        
        // Dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupNavigationBar() {
        title = "Post Photo"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(handleDismiss)
        )
        navigationItem.leftBarButtonItem?.tintColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Post",
            style: .done,
            target: self,
            action: #selector(handlePost)
        )
        navigationItem.rightBarButtonItem?.tintColor = .white
        
        // Style navigation bar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    // MARK: - Actions
    
    @objc private func handleSelectPhoto() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc private func handlePost() {
        guard let image = selectedImage else {
            showAlert(title: "Error", message: "Please select a photo first")
            return
        }
        
        let caption = captionTextField.text
        
        activityIndicator.startAnimating()
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        ParseService.shared.createPost(image: image, caption: caption, location: imageLocation) { [weak self] result in
            guard let self = self else { return }
            
            self.activityIndicator.stopAnimating()
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            
            switch result {
            case .success:
                self.delegate?.didPostPhoto()
                self.dismiss(animated: true)
            case .failure(let error):
                self.showAlert(title: "Error", message: "Failed to post: \(error.localizedDescription)")
            }
        }
    }
    
    @objc private func handleDismiss() {
        dismiss(animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Helpers
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func extractLocationFromImage(_ image: UIImage, asset: PHAsset?) {
        guard let asset = asset else { return }
        
        if let location = asset.location {
            do {
                imageLocation = try ParseGeoPoint(latitude: location.coordinate.latitude,
                                                  longitude: location.coordinate.longitude)
            } catch {
                print("Failed to create ParseGeoPoint: \(error.localizedDescription)")
                imageLocation = nil
            }
        }
    }
}

// MARK: - PHPickerViewControllerDelegate

extension PostPhotoViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let result = results.first else { return }
        
        // Get the asset identifier for location extraction
        if let assetIdentifier = result.assetIdentifier {
            let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil)
            if let asset = fetchResult.firstObject {
                extractLocationFromImage(UIImage(), asset: asset)
            }
        }
        
        // Load the image
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            guard let self = self, let image = object as? UIImage else { return }
            
            DispatchQueue.main.async {
                self.selectedImage = image
                self.imageView.image = image
                self.imageView.isHidden = false
            }
        }
    }
}
