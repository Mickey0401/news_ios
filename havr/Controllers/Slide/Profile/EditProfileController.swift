//
//  EditProfileController.swift
//  havr
//
//  Created by Agon Miftari on 4/22/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import MBProgressHUD
import Whisper
import TwitterCore
import TwitterKit
import Accounts
import KILabel


typealias Success = Bool

class EditProfileController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: - OUTLETS
    @IBOutlet weak var usernameCheckImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var twitterUserImageView: UIImageView!
    @IBOutlet weak var twitterUserNameLabel: KILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var selectionView: SelectionView!
    
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    
    //MARK: - VARIABLES
    var imageMedia: Media?
    var isUsernameFree : Bool = true
    var uploaded: (image: Bool, data: Bool) = (false, false)
    
    fileprivate lazy var keyboardToolbar: UIToolbar = {
        let t = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let barButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Done") , style: .plain, target: self, action: #selector(handleNextButton))
        barButton.tintColor = Apperance.appBlueColor
        
        t.setItems([space, barButton], animated: false)
        return t
    }()
    
    lazy var genderPickerView: GenderPickerView = {
        let v = GenderPickerView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 220))
        return v
    }()
    
    lazy var agePickerView: AgePickerView = {
        let v = AgePickerView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 220))
        return v
    }()
    
    var user: User!
    
    @objc fileprivate func handleNextButton(uibutton: UIBarButtonItem) {
        if genderTextField.isFirstResponder {
            self.view.endEditing(true)
        }else if ageTextField.isFirstResponder {
            self.view.endEditing(true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.backgroundColor = .white // UIColor(red255: 251, green255: 250, blue255: 250)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        userImageView.addTapGestureFor(self, #selector(EditProfileController.cameraButtonPressed(_:)))
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        navigationController?.navigationBar.barTintColor = .white
        commonInit()
        fetchProfile()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(EditProfileController.openTwitter))
        twitterUserNameLabel.addGestureRecognizer(tapGesture)
        twitterUserNameLabel.isUserInteractionEnabled = true
        guard Twitter.sharedInstance().sessionStore.hasLoggedInUsers() else {
            twitterUserNameLabel.text = "twitter username"
            return
        }
        twitterUserNameLabel.text = "@" + "\(UserDefaults.standard.value(forKey: "user_connected_twitter_username") as? String ?? "twitter username")"
        twitterUserNameLabel.textColor = UserDefaults.standard.value(forKey: "user_connected_twitter_username") != nil ? UIColor(red255: 4, green255: 128, blue255: 229) : UIColor.lightGray
        
        let url = URL(string: UserDefaults.standard.value(forKey: "user_connected_twitter_profile_image_url") as? String ?? "")
        twitterUserImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "tweetIcon"), options: nil, progressBlock: nil, completionHandler: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let interest = ResourcesManager.activeInterestsWithoutSaved.map({ (interes) -> InterestContent in
            return InterestContent.interest(name: interes.item?.name, imageUrl: interes.item?.getUrl(), isSeen: interes.item?.isSeen, id: (interes.item?.id)!)
        })
        selectionView.datasource = interest
        selectionView.selectionInterestCollection.reloadData()
    }
    
    func commonInit() {
        ageTextField.inputAccessoryView = keyboardToolbar
        genderTextField.inputAccessoryView = keyboardToolbar
        
        nameTextField.delegate = self
        genderTextField.delegate = self
        ageTextField.delegate = self
        usernameTextField.delegate = self
        
        ageTextField.inputView = agePickerView
        genderTextField.inputView = genderPickerView
        
        agePickerView.selectedValueChanged = {[unowned self] picker in
            self.ageTextField.text = picker.selectedValue?.description
        }
        
        genderPickerView.selectedValueChanged = { [unowned self] picker in
            var gender = picker.selectedValue
            if picker.selectedValue == "Neutral" {
                gender = ""
            }
            self.genderTextField.text = gender
        }
        usernameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        usernameTextField.delegate = self
        
        selectionView.delegate = self
    }
    
    func fetchProfile(){
        if let user = user {
            nameTextField.text = user.fullName
            usernameTextField.text = user.username
            ageTextField.text = user.age.toString
            genderTextField.text = user.gender
            
            if user.gender == "Other" || user.gender == "" {
                genderTextField.text = ""
                genderTextField.placeholder = "Set Gender"
            }
            if user.age == 0 {
                ageTextField.text = ""
                ageTextField.placeholder = "Set Age"
            }
            
            if let image = user.getUrl() {
                userImageView.kf.setImage(with: image, placeholder: Constants.cameraBackground)
                self.view.layoutIfNeeded()
            }else {
                userImageView.setImageForName(string: user.fullName, circular: true, textAttributes: nil)
            }
        }
    }
    
    func updateProfile(){
        
        let validation = validateInputs()
        
        if validation.success {
            self.showHud()
            saveButton.isEnabled = false
            if let media = self.imageMedia {
                let updatedUser = updateUser()
                media.upload(completion: { (media, success, error) in
                    self.saveButton.isEnabled = true
                    self.hideHud()
                    if success {
                        updatedUser.photo = media.getAbsolute()
                        self.performUpdate(user: updatedUser)
                    }else{
                        //media was not uploaded
                    }
                })
            } else {
                performUpdate(user: updateUser())
            }
        }else{
            // show error
            self.hideHud()
            MBProgressHUD.showWithStatus(view: self.view, text: validation.message, image: #imageLiteral(resourceName: "ERROR"))
        }
    }
    
    func performUpdate(user: User){
        UsersAPI.updateProfile(user: user, completion: { (user, error) in
            self.saveButton.isEnabled = true
            self.hideHud()
            if let user = user {
                AccountManager.currentUser = user
                AccountManager.currentUser?.store()
                SearchFilter.reset()
                self.slideController.profile.user = AccountManager.currentUser
                MBProgressHUD.showWithStatus(view: self.view, text: "Success", image: #imageLiteral(resourceName: "SUCCESS"))
                self.hideModal()
            }else {
                MBProgressHUD.showWithStatus(view: self.view, text: "Error", image: #imageLiteral(resourceName: "ERROR"))
            }
        })
    }
    
    fileprivate func updateUser()-> User{
        let user = User()
        user.id = self.user.id
        user.fullName = nameTextField.text!
        user.age = Int((ageTextField.text?.toDouble()!)!)
        user.gender = genderTextField.text ?? "Other"
        
        //CHECK USERNAME TO BE IMPLEMENTED
        user.username = usernameTextField.text!
        user.photo = self.user.photo
        
        return user
    }
    
    func validateInputs() -> (success: Success, message: ErrorMessage, control: UIView) {
        
        guard let fullname = nameTextField.text, !fullname.isEmpty else {
            return (false, "Profile must have a name.", nameTextField)
        }
        
        guard let username = usernameTextField.text, !username.isEmpty && (usernameTextField.text?.characters.count)! > 4 else {
            return (false, "Profile must have a username and should have more than 4 characters.", usernameTextField)
        }
        if !isUsernameFree{
            usernameTextField.shake()
        }
        
        return (true, "", UIView())
    }
    
    @IBAction func cameraButtonPressed(_ sender: UIImageView) {
        let editPicture = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takeApicture = UIAlertAction(title: "Take a Photo", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in self.openCamera(sender) })
        let chooseFromCameraRoll = UIAlertAction(title: String.localized("Choose From Camera Roll"), style: .default, handler: {
            (alert: UIAlertAction!) -> Void in  self.openPhotoLibraryButton(sender) })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in })
        
        editPicture.addAction(takeApicture)
        editPicture.addAction(chooseFromCameraRoll)
        editPicture.addAction(cancelAction)
        editPicture.view.tintColor = Apperance.appBlueColor
        self.present(editPicture, animated: true, completion: nil)
        editPicture.view.tintColor = Apperance.appBlueColor
    }
    @IBAction func cancelBarPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Discard Changes", message: "Are you sure you want to discard your changes?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (_) in
            //
        }))
        
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (_) in
            
            self.hideModal()
            
        }))
        
        alert.view.tintColor = Apperance.appBlueColor
        self.present(alert, animated: true, completion: nil)
        alert.view.tintColor = Apperance.appBlueColor
        
    }
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        updateProfile()
    }
    
    //MARK: - FUNCTIONS
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
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.userImageView.image = image
            self.userImageView.contentMode = .scaleAspectFill
            let media = Media.create(for: image)
            
            self.imageMedia = media
        }
        
        picker.dismiss(animated: true, completion: {
        })
    }
    func textFieldDidChange(_ textField: UITextField) {
        checkUsername(username: textField.text!)
    }
    func checkUsername(username: String) {
        if username != user.username {
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
                self.isUsernameFree = false
                self.usernameCheckImageView.image = nil
            }
        }else {
            self.isUsernameFree = true
            self.usernameCheckImageView.image = nil
        }
    }
    
}

