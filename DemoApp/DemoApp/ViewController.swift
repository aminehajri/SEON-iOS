//
//  ViewController.swift
//  DemoApp
//
//  Created by Amine Hajri
//

import UIKit
import CameraSDK

class ViewController: UIViewController {
    
    var photoManager: PhotoManager!
    var capturePhotoButton: UIButton!
    var accessPhotosButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoManager = PhotoManager(viewController: self)
        photoManager.takePhotoDelegate = self
        photoManager.accessPhotosDelegate = self
        
        setupLayout()
    }
    
    func setupLayout() {
        // Set up the photo capturing button layout
        capturePhotoButton = UIButton(type: .system)
        capturePhotoButton.setTitle("Take a picture", for: .normal)
        capturePhotoButton.addTarget(self, action: #selector(captureSelfieButtonTapped), for: .touchUpInside)
        capturePhotoButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(capturePhotoButton)
        capturePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        capturePhotoButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30).isActive = true
        capturePhotoButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        capturePhotoButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // Set up the access photo button layout
        accessPhotosButton = UIButton(type: .system)
        accessPhotosButton.setTitle("Access photo gallery", for: .normal)
        accessPhotosButton.addTarget(self, action: #selector(accessSavedPhotos), for: .touchUpInside)
        accessPhotosButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(accessPhotosButton)
        accessPhotosButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        accessPhotosButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 20).isActive = true
        accessPhotosButton.topAnchor.constraint(equalTo: capturePhotoButton.bottomAnchor, constant: 20).isActive = true
        accessPhotosButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        accessPhotosButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    @objc func captureSelfieButtonTapped() {
        photoManager.takePhoto()
    }
    
    @objc func accessSavedPhotos() {
        photoManager.authenticateUser { success, error in
            if success {
                self.photoManager.accessPhotos()
            } else {
                self.showAlert(message: error?.localizedDescription ?? "Error")
            }
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
}

extension ViewController: TakePhotoDelegate {
    func didFailWithError(error: CameraSDK.TakePhotoError) {
        switch error {
        case .cameraNotAvailable:
            showAlert(message: "Camera is not available on this device.")
        case .permissionDenied:
            showAlert(message: "Camera permission was denied.")
        case .imageCaptureFailed:
            showAlert(message: "Failed to capture image. Please try again.")
        case .imageSavingFailed:
            showAlert(message: "Couldn't save image.")
        case .unknownError:
            showAlert(message: "An unknown error occurred.")
        default:
            return
        }
    }
}

extension ViewController: AccessPhotosDelegate {
    func didAccessPhotos(images: [UIImage]) {
        
        // Present the PhotoGalleryViewController
        let photoGalleryView = PhotoGalleryViewContoller()
        photoGalleryView.images = images
        present(photoGalleryView, animated: true, completion: nil)
    }
    
    func didFailWithError(error: CameraSDK.AccessPhotoError) {
        switch error {
        case .photoFolderCreationFailed:
            showAlert(message: "Couldn't create the photo Folder")
        case .unknownError:
            showAlert(message: "Couldn't load images")
        default:
            return
        }
    }
}

