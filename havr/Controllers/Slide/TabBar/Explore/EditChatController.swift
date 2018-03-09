//
//  EditChatController.swift
//  havr
//
//  Created by Agon Miftari on 5/3/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import GooglePlaces


protocol EditChatRoomControllerDelegate: class {
    func didUpdate(chatRoom: ChatRoom)
    func didDelete(chatRoom: ChatRoom)
}

class EditChatController: UIViewController {
    
    @IBOutlet weak var editImageButton: UIButton!
    @IBOutlet weak var editImageView: RoundedImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    
    @IBOutlet weak var firstDistanceButton: UIButton!
    @IBOutlet weak var firstDistanceLabel: UILabel!
    @IBOutlet weak var firstDistanceView: UIView!
    
    @IBOutlet weak var secondDistanceButton: UIButton!
    @IBOutlet weak var secondDistanceLabel: UILabel!
    @IBOutlet weak var secondDistanceView: UIView!
    
    @IBOutlet weak var thirdDistanceButton: UIButton!
    @IBOutlet weak var thirdDistanceLabel: UILabel!
    @IBOutlet weak var thirdDistanceView: UIView!
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    var addressCoordinate: CLLocationCoordinate2D?
    var imageMedia : Media?
    var bingImage: BingImage?
    var proximity: Double?
    
    weak var delegate: EditChatRoomControllerDelegate!
    
    var chatRoom : ChatRoom!
    
    @IBOutlet weak var deleteButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchChatRoom()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GA.TrackScreen(name: "Edit Chatroom")

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func fetchChatRoom() {
        
        if let chatRoom = chatRoom {
            
            nameField.text = chatRoom.name
            addressField.text = chatRoom.address
            addressCoordinate = chatRoom.location?.coordinate
            if let image = chatRoom.getImageUrl() {
                editImageView.kf.setImage(with: image, placeholder: Constants.cameraBackground)
            }else {
                editImageView.image = Constants.cameraBackground
            }
            
            if chatRoom.proximity > 0.0 && chatRoom.proximity < 5.0 {
                firstDistanceAppearance()
            }else if chatRoom.proximity >= 5.0 && chatRoom.proximity < 50.0 {
                secondDistanceAppearance()
            }else if chatRoom.proximity >= 50.0{
                thirdDistanceAppearance()
            }
        }
    }
    
    func updateChatRoom(){
        
        let validation = validateInputs()
        
        if validation.success {
            doneButton.isEnabled = false
            let updatedChat = updateChat()

            if let media = self.imageMedia{
                media.upload(completion: { (media, success, error) in
                    self.doneButton.isEnabled = true
                    if success {
                        updatedChat.photo = media.getAbsolute()
                        self.updateChatRoom(room: updatedChat)
                    }else{
                        //media was not uploaded
                    }
                })
            }else if let bingImage = self.bingImage{
                updatedChat.photo = bingImage.path
                self.updateChatRoom(room: updatedChat)
            }else{
                self.updateChatRoom(room: updateChat())
            }
        }
        else {
            self.hideHud()
            Helper.show(alert: validation.message)
        }
    }
    
    func updateChatRoom(room: ChatRoom){
        self.showHud()
        ChatRoomAPI.updateRoom(with: self.chatRoom.id, chatRoom: room, completion: { (chatRoom, error) in
            self.hideHud()
            if let chat = chatRoom {
                
                self.delegate.didUpdate(chatRoom: chat)
                self.hideModal()
            }
            
            if let error = error {
                Helper.show(alert: error.message)
            }
        })
    }
    
    fileprivate func updateChat() -> ChatRoom {
        let chatRoom = ChatRoom()
        
        chatRoom.id = self.chatRoom.id
        chatRoom.name = nameField.text!
        chatRoom.address = addressField.text!
        
        if let prox = proximity {
            chatRoom.proximity = prox
        }
        
        if let latitude = addressCoordinate?.latitude {
            chatRoom.latitude = latitude
        }
        if let longitude = addressCoordinate?.longitude {
            chatRoom.longitude = longitude
        }
        chatRoom.photo = self.chatRoom.photo
        
        return chatRoom
    }
    