extension EditProfileController {
    static func create() -> EditProfileController {
        return UIStoryboard.profile.instantiateViewController(withIdentifier: "EditProfileController") as! EditProfileController
    }
}
extension EditProfileController: SelectionViewDelegate {
    func didSelect(interest: Interest, at index: Int) {
        let interest = InterestController.create()
        //        let nav = UINavigationController(rootViewController: interest)
        //        self.showModal(nav)
        self.push(interest)
    }
}

extension EditProfileController : UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }
        switch textField {
        case nameTextField:
            if text.count < 12 {
                let message = Whisper.Announcement(title: "Your name is too short :(")
                Whisper.show(shout: message, to: navigationController!)

            }
            if text.count > 19 {
                let message = Whisper.Announcement(title: "Your name need to be more shortly")
                Whisper.show(shout: message, to: navigationController!)

            }
        case usernameTextField:
            if text.count > 29 {
                let message = Whisper.Announcement(title: "The limit is 29 characters, please adjust")
                Whisper.show(shout: message, to: navigationController!)
            }
        case ageTextField:
            guard let age = Int(text) else { return }
            guard !(3...99).contains(age) else { return }
            let message = Whisper.Announcement(title: "The age limit is from 13 to 99")
            Whisper.show(shout: message, to: navigationController!)

        default:
            print("other rext field")
        }
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if ageTextField == textField {
            
            agePickerView.selectedValue = user.age
            
        }
        
        if genderTextField == textField {
            
            if user.gender == "Other"  || user.gender == ""{
                
                genderPickerView.selectedValue = "Not specified"
            } else {
                genderPickerView.selectedValue = user.gender
            }
        }
        
        return true
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.nameTextField {
            if !(textField.text!.count <= 19) {
                nameTextField.shake()
                let message = Whisper.Announcement(title: "Your name need to be more shortly")
                Whisper.show(shout: message, to: navigationController!)
                return false
            } else { return true }
        }
        
        if (textField == self.usernameTextField) {
            if textField.isTextContainIncorrectCharacter || !(textField.text!.count <= 29) {
                print(range)
                let message = Whisper.Announcement(title: "The limit is 29 characters, please adjust")
                Whisper.show(shout: message, to: navigationController!)
                usernameTextField.shake()
                return false
            } else {
                 return true
            }
        }
        return true
    }
}

