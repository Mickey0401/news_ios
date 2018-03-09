//
//  BaseImagePickerController.swift
//  havr
//
//  Created by Mickey on 3/2/18.
//  Copyright © 2018 Tenton LLC. All rights reserved.
//

import UIKit

class BaseImagePickerController: UIImagePickerController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.isTranslucent = false
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.black,
                                                  NSFontAttributeName: UIFont.init(name: "SF Pro Display", size: 18)!]
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
