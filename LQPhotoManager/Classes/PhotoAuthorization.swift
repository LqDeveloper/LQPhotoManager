//
//  PhotoAuthorization.swift
//  LQPhotoManager
//
//  Created by Quan Li on 2019/8/20.
//  Copyright © 2019 williamoneilchina. All rights reserved.
//

import Foundation
import Photos


public enum PhotoAuthorizationStatus:String{
    case photoNotDetermined = "用户尚未做出选择"
    case photoRestricted    = "无权访问照片数据。"
    case photoDenied        = "用户拒绝访问照片数据。"
    case photoAuthorized    = "用户允许访问照片数据。"
}


extension LQPhotoManager{
    
  public  func authorizationStatus() -> PhotoAuthorizationStatus{
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
    
    public  func requestPhotoAuthorization(completion:@escaping (PhotoAuthorizationStatus)->Void){
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
            completion(photoStatus)
        }
    }
}