extension EditProfileController {
    func openTwitter() {
        Twitter.sharedInstance().logIn(with: self) { (session, error) in
            guard let session = session else { return }
            guard error == nil else {
                let alertConstroller = UIAlertController(title: "Error", message: "Couldn't connect your twitter account %(", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alertConstroller.addAction(cancelAction)
                self.present(alertConstroller, animated: true, completion: nil)
                return
            }
            self.twitterUserNameLabel.text = "@" + session.userName
            UserDefaults.standard.set(session.userName, forKey: "user_connected_twitter_username")
            UserDefaults.standard.set(session.userID, forKey: "user_connected_twitter_id")
            let twitterClient = TWTRAPIClient(userID: session.userID)
            twitterClient.loadUser(withID: (session.userID), completion: { (user, error) in
                guard let user = user else {
                    self.twitterUserImageView.setImageForName(string: session.userName, circular: true, textAttributes: nil)
                    return
                }
                self.twitterUserImageView.kf.setImage(with: URL(string:user.profileImageURL))
                UserDefaults.standard.set(user.profileImageURL, forKey: "user_connected_twitter_profile_image_url")
            })
        }
    }
}

extension UITextField {
    var isTextContainIncorrectCharacter: Bool {
        let invalidCharacterSet = CharacterSet.init(charactersIn: " !@#$%^&*()+{}[]|\"<>,~`/:;?=\\¥'£•€¢")
        guard let range = self.text?.rangeOfCharacter(from: invalidCharacterSet) else { return false}
        return !range.isEmpty
    }
}
