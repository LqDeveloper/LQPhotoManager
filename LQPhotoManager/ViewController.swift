//
//  ViewController.swift
//  LQPhotoManager
//
//  Created by Quan Li on 2019/8/20.
//  Copyright © 2019 williamoneilchina. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        LQPhotoManager.shared.requestPhotoAuthorization { (status) in
            print(status)
        }
    }


}

