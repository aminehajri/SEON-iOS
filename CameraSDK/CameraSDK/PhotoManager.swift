//
//  PhotoManager.swift
//  CameraSDK
//
//  Created by Amine Hajri
//

import UIKit
import AVFoundation
import LocalAuthentication

public class PhotoManager: NSObject {
    
    let appFolderName = "Seon"
    let photoExtension = ".jpg"
    
    weak var viewController: UIViewController?
    
    public var takePhotoDelegate: TakePhotoDelegate?
    public var accessPhotosDelegate: AccessPhotosDelegate?
    
    public init(viewController: UIViewController) {
        super.init()
        
        self.viewController = viewController
        createAppDirectory()
    }
    
    public func takePhoto() {
        // Check if the device has a camera
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            takePhotoDelegate?.didFailWithError(error: .cameraNotAvailable)
            return
        }
        
        // Check and request camera permission
        checkCameraPermission { [weak self] granted in
            guard let self = self else { return }
            
            if granted {
                self.showCamera()
            } else {
                self.takePhotoDelegate?.didFailWithError(error: .permissionDenied)
            }
        }
    }
    
    // Access all saved photos from the app directory
    public func accessPhotos() {
        var images: [UIImage] = []
        
        let appDirectory = getAppDirectory()
        
        do {
            // List all images in the app directory
            let fileManager = FileManager.default
            let filePaths = try fileManager.contentsOfDirectory(atPath: appDirectory.path)
            let imagePaths = filePaths.filter { $0.hasSuffix(photoExtension) }
            
            for imagePath in imagePaths {
                let fullPath = appDirectory.appendingPathComponent(imagePath)
                
                // Load the image from the file path
                if let image = loadImageFromDevice(with: fullPath.path) {
                    images.append(image)
                }
            }
            
            // Inform the delegate with the array of loaded images
            accessPhotosDelegate?.didAccessPhotos(images: images)
            
        } catch {
            print("Error accessing saved photos: \(error)")
            accessPhotosDelegate?.didFailWithError(error: .unknownError)
        }
    }
    
    // Authenticate user using biometric authentication
    public func authenticateUser(completion: @escaping (Bool, Error?) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        // Check if the device supports biometric authentication (Face ID or Touch ID)
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate to access your saved photos"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        // Authentication was successful, grant access
                        completion(true, nil)
                    } else {
                        // Authentication failed
                        completion(false, authenticationError)
                    }
                }
            }
        } else {
            // Device does not support biometric authentication
            completion(false, error)
        }
    }
    
    // Check camera permission
    private func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraAuthorizationStatus {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        case .denied, .restricted:
            completion(false)
        default:
            completion(false)
        }
    }
    
    // Show camera to capture photo
    private func showCamera() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        imagePickerController.cameraDevice = .front
        imagePickerController.delegate = self
        viewController?.present(imagePickerController, animated: true)
    }
    
    // Save the captured image on device
    private func saveImage(image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 1.0) else {
            takePhotoDelegate?.didFailWithError(error: .imageSavingFailed)
            return
        }
        
        let appDierctory = getAppDirectory()
        let timestamp = Int(Date().timeIntervalSince1970)
        let imagePath = appDierctory.appendingPathComponent("photo_\(timestamp)\(photoExtension)")
        
        do {
            try data.write(to: imagePath)
            print("Image saved successfully to: \(imagePath)")
        } catch {
            print("Failed to save image: \(error)")
            takePhotoDelegate?.didFailWithError(error: .imageSavingFailed)
        }
    }
    
    // Create the app "Seon" directory if it doesn't exist
    private func createAppDirectory() {
        let fileManager = FileManager.default
        let appDirectory = getDocDirectory().appendingPathComponent(appFolderName)
        
        // Create the directory if it doesn't exist
        if !fileManager.fileExists(atPath: appDirectory.path) {
            do {
                try fileManager.createDirectory(at: appDirectory, withIntermediateDirectories: true, attributes: nil)
                print("Seon directory created.")
            } catch {
                print("Error creating Seon directory: \(error)")
                accessPhotosDelegate?.didFailWithError(error: .photoFolderCreationFailed)
            }
        }
    }
    
    // Get the app "Seon" directory path
    private func getAppDirectory() -> URL {
        return getDocDirectory().appendingPathComponent(appFolderName)
    }
    
    // Get the documents directory path
    private func getDocDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    // Load an image from device using its file path
    private func loadImageFromDevice(with path: String) -> UIImage? {
        let fileURL = URL(fileURLWithPath: path)
        if let imageData = try? Data(contentsOf: fileURL) {
            return UIImage(data: imageData)
        }
        return nil
    }
}

extension PhotoManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        // Get the captured image
        if let capturedImage = info[.originalImage] as? UIImage {
            // Save the captured image
            saveImage(image: capturedImage)
        } else {
            takePhotoDelegate?.didFailWithError(error: .imageCaptureFailed)
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
