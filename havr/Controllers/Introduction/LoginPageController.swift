//
//  LoginPageController.swift
//  havr
//
//  Created by Agon Miftari on 4/20/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import MBProgressHUD

class LoginPageController: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var termConditionLabel: UILabel!
    //MARK: - OUTLETS
//    @IBOutlet weak var nextStepButton: UIButton!
    @IBOutlet weak var loginFacebookButton: UIButton!
//    @IBOutlet weak var emailAddressField: UITextField!
    
    //MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
        termConditionLabel.text = "By signing up, you agree to our Terms & Privacy \n Policy" 
    }
    
    func commonInit(){
//        emailAddressField.delegate = self
        termConditionLabel.addTapGestureFor(self, #selector(privacyPolicyButtonClicked(_:)))
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        loginFunction()
        return true
    }
    
    //MARK: - ACTIONS
    @IBAction func loginFacebookButtonClicked(_ sender: UIButton) {
        
        sender.isEnabled = false
        let loginManager = LoginManager()
        loginManager.logOut()
        
        loginManager.logIn([.publicProfile, .email], viewController: self) { (loginResult) in
            switch loginResult{
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                console("fb login; granted:\(grantedPermissions) declined:\(declinedPermissions) accessToken:\(accessToken)")
                
                self.showHud()

                UsersAPI.loginWithFacebook(accessToken: accessToken.authenticationToken, completion: { (token, user, error) in
                    sender.isEnabled = true
                    self.hideHud()
                    if let user = user, let token = token {
                        Preferences.isFacebook = true
                        AccountManager.start(user: user, token: token)
                        //open
                        self.switchWindowRoot(to: .slide)
                    }
                    if let error = error {
                        Helper.show(alert: error.message)
                    }
                })
                
                break
            case .cancelled:
                sender.isEnabled = true
                console("fb User cancelled login.")
                break
            case .failed(let error):
                sender.isEnabled = true
                console("fb login error: \(error)")
                break
            }
        }
    }
    
    @IBAction func nextStepButtonClicked(_ sender: UIButton) {
//        emailAddressField.resignFirstResponder()
//        loginFunction()
        let controller = LoginPhoneNumberViewController.create()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    func loginFunction(){
//        guard let email = emailAddressField.text, !email.isEmpty else {
//            emailAddressField.shake()
//            return
//        }
        
//        if !email.isEmail {
//            Helper.show(alert: "Provided email is not valid.", title: nil, doneButton: "OK", completion: {
//                self.emailAddressField.shake()
//            })
//            return
//        }
        showHud()
        
 //       nextStepButton.isEnabled = false
//        UsersAPI.checkEmail(email: email) { (success, error) in
//            
//            self.nextStepButton.isEnabled = true
//            self.hideHud()
//            
//            if let success = success {
//                if success {
//                    let emailRegistration = EmailRegistrationController.create()
//                    emailRegistration.email = email
//
//                    self.push(emailRegistration)
//                } else {
//                    MBProgressHUD.showWithStatus(view: self.view, text: "Email taken", image: #imageLiteral(resourceName: "ERROR"))
//                }
//            }else if let error = error{
//                Helper.show(alert: error.message)
//            }
//        }
    }
    
    @IBAction func signInButtonClicked(_ sender: UIButton) {
        let logIn = LogInController.create()
        self.push(logIn)
    }
    
    @IBAction func termsButtonClicked(_ sender: UIButton) {
        let terms = TermsAndPrivacyController.create()
        terms.navTitle = "Terms of use"
        terms.termsOrPPText = Terms.termsText
        self.push(terms)
    }
    @IBAction func privacyPolicyButtonClicked(_ sender: UIButton) {
        let privacy = TermsAndPrivacyController.create()
        privacy.navTitle = "Privacy Policy"
        privacy.termsOrPPText = PrivacyPolicy.ppText
        self.push(privacy)
    }
}

//MARK: - EXTENSIONS
extension LoginPageController {
    static func create() -> LoginPageController {
        return UIStoryboard.introduction.instantiateViewController(withIdentifier: "LoginPageController") as! LoginPageController
    }
}
