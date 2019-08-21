//
//  PhotoTableViewController.swift
//  LQPhotoManager
//
//  Created by Li on 2019/8/20.
//  Copyright © 2019 . All rights reserved.
//

import UIKit
import Photos
class PhotoTableViewController: UITableViewController {
    
    var album:PHAssetCollection?
    var photos:PHFetchResult<PHAsset>?
    var photoManager:LQPhotoManager?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = album?.localizedTitle
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "UITableViewCell")
        self.photoManager = LQPhotoManager.init(photoDelegate: self)
        self.photoManager?.requestPhotosData()
    }
    
    deinit {
        self.photoManager?.unregisterChangeObserver()
    }
    
    @IBAction func addAlbum(_ sender: Any) {
        let image = UIImage.init(named: "image.jpg")
        LQPhotoManager.addImage(image: image, toAlbum: self.album)
    }
}

extension PhotoTableViewController:LQPhotoManagerDelegate{
    func photosDataDidChange(changeInstance: PHChange) {
        guard let ph = photos else {
            return
        }
        guard let changeDetails = changeInstance.changeDetails(for: ph) else{
            return
        }
        photos = changeDetails.fetchResultAfterChanges
        tableView.reloadData()
    }
    
    func photosAuthorizationChange(status: PhotoAuthorizationStatus) {
        guard status == .photoAuthorized else {
            return
        }
        photos = LQPhotoManager.getPhotosFromAlbum(album: album)
        tableView.reloadData()
    }
}


extension PhotoTableViewController{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos?.count ?? 0
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        LQPhotoManager.changePHAssetToImage(photoAsset: photos?[indexPath.row], resultHandler: { (image, _) in
            cell.imageView?.image = image
        })
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let photo = photos?[indexPath.row] else{
            return
        }
        LQPhotoManager.deleteImagesFromAlbum(photoAssets: [photo])
    }
    
}
