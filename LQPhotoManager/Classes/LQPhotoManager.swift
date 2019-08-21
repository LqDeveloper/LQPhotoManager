//
//  LQPhotoManager.swift
//  LQPhotoManager
//
//  Created by Li on 2019/8/20.
//  Copyright © 2019 . All rights reserved.
//

/*
 常用类介绍
 1.PHPhotoLibrary:该类用于表示设备和iCloud上所有的收藏和资源。可以使用一个共享实例以一种线程安全的方法对照片库的变化进行管理，
 比如添加新的资源和相簿，或者编辑和删除已有的资源或相簿，此外,共享实例还可以注册一个关于照片库发生变化的监听对象，以实现用户界面的同步。
 
 2.PHAssetCollection:该类一般用于表示一组照片或者视频》可以在设备上本地创建，可以从iPhone中同步照片，可以从相册或保存照片的相簿中获取图片，或者从根据一定的约束条件得到的智能相簿中
 （比如全景照片）同步图片。该类还提供以组的方式访问资源。资源集合可以以集合列表的方式进行组合。
 
 3.PHAsset:该类用于表示照片或者视频的元数据。它提供了一些类方法，返回使用了相同约束条件的资源结果，提供带资源信息的实例方法，比如日期，位置，类型，和方向之类的信息。
 
 4.PHFetchResult:这是一个轻量级的对象，用于表示一组资源或者资源集合。当按照约束条件请求资源或者资源集合时m，类方法将会返回一个抓取结构（fetch result）。抓取结果会按照需求载入资源
 而不是一次将所有资源载入内存，这样即使面对大资源也能很好的加以处理，抓取结果同时还是线程安全的，这意味着如果底层数据发生变化，对象的个数不会变。可以为照片库的变化注册一个请求通知类，这样变化通过PHFetchResultChangeDetails 实例发送，可以用于更新抓取结果和所有的相应的用户界面
 
 5.PHImageManager:图片管理器以异步的方式处理图片数据的抓取和保存，尤其适用于获取指定尺寸的图片或者管理从iCloud获取的图片数据。此外，当需要在表现图或者集合视图中显示大量资源时m，照片
 库还提供PHCachingImageManager 类来提升视图滑动的流畅度。
 
 
 public enum PHAssetCollectionType : Int {
 case album       /// 自己创建的相册
 
 case smartAlbum  /// 经由系统相机得来的相册
 
 case moment      /// 自动生成的时间分组的相册
 }
 
 
 public enum PHAssetCollectionSubtype : Int {
 
 
 // PHAssetCollectionTypeAlbum regular subtypes
 case albumRegular             // 在iPhone中自己创建的相册
 
 case albumSyncedEvent         // 从iPhoto（就是现在的图片app）中导入图片到设备
 
 case albumSyncedFaces         // 从图片app中导入的人物照片
 
 case albumSyncedAlbum         // 从图片app导入的相册
 
 case albumImported            // 从其他的相机或者存储设备导入的相册
 
 
 // PHAssetCollectionTypeAlbum shared subtypes
 case albumMyPhotoStream    // 照片流，照片流和iCloud有关，如果在设置里关闭了iCloud开关，就获取不到了
 
 case albumCloudShared      // iCloud的共享相册，点击照片上的共享tab创建后就能拿到了，但是前提是你要在设置中打开iCloud的共享开关（打开后才能看见共享tab）
 
 
 // PHAssetCollectionTypeSmartAlbum subtypes
 case smartAlbumGeneric      //一般的照片
 
 case smartAlbumPanoramas    // 全景图、全景照片
 
 case smartAlbumVideos       // 视频
 
 case smartAlbumFavorites    // 标记为喜欢、收藏
 
 case smartAlbumTimelapses   // 延时拍摄、定时拍摄
 
 case smartAlbumAllHidden    // 隐藏的
 
 case smartAlbumRecentlyAdded  // 最近添加的、近期添加
 
 case smartAlbumBursts         // 连拍
 
 case smartAlbumSlomoVideos    // 慢动作视频
 
 case smartAlbumUserLibrary    // 相机胶卷
 
 @available(iOS 9.0, *)
 case smartAlbumSelfPortraits    // 使用前置摄像头拍摄的作品
 
 @available(iOS 9.0, *)
 case smartAlbumScreenshots      // 屏幕截图
 
 @available(iOS 10.2, *)
 case smartAlbumDepthEffect      // 使用深度摄像模式拍的照片
 
 @available(iOS 10.3, *)
 case smartAlbumLivePhotos       //Live Photo资源
 
 @available(iOS 11.0, *)
 case smartAlbumAnimated
 
 @available(iOS 11.0, *)
 case smartAlbumLongExposures
 
 // Used for fetching, if you don't care about the exact subtype
 case any
 }
 
 使用说明
 需要在Info.plist 中添加
 Privacy - Photo Library Additions Usage Description 添加图片
 Privacy - Photo Library Usage Description           读取图片
 */
import Foundation
import Photos
open class LQPhotoManager:NSObject {
    public weak var delegate:LQPhotoManagerDelegate?
    public init(photoDelegate:LQPhotoManagerDelegate?){
        delegate = photoDelegate
        super.init()
        PHPhotoLibrary.shared().register(self)
    }
    
