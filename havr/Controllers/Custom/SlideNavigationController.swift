//
//  SlideNavigationController.swift
//  havr
//
//  Created by Arben Pnishi on 8/26/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

class SlideNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override var shouldAutorotate: Bool{
        return false
    }
}
