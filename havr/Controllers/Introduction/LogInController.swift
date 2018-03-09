//
//  LogInController.swift
//  havr
//
//  Created by Ismajl Marevci on 4/27/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import MBProgressHUD


class LogInController: UIViewController {

    //MARK: - OUTLETS
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var backButton: UIButton!
    
    //MARK: - VARIABLES
    
    //MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        self.navigationController?.setNavigationBarHidden(true, animated: true)

    }
    func setNavigationImage(){
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 74, height: 35))
        imageView.contentMode = .scaleAspectFit
        let image = UIImage(named: "Havr name")
        imageView.image = image
        navigationItem.titleView = imageView
        
    }
    func forgotPassword(sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty else {
            emailTextField.shake()
            return
        }
        
        if !email.isEmail {
            MBProgressHUD.showWithStatus(view: self.view, text: "Provided email is not valid.", image: #imageLiteral(resourceName: "ERROR"))
            self.emailTextField.shake()
            return
        }
        sender.isEnabled = false
        showHud()
        UsersAPI.forgotPassword(email: email) { (success, error) in
            sender.isEnabled = true
            self.hideHud()
            if let success = success {
                if success {
                    Helper.show(alert: "We sent an email to \(email) with instructions for resetting your password.")
                } else {
                    Helper.show(alert: "No account with that email address exists", title: "Password Reset Failed", doneButton: "OK", completion: nil)
                }
            }
            
            if let error = error {
                Helper.show(alert: error.message)
            }
        }
    }
    
    //MARK: - ACTIONS
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.pop()
    }
    
    @IBAction func forgotPasswordButtonClicked(_ sender: UIButton) {
        passwordTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        forgotPassword(sender: sender)
    }
    
    @IBAction func logInButtonClicked(_ sender: UIButton) {
        passwordTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        guard let email = emailTextField.text, !email.isEmpty else {
            emailTextField.shake()
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            passwordTextField.shake()
            return
        }
        showHud()

        sender.isEnabled = false
        UsersAPI.logMe(username: email, password: password) { (user, token, error) in
            sender.isEnabled = true
            self.hideHud()
            if let user = user, let token = token {
                AccountManager.start(user: user, token: token)
                //open
                self.switchWindowRoot(to: .slide)
            }
            if let error = error {
                MBProgressHUD.showWithStatus(view: self.view, text: error.message, image: #imageLiteral(resourceName: "ERROR"))
            }
        }
    }
}
//MARK: - EXTENSIONS
extension LogInController {
    static func create() -> LogInController {
        return UIStoryboard.introduction.instantiateViewController(withIdentifier: "LogInController") as! LogInController
    }
}
