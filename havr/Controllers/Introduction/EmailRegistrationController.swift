//
//  EmailRegistrationController.swift
//  havr
//
//  Created by Agon Miftari on 4/20/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import MBProgressHUD

class EmailRegistrationController: UIViewController, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    //MARK: - OUTLETS
    @IBOutlet weak var usernameCheckImageView: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var fullNameField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    var email: String!
    var isUsernameFree : Bool = false
    var imageMedia: Media?
    var token: String! 
    
    //MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        usernameField.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    //MARK: - DELEGATES
    func openCamera(_ sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
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
        
        
        self.dismiss(animated: true) {
            if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
                self.profileImage.image = image
                self.profileImage.contentMode = .scaleAspectFill
                
                let resizedImage = image.resizeUserImage(isSignup: true)
                
                let media = Media.create(for: resizedImage)
                
                self.imageMedia = media
            }
        }
    }
    
    
    //MARK: - ACTIONS
    @IBAction func cameraButtonClicked(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takeApicture = UIAlertAction(title: "Take a Photo", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in self.openCamera(sender) })
        let chooseFromCameraRoll = UIAlertAction(title: String.localized("Choose From Camera Roll"), style: .default, handler: {
            (alert: UIAlertAction!) -> Void in  self.openPhotoLibraryButton(sender) })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in })
        
        alert.addAction(takeApicture)
        alert.addAction(chooseFromCameraRoll)
        alert.addAction(cancelAction)
        
        alert.view.tintColor = Apperance.appBlueColor
        self.present(alert, animated: true, completion: nil)
        alert.view.tintColor = Apperance.appBlueColor
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.pop()
    }
    
    @IBAction func doneButtonClicked(_ sender: UIButton) {
        
        register(sender: sender)
    }
    
    @IBAction func signInButtonClicked(_ sender: UIButton) {
        let logIn = LogInController.create()
        self.push(logIn)
    }
    
    func createUser(sender: UIButton, token: String, full_name: String, username: String, media: Media?) {
        UsersAPI.register(token: token, full_name: full_name, username: username, photo: media?.getAbsolute(), completion: { (token, user, error) in
            sender.isEnabled = true
            self.hideHud()
            if let token = token, let user = user{
                sender.isEnabled = true
                if let media = media {
                    user.photo = media.getAbsolute()
                }
                AccountManager.start(user: user, token: token)
                self.switchWindowRoot(to: .slide)
            }else{
                //user creation failed
                if let error = error {
                    Helper.show(alert: error.message)
                }
                
            }
        })
    }
    
    func register(sender: UIButton) {
        guard let username = usernameField.text, !username.isEmpty && username.count > 4 else {
            usernameField.shake()
            return
        }
        
        guard let full_name = fullNameField.text, !full_name.isEmpty else {
            fullNameField.shake()
            return
        }
        
        if !isUsernameFree {
            usernameField.shake()
            return
        }
        
        self.showHud()
        sender.isEnabled = false
        
        if let media = imageMedia {
            switch media.uploadStatus {
            case .uploaded:
                createUser(sender: sender, token: token, full_name: full_name, username: username, media: media)
            default:
                media.upload(completion: {[unowned self] (media, success, error) in
                    self.hideHud()
                    guard success else {
                        if let error = error {
                            Helper.show(alert: error)
                        }
                        return
                    }
                    self.createUser(sender: sender, token: self.token, full_name: full_name, username: username, media: media)

                })
            }
        } else {
            createUser(sender: sender, token: token, full_name: full_name, username: username, media: imageMedia)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if passwordField.resignFirstResponder() {
            register(sender: doneButton)
            return true
        }
        return false
    }
    func textFieldDidChange(_ textField: UITextField) {
        checkUsername(username: textField.text!)
    }
    
    func checkUsername(username: String) {
        if ((username.characters.count) > 4) {
            UsersAPI.checkUsername(username: username) { (success, error) in
                if let success = success  {
                    if success{
                        self.isUsernameFree = true
                        self.usernameCheckImageView.image = #imageLiteral(resourceName: "SuccessfulCheck")
                        print("success")
                    }else {
                        self.isUsernameFree = false
                        self.usernameCheckImageView.image = #imageLiteral(resourceName: "FailedCheck")
                        print ("error")
                    }
                }
            }
        }else {
            self.usernameCheckImageView.image = nil
        }
    }
}


//MARK: - EXTENSIONS
extension EmailRegistrationController {
    static func create() -> EmailRegistrationController {
        return UIStoryboard.introduction.instantiateViewController(withIdentifier: "EmailRegistrationController") as! EmailRegistrationController
    }
}

extension EmailRegistrationController : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let validString = CharacterSet.init(charactersIn: " !@#$%^&*()+{}[]|\"<>,~`/:;?=\\¥'£•€¢")
        
        // restrict special char in test field
        if (textField == self.usernameField)
        {
            if let range = string.rangeOfCharacter(from: validString)
            {
                print(range)
                usernameField.shake()
                return false
            }
            else
            {
                
                return true
            }
        }
        return true
    }
}
