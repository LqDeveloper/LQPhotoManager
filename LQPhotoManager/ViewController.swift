//
//  ViewController.swift
//  LQPhotoManager
//
//  Created by Li on 2019/8/20.
//  Copyright © 2019 . All rights reserved.
//

import UIKit
import Photos
class ViewController: UITableViewController {
    var albums:PHFetchResult<PHAssetCollection>?
    var photoManager:LQPhotoManager?
    var picker:LQImagePickerManager?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "UITableViewCell")
        self.photoManager = LQPhotoManager.init(photoDelegate: self)
        self.photoManager?.requestPhotosData()
    }
    
    deinit {
        self.photoManager?.unregisterChangeObserver()
    }
    @IBAction func showPicker(_ sender: Any) {

        self.picker = LQImagePickerManager.init()
        self.picker?.showPicker(self, .photoLibrary, {[weak self] (image, _, _) in
           
        })
    }
    
    @IBAction func addAlbum(_ sender: Any) {
        let alertController = UIAlertController.init(title: "添加相册", message: "请输入相册名", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "请输入相册名"
        }
        let cancleAction = UIAlertAction.init(title: "取消", style: .cancel) { (_) in
            
        }
        let okAction = UIAlertAction.init(title: "确定", style: .default) { (_) in
            let title = alertController.textFields?.first?.text
            LQPhotoManager.createAlbum(albumName: title)
        }
        
        alertController.addAction(cancleAction)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension ViewController:LQPhotoManagerDelegate{
    func photosDataDidChange(changeInstance: PHChange) {
        guard  let als = albums else {
            return
        }
        
        guard let changeDetails = changeInstance.changeDetails(for: als) else{
            return
        }
        albums = changeDetails.fetchResultAfterChanges
        tableView.reloadData()
    }
    
    func photosAuthorizationChange(status: PhotoAuthorizationStatus) {
        guard status == .photoAuthorized else {
            return
        }
        albums = LQPhotoManager.getAlbum(with: .album, subtype: .albumRegular)
        tableView.reloadData()
    }
}

extension ViewController{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums?.count ?? 0
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        cell.textLabel?.text = albums?[indexPath.row].localizedTitle
        cell.detailTextLabel?.text = "有\(String(describing: albums?[indexPath.row].estimatedAssetCount))张图片"
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
        guard let album = albums?[indexPath.row] else{
            return
        }
        LQPhotoManager.deleteAlbums(albumsToBeDeleted: [album])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard  let photoVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "PhotoVC") as? PhotoTableViewController else {
            return
        }
        photoVC.album = albums?[indexPath.row]
        navigationController?.pushViewController(photoVC, animated: true)
        
    }
}

