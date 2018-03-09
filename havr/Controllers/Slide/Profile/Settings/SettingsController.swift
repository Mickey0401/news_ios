//
//  SettingsController.swift
//  havr
//
//  Created by Ismajl Marevci on 4/22/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import MBProgressHUD
import Photos

class SettingsController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var privacyButton: UIButton!
    @IBOutlet weak var contactUsButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var leftButton: UIBarButtonItem!
    @IBOutlet weak var rightButton: UIBarButtonItem!
    
    @IBOutlet weak var privacyView: PrivacyView!
    @IBOutlet weak var contactUsView: ContactUsView!
    
    lazy var photoLibraryPermission : AllowPermissionView = {
        let pL = AllowPermissionView.createForPhotoLibrary()
        return pL
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        privacyButton.isSelected = true
        leftButton.isEnabled = false
        leftButton.tintColor = UIColor.clear
        privacyView.blockedListButtonPressed = blockedListButtonPressed
        privacyView.changePasswordButtonPressed = changePasswordButtonPressed
        privacyView.logOutButtonPressed = logOutButtonPressed
        contactUsView.addScreenshotButtonPressed = addScreenshot
        
        privacyView.emailSwitch.isOn = AccountManager.currentUser!.isPublic
        
        privacyView.emailSwitchChanged = { [unowned self] emailSwitch in
            self.emailChanged(sender: emailSwitch)
        }
        
        photoLibraryPermission.permissionButtonPressed = permissionButtonPressed
        photoLibraryPermission.laterButtonPressed = laterButtonPressed
        
        chectIfIsFacebook()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GA.TrackScreen(name: "Camera")

//        if let nav = self.navigationController?.navigationBar {
//            Helper.setupBlueNavigationBar(navBar: nav)
//        }

    }
    
    @IBAction func leftButtonPressed(_ sender: UIBarButtonItem) {
        self.hideModal()
    }
    @IBAction func rightButtonPressed(_ sender: UIBarButtonItem) {
        if !privacyView.isHidden {
            self.hideModal(true)
        }else {
            self.hideModal(true) {
                Helper.show(alert: "Thank you for your feedback!")
            }
        }
    }
    
    @IBAction func contactUsButtonPressed(_ sender: UIButton) {
        viewIsHidden(filters: true, privacy: true, contactUs: false)
    }
    
    @IBAction func privacyButtonPressed(_ sender: UIButton) {
        viewIsHidden(filters: true, privacy: false, contactUs: true)
    }
    
    func emailChanged(sender: UISwitch) {
        let current = sender.isOn
        self.showHud()
        UsersAPI.updatePrivacy(isPublic: current) { (newStatus, error) in
            self.hideHud()
            if let status = newStatus {
                sender.isOn = status
                //update this profile
                AccountManager.updateProfile()
            }
            
            if let error = error {
                Helper.show(alert: error.message)
            }
        }
    }
    
    func chectIfIsFacebook() {
        
        if Preferences.isFacebook {
            privacyView.changePasswordView.isHidden = true
        }else {
            privacyView.changePasswordView.isHidden = false

        }
    }
    
    fileprivate func viewIsHidden(filters: Bool, privacy: Bool, contactUs: Bool){
        if !privacy {
            leftButton.isEnabled = false
            leftButton.tintColor = UIColor.clear
            rightButton.title = "Done"
        }else {
            rightButton.title = "Send"
            leftButton.isEnabled = true
            leftButton.tintColor = UIColor.white
            leftButton.setTitleTextAttributes([NSFontAttributeName: UIFont.robotoRegularFont(14)], for: .normal)
        }
        
        privacyView.isHidden = privacy
        contactUsView.isHidden = contactUs
        
        privacyButton.isSelected = !privacy
        contactUsButton.isSelected = !contactUs
    }
    
    func addScreenshot(sender: UIButton) {
        self.checkPhotoLibraryPermission()
        
    }
    func openPhotoLibraryButton(_ sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            
            imagePicker.navigationBar.barTintColor = Apperance.appBlueColor
            imagePicker.navigationBar.tintColor = UIColor.white
            imagePicker.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
            
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.dismiss(animated: true, completion: {
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
               self.contactUsView.screenshotImageView.image = image
            }
        })
    }
    
    func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            self.photoLibraryPermission.hide()
            self.openPhotoLibraryButton(self)
            
        //handle authorized status
        case .denied, .restricted :
            self.photoLibraryPermission.show(to: self.navigationController!.view)
            
        //handle denied status
        case .notDetermined:
            // ask for permissions
            PHPhotoLibrary.requestAuthorization() { status in
                switch status {
                case .authorized:
                    self.photoLibraryPermission.hide()
                    self.openPhotoLibraryButton(self)
                    
                // as above
                case .denied, .restricted:
                    // as above
                    self.photoLibraryPermission.show(to: self.navigationController!.view)
                case .notDetermined:
                    return
                    // won't happen but still
                }
            }
        }
    }
    
    func laterButtonPressed() {
        self.photoLibraryPermission.hide()
    }
    
    func permissionButtonPressed() {
        UIApplication.shared.openURL(NSURL(string:UIApplicationOpenSettingsURLString)! as URL)
    }
}

//MARK: - EXTENSIONS
extension SettingsController {
    static func create() -> SettingsController {
        return UIStoryboard.settings.instantiateViewController(withIdentifier: "SettingsController") as! SettingsController
    }
    
    func blockedListButtonPressed() {
        let blockedList = BlockedListController.create()
        self.push(blockedList)
    }
    
    func changePasswordButtonPressed() {
        let changePasswordVC = ChangePasswordController.create()
        self.push(changePasswordVC)
    }
    
    func logOutButtonPressed() {
        let alert = UIAlertController(title: "Log out", message: "Are you sure you want to \n log out?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (handler) in
            //Log Out function here ...
            self.showHud()
            AccountManager.delete()
            self.switchWindowRoot(to: .login)
            UsersAPI.logout(completion: { (success, error) in
                self.hideHud()
                if success {
                    print("Token removed.")
                }
            })
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (handler) in}))
        alert.view.tintColor = Apperance.appBlueColor
        self.present(alert, animated: true, completion: nil)
        alert.view.tintColor = Apperance.appBlueColor
    }
}

