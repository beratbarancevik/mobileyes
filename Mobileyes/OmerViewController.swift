//
//  OmerViewController.swift
//  Mobileyes
//
//  Created by Berat Baran Cevik on 27/04/2019.
//  Copyright © 2019 Mobileyes. All rights reserved.
//

import UIKit

class OmerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeTabBar()
        // Do any additional setup after loading the view.
    }
    
    private func initializeTabBar() {
        if let items = tabBarController?.tabBar.items {
            for item in items {
                item.imageInsets = UIEdgeInsets.init(top: 5.5, left: 0, bottom: -5.5, right: 0)
            }
        }
    }
}