    func validateInputs() -> (success: Success, message: ErrorMessage, control: UIView) {
        
        guard let fullname = nameField.text, !fullname.isEmpty else {
            return (false, "Please, select chat room name.", nameField)
        }
        
        guard let address = addressField.text, !address.isEmpty else {
            return (false, "Please, select chat room place.", addressField)
        }
        
        return (true, "", UIView())
    }
    
    
    @IBAction func editImageButtonPressed(_ sender: UIButton) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        
        let cameraAction = UIAlertAction(title: "Take a Photo", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in self.openCamera(sender) })
        
        
        let cameraRollAction = UIAlertAction(title: "Camera Roll", style: .default, handler: { (handler) in
            
            self.openPhotoLibraryButton(self)
        })
        
        let webImages = UIAlertAction(title: "Web Images", style: .default) { (handler) in
            //web images handler
            
            let webImagesVC = WebImagesController.create()
            webImagesVC.delegate = self

            let webImagesNav = UINavigationController(rootViewController: webImagesVC)
            
            self.showModal(webImagesNav)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(cameraAction)
        alert.addAction(cameraRollAction)
        alert.addAction(webImages)
        alert.addAction(cancel)
        
        alert.view.tintColor = Apperance.appBlueColor
        self.present(alert, animated: true, completion: nil)
        alert.view.tintColor = Apperance.appBlueColor
    }
    
    func deleteChatRoom(){
        let alert = UIAlertController(title: "Alert", message: "Are you sure you want to delete this chat group?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
            
            
            ChatRoomAPI.deleteRoom(with: self.chatRoom.id) { (success, error) in
                
                if success {
                    
                    self.delegate.didDelete(chatRoom: self.chatRoom)
                    self.hideModal()
                }else {
                    if let error = error {
                        Helper.show(alert: error.message)
                    }
                }
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: {(action) in }))
        
        if let wPPC = alert.popoverPresentationController {
            let barButtonItem = self.navigationItem.rightBarButtonItem!
            let buttonItemView = barButtonItem.value(forKey: "view")
            wPPC.sourceView = buttonItemView as? UIView
            wPPC.sourceRect = (buttonItemView as AnyObject).bounds
        }
        alert.view.tintColor = Apperance.appBlueColor
        self.present(alert, animated: true, completion: nil)
        alert.view.tintColor = Apperance.appBlueColor
    }
    
    
    
    func firstDistanceAppearance() {
        //Appearance Layer
        EditChatController.selectedDistanceAppearance(title: firstDistanceLabel, distanceView: firstDistanceView)
        EditChatController.defaultDistanceAppearance(title: secondDistanceLabel, distanceView: secondDistanceView)
        EditChatController.defaultDistanceAppearance(title: thirdDistanceLabel, distanceView: thirdDistanceView)
        
    }
    
    func secondDistanceAppearance() {
        //Appearance Layer
        EditChatController.selectedDistanceAppearance(title: secondDistanceLabel, distanceView: secondDistanceView)
        EditChatController.defaultDistanceAppearance(title: firstDistanceLabel, distanceView: firstDistanceView)
        EditChatController.defaultDistanceAppearance(title: thirdDistanceLabel, distanceView: thirdDistanceView)
    }
    
    func thirdDistanceAppearance() {
        
        //Appearance Layer
        EditChatController.selectedDistanceAppearance(title: thirdDistanceLabel, distanceView: thirdDistanceView)
        EditChatController.defaultDistanceAppearance(title: secondDistanceLabel, distanceView: secondDistanceView)
        EditChatController.defaultDistanceAppearance(title: firstDistanceLabel, distanceView: firstDistanceView)
    }
    
    
    @IBAction func firstDistanceButtonPressed(_ sender: UIButton) {
        
        firstDistanceAppearance()
        
        if let firstDistance = firstDistanceLabel.text {
            proximity = Double(firstDistance.trim)
        }
        
    }
    
    @IBAction func secondDistanceButtonPressed(_ sender: UIButton) {
        
        secondDistanceAppearance()
        
        if let secondDistance = secondDistanceLabel.text {
            proximity = Double(secondDistance.trim)
        }
    }
    
    @IBAction func thirdDistanceButtonPressed(_ sender: UIButton) {
        
        thirdDistanceAppearance()
        
        if let thirdDistance = thirdDistanceLabel.text {
            proximity = Double(thirdDistance.trim)
        }
    }
    
    
    static func selectedDistanceAppearance(title: UILabel, distanceView: UIView) {
        
        title.textColor = Apperance.appBlueColor
        distanceView.layer.borderColor = Apperance.appBlueColor.cgColor
        distanceView.backgroundColor = Apperance.appBlueColor
        
    }
    
    static func defaultDistanceAppearance(title: UILabel, distanceView: UIView) {
        
        title.textColor = UIColor(red255: 92, green255: 89, blue255: 92)
        distanceView.layer.borderColor = UIColor(red255: 198, green255: 195, blue255: 198).cgColor
        distanceView.backgroundColor = UIColor.white
        
    }
    
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        deleteChatRoom()
    }
    
    
    @IBAction func cancelBarButtonPressed(_ sender: UIBarButtonItem) {
        self.hideModal()
        
    }
    @IBAction func doneBarButtonPressed(_ sender: UIBarButtonItem) {
        updateChatRoom()
    }
    
    
    @IBAction func addressButtonPressed(_ sender: UIButton) {
        let autoCompleteVC = GMSAutocompleteViewController()
        autoCompleteVC.delegate = self
        
        self.present(autoCompleteVC, animated: true, completion: nil)
    }
    
    
    //Camera Function
    func openCamera(_ sender: AnyObject) {
        
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            self.editImageView.image = image
            
            self.editImageView.contentMode = .scaleAspectFill
            let resize = image.resizePostImage()
            let media = Media.create(for: resize)
            
            self.imageMedia = media
            self.bingImage = nil
        }
        
        picker.dismiss(animated: true, completion: {
        })
    }
    
}

extension EditChatController {
    
    static func create() -> EditChatController {
        return UIStoryboard.explore.instantiateViewController(withIdentifier: "EditChatController") as! EditChatController
    }
}

extension EditChatController: WebImageDelegate{
    func webImageChosen(image: BingImage) {
        self.bingImage = image
        self.imageMedia = nil
        self.editImageView.kf.setImage(with: image.getImageUrl())
    }
}

extension EditChatController : GMSAutocompleteViewControllerDelegate {
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("error: \(error)")
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        addressField.text = place.name
        addressCoordinate = place.coordinate
        
        self.dismiss(animated: true)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true)
    }
    
}

extension EditChatController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func openPhotoLibraryButton(_ sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
 
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
}



