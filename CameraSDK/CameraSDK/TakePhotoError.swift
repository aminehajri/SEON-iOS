//
//  TakePhotoError.swift
//  CameraSDK
//
//  Created by Amine Hajri
//


public enum TakePhotoError: Error {
    case cameraNotAvailable
    case permissionDenied
    case imageCaptureFailed
    case imageSavingFailed
    case unknownError
}
