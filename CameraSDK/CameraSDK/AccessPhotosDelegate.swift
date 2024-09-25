//
//  AccessPhotosDelegate.swift
//  CameraSDK
//
//  Created by Amine Hajri
//

import UIKit

public protocol AccessPhotosDelegate {
    func didAccessPhotos(images: [UIImage])
    func didFailWithError(error: AccessPhotoError)
}
