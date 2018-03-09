//
//  ChangePasswordController.swift
//  havr
//
//  Created by Agon Miftari on 7/14/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import MBProgressHUD

class ChangePasswordController: UIViewController {
    
    
    @IBOutlet weak var currentPasswordField: UITextField!
    @IBOutlet weak var newPasswordField: UITextField!
    @IBOutlet weak var verifyNewPasswordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GA.TrackScreen(name: "Change Password")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func changePasswordButtonPressed(_ sender: UIButton) {
        
        changePassword()
    }
    
    
    func changePassword() {
        
        guard let oldPassword = currentPasswordField.text, oldPassword.characters.count > 5 else {
            
            Helper.show(alert: "Please provide the current Password")
            
            return
        }
        
        guard let newPassword = newPasswordField.text, !newPassword.isEmpty else {
            Helper.show(alert: "Please provide the new Password")
            
            return
        }
        
        guard let newPassword2 = verifyNewPasswordField.text, !newPassword2.isEmpty else {
            Helper.show(alert: "Please provide the new Password")
            
            return
        }
        
        
        if newPassword != newPassword2 {
            
            Helper.show(alert: "Passwords do not match!")
            
            return
        }
        
        self.showHud()
        
        UsersAPI.changePassword(oldPassword: oldPassword, newPassword: newPassword, newPassword2: newPassword2) { (success, error) in
        
            self.hideHud()
            if success {
                
                MBProgressHUD.showWithStatus(view: self.view, text: "Password Changed", image: #imageLiteral(resourceName: "SUCCESS"))

                delay(delay: 0.5, closure: {
                    self.pop()
                })
                
            }else {
                
                if let error = error {
                    Helper.show(alert: error.message)
                }
            }
            
        }
        
        
        
    }

}

extension ChangePasswordController {
    
    static func create() -> ChangePasswordController {
        
        return UIStoryboard.settings.instantiateViewController(withIdentifier: "ChangePasswordController") as! ChangePasswordController
    }
    
    
}

