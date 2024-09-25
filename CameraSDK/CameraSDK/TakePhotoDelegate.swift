//
//  TakePhotoDelegate.swift
//  CameraSDK
//
//  Created by Amine Hajri
//

import UIKit

public protocol TakePhotoDelegate {
    func didFailWithError(error: TakePhotoError)
}
