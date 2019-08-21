//
//  PhotoAuthorization.swift
//  LQPhotoManager
//
//  Created by Li on 2019/8/20.
//  Copyright © 2019 . All rights reserved.
//

import Foundation
import Photos
import AVFoundation

public enum PhotoAuthorizationStatus:String{
    case photoNotDetermined = "用户尚未对相册权限做出选择"
    case photoRestricted    = "用户无权访问相册"
    case photoDenied        = "用户拒绝访问相册"
    case photoAuthorized    = "用户允许访问相册"
}

public enum CameraAuthorizationStatus:String{
    case cameraNotDetermined = "用户尚未对相机权限做出选择"
    case cameraRestricted    = "用户无权访问相机"
    case cameraDenied        = "用户拒绝访问相机"
    case cameraAuthorized    = "用户允许访问相机"
}


struct AuthorizationManager{
    public static var photoStatus:PhotoAuthorizationStatus{
        let status = PHPhotoLibrary.authorizationStatus()
        var photoStatus: PhotoAuthorizationStatus = .photoNotDetermined
        switch status {
        case .notDetermined:
            photoStatus = .photoNotDetermined
        case .restricted:
            photoStatus = .photoRestricted
        case .denied:
            photoStatus = .photoDenied
        case .authorized:
            photoStatus = .photoAuthorized
        @unknown default:
            photoStatus = .photoNotDetermined
        }
        return photoStatus
    }
    
    
    public static var cameraStatus:CameraAuthorizationStatus{
        let status =  AVCaptureDevice.authorizationStatus(for: .video)
        var cameraStatus: CameraAuthorizationStatus = .cameraNotDetermined
        switch status {
        case .notDetermined:
            cameraStatus = .cameraNotDetermined
        case .restricted:
            cameraStatus = .cameraRestricted
        case .denied:
            cameraStatus = .cameraDenied
        case .authorized:
            cameraStatus = .cameraAuthorized
        @unknown default:
            cameraStatus = .cameraNotDetermined
        }
        return cameraStatus
    }
    
    public static func checkPhotoAuthorization(complition:@escaping (PhotoAuthorizationStatus)->Void){
        if photoStatus == .photoAuthorized{
            complition(.photoAuthorized)
        }
        requestPhotoAuthorization(complition: complition)
    }
    
    
    public static func requestPhotoAuthorization(complition:@escaping (PhotoAuthorizationStatus)->Void){
        var photoStatus:PhotoAuthorizationStatus = .photoNotDetermined
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status{
            case .notDetermined:
                photoStatus = .photoNotDetermined
            case .restricted:
                photoStatus = .photoRestricted
            case .denied:
                photoStatus = .photoDenied
            case .authorized:
                photoStatus = .photoAuthorized
            @unknown default:
                photoStatus = .photoNotDetermined
            }
            DispatchQueue.main.async {
                complition(photoStatus)
            }
        }
    }
    
    public  static func checkCameraAuthorization(complition:@escaping (CameraAuthorizationStatus)->Void){
        if cameraStatus == .cameraAuthorized{
            complition(.cameraAuthorized)
        }
        requestCameraAuthorization(complition: complition)
    }
    
    public static func requestCameraAuthorization(complition:@escaping (CameraAuthorizationStatus)->Void){
        var cameraStatus: CameraAuthorizationStatus = .cameraNotDetermined
        AVCaptureDevice.requestAccess(for: .video) { (isSuccess) in
            if isSuccess{
                cameraStatus = .cameraAuthorized
            }else{
                cameraStatus = .cameraDenied
            }
            DispatchQueue.main.async {
               complition(cameraStatus)
            }
        }
    }
    
}