    public func unregisterChangeObserver(){
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }

    public func requestPhotosData(){
        AuthorizationManager.checkPhotoAuthorization { (status) in
            self.notifyObserver(status: status)
        }
    }
}



/*
 可以使用PHChnage下面的方法去监听发生的变化
 public func changeDetails<T>(for fetchResult: PHFetchResult<T>) -> PHFetchResultChangeDetails<T>? where T : PHObject
 
 通过PHFetchResultChangeDetails的下面的发生的变化
 //
 open var fetchResultBeforeChanges: PHFetchResult<ObjectType> { get }
 
 open var fetchResultAfterChanges: PHFetchResult<ObjectType> { get }
 */
public protocol LQPhotoManagerDelegate:AnyObject{
    func photosDataDidChange(changeInstance: PHChange)
    func photosAuthorizationChange(status:PhotoAuthorizationStatus)
}

extension LQPhotoManager{
    /// 获取相册
    ///
    /// - Parameters:
    ///   - type: 相册类型
    ///   - subtype: 哪种类型拍摄的
    ///   - options: 筛选条件
    public class func getAlbum(with type: PHAssetCollectionType, subtype: PHAssetCollectionSubtype, options: PHFetchOptions? = nil)-> PHFetchResult<PHAssetCollection>{
        return PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.album, subtype: PHAssetCollectionSubtype.any, options: options)
    }
    
    
    
    /// 创建相册
    ///
    /// - Parameter albumName: 相册的名字
    public class  func createAlbum(albumName:String?) {
        guard let name = albumName else{
            return
        }
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name)
        }) { (success, error) in
            if !success{
                print("创建相册失败 错误信息:\(error?.localizedDescription ?? "没有错误信息")")
            }
        }
    }
    
    /// 删除多个相册
    ///
    /// - Parameter albumsToBeDeleted: [PHAssetCollection]?
    public class func deleteAlbums(albumsToBeDeleted: [PHAssetCollection]?) {
        guard let albums = albumsToBeDeleted else {
            return
        }
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.deleteAssetCollections(albums as NSFastEnumeration)
        }) { (success, error) in
            if !success{
                print("删除多个相册失败 错误信息:\(error?.localizedDescription ?? "没有错误信息")")
            }
        }
    }
    
    /// 获取相册中的照片
    ///
    /// - Parameter album: PHAssetCollection
    /// - Returns: PHFetchResult<PHAsset>
    public class func getPhotosFromAlbum(album:PHAssetCollection?) -> PHFetchResult<PHAsset>? {
        guard let al = album else {
            return nil
        }
        return PHAsset.fetchAssets(in: al, options: nil)
    }
    
    
    
    /// 将图片加入相册
    ///
    /// - Parameters:
    ///   - image: UIImage
    ///   - toAlbum: PHAssetCollection
    public class func addImage(image:UIImage?,toAlbum:PHAssetCollection?){
        guard let img = image,let album = toAlbum  else {
            return
        }
        
        PHPhotoLibrary.shared().performChanges({
            let addImageRequest = PHAssetChangeRequest.creationRequestForAsset(from: img)
            let addedImagePlaceholder = addImageRequest.placeholderForCreatedAsset
            let addImageToAlbum = PHAssetCollectionChangeRequest.init(for: album)
            addImageToAlbum?.addAssets([addedImagePlaceholder] as NSFastEnumeration)
        }) { (success, error) in
            if !success{
                print("将图片加入相册失败 错误信息:\(error?.localizedDescription ?? "没有错误信息")")
            }
        }
    }
    
    
    /// 将照片从相册中删除
    ///
    /// - Parameter photoAssets: [PHAsset]
    public class func deleteImagesFromAlbum(photoAssets:[PHAsset]?){
        guard let photos = photoAssets else {
            return
        }
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(photos as NSFastEnumeration)
        }) { (success, error) in
            if !success{
                print("将图片加入相册失败 错误信息:\(error?.localizedDescription ?? "没有错误信息")")
            }
        }
    }
    
    
    /// 将PHAsset 转成Image
    ///
    /// - Parameters:
    ///   - photoAsset: PHAsset
    ///   - imageSize:  图片尺寸
    ///   - contentMode: 拉伸模式
    ///   - resultHandler: 转换成功后的回调
    public class func changePHAssetToImage(photoAsset:PHAsset?,contentMode:PHImageContentMode = PHImageContentMode.aspectFill,resultHandler: @escaping (UIImage?, [AnyHashable : Any]?) -> Void) {
        guard let photoA = photoAsset else {
            return
        }
        
        let imageManager =  PHImageManager.default()
        imageManager.requestImage(for: photoA, targetSize: CGSize.init(width: photoA.pixelWidth, height: photoA.pixelHeight), contentMode: contentMode, options: nil) { (image, imageInfo) in
            resultHandler(image,imageInfo)
        }
    }
    
    internal func notifyObserver(status:PhotoAuthorizationStatus){
        DispatchQueue.main.async {
            self.delegate?.photosAuthorizationChange(status: status)
        }
    }
}


extension LQPhotoManager:PHPhotoLibraryChangeObserver{
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            self.delegate?.photosDataDidChange(changeInstance: changeInstance)
        }
    }
}
