//
//  LQImagePickerManager.swift
//  LQPhotoManager
//
//  Created by Quan Li on 2019/8/21.
//  Copyright © 2019 williamoneilchina. All rights reserved.
//

import UIKit

public enum LQImagePickerStatus{
    case noPickerAuthorized
    case pickerNoAvailable
    case pickerAuthorized
}

open class LQImagePickerManager:NSObject{
    public typealias ImagePickerBlock = (UIImage?,UIImagePickerController.SourceType,LQImagePickerStatus)->Void
    public var imagePicker:UIImagePickerController?
    private var pickerHandler:ImagePickerBlock?
    
    
    /// 跳转到 UIImagePickerController
    /// 注意: 持有了当前类调用这个方法，需要使用 [unowned self] 或者[weak self] 防止循环引用
    /// - Parameters:
    ///   - vc: 当前vc
    ///   - sourceType: picker sourceType
    ///   - handler: 回调
    public func showPicker(_ vc:UIViewController,_ sourceType:UIImagePickerController.SourceType,_ handler:@escaping ImagePickerBlock){
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else{
            handler(nil,sourceType,.pickerNoAvailable)
            return
        }
        if  sourceType == .camera {
            AuthorizationManager.checkCameraAuthorization { (status) in
                guard status == .cameraAuthorized else{
                    handler(nil,sourceType,.noPickerAuthorized)
                    return
                }
                self.pickerHandler = handler
                self.createImagePicker(vc:vc,sourceType: sourceType)
            }
        }else{
            AuthorizationManager.checkPhotoAuthorization { (status) in
                guard status == .photoAuthorized else{
                    handler(nil,sourceType,.noPickerAuthorized)
                    return
                }
                self.pickerHandler = handler
                self.createImagePicker(vc:vc,sourceType: sourceType)
            }
        }
    }
    
    func createImagePicker(vc:UIViewController,sourceType:UIImagePickerController.SourceType){
        self.imagePicker = UIImagePickerController.init()
        self.imagePicker?.delegate = self
        self.imagePicker?.allowsEditing = true
        self.imagePicker?.sourceType = sourceType
        vc.present(self.imagePicker!, animated: true, completion: nil)
    }
    
}


extension LQImagePickerManager:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let editImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        if let image = editImage {
            pickerHandler?(image,picker.sourceType,.pickerAuthorized)
            picker.dismiss(animated: true, completion: nil)
            return
        }
        let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        if let image = originalImage {
            pickerHandler?(image,picker.sourceType,.pickerAuthorized)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
