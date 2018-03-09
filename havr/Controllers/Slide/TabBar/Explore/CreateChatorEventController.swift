//
//  CreateChatorEventController.swift
//  havr
//
//  Created by Ismajl Marevci on 4/29/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import GooglePlaces
import TPKeyboardAvoiding
import MBProgressHUD
import Photos

class CreateChatorEventController: UIViewController {
    
    @IBOutlet weak var tableView: TPKeyboardAvoidingTableView!
    @IBOutlet weak var imageView: RoundedImageView!
    
    @IBOutlet weak var cameraButton: RoundedButton!
    @IBOutlet weak var createChatOrEventLabel: UILabel!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateTextFied: UITextField!
    @IBOutlet weak var ivCameraSmall: UIImageView!
    
    //MARK: - VARIABLES
    var imageMedia: Media?
    var bingImage: BingImage?
    
    var isEvent = true
    var isCameraController = false
    var isStartDatePicker = false
    var chatProximity : Double?
    var addressCoordinate: CLLocationCoordinate2D?
    var userLocation : CLLocation?
    
    var startDate: Date? {
        didSet {
            startDateTextField.text = startDate?.toString
        }
    }
    var endDate: Date? {
        didSet {
            endDateTextFied.text = endDate?.toString
        }
    }
    
    
    lazy var photoLibraryPermission : AllowPermissionView = {
        let pL = AllowPermissionView.createForPhotoLibrary()
        return pL
    }()
    
    lazy var dateTimePicker: UIDatePicker = {
        let p = UIDatePicker(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 220))
        p.datePickerMode = .dateAndTime
        return p
    }()
    
    lazy var toolbarPicker: UIToolbar = {
        let t = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        let nextItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(pickerNextButtonClicked))
        t.items = [ UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil), nextItem]
        return t
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerCreateChatTableCell()
        tableView.registerCreateEventTableCell()
        tableView.reloadData()
        
        photoLibraryPermission.permissionButtonPressed = permissionButtonPressed
        photoLibraryPermission.laterButtonPressed = laterButtonPressed
        
        startDateTextField.inputView = dateTimePicker
        endDateTextFied.inputView = dateTimePicker
        
        startDateTextField.inputAccessoryView = toolbarPicker
        endDateTextFied.inputAccessoryView = toolbarPicker
        
        startDateTextField.delegate = self
        endDateTextFied.delegate = self
        
        dateTimePicker.addTarget(self, action: #selector(datePickerValueChanged), for: UIControlEvents.valueChanged)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GA.TrackScreen(name: "Create Event or Chatroom")

        UIApplication.shared.statusBarStyle = .default
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        self.view.layoutIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @IBAction func rightBarButtonPressed(_ sender: UIBarButtonItem) {
        
        let exploreListVC = ExploreListController.create()
        
        let transition = CATransition()
        transition.duration = 0.4
        transition.type = "flip"
        transition.subtype = kCATransitionFromLeft
        self.navigationController?.view.layer.add(transition, forKey: kCATransition)
        self.navigationController?.pushViewController(exploreListVC, animated: false)
    }
    
    @IBAction func cameraButtonPressed(_ sender: UIButton) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        
        let cameraAction = UIAlertAction(title: "Take a Photo", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in self.openCamera(sender) })
        
        
        let cameraRollAction = UIAlertAction(title: "Camera Roll", style: .default, handler: { (handler) in
            
            self.checkPhotoLibraryPermission()
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
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.pop()
    }
    
    @IBAction func createButtonPressed(_ sender: UIButton) {

        //EventCreate
        if isEvent {
            createEvent()
        }
        else {
            createChatRoom()
        }
    }
    
    @IBAction func addressButtonPressed(_ sender: UIButton) {
        let autoCompleteVC = GMSAutocompleteViewController()
        autoCompleteVC.delegate = self
        
        self.present(autoCompleteVC, animated: true, completion: nil)
    }
    
    @IBAction func userLocationButtonPressed(_ sender: UIButton) {
        if let userCoordinate = userLocation?.coordinate {
            addressField.text = String(describing: userCoordinate)
        }
    }
    
    //MARK: - FUNCTIONS
    
    func createEvent() {
        
        if self.imageMedia == nil && self.bingImage == nil {
            Helper.show(alert: "Please, select event image.")
            return
        }
        
        guard let eventName = nameField.text, !eventName.isEmpty else {
            Helper.show(alert: "Please, select event name.")
            
            return
        }
        guard let coordinate = addressCoordinate else {
            Helper.show(alert: "Please, select an event place.")
            return
        }
        
        guard let startDate = self.startDate else {
            Helper.show(alert: "Please, select start date.")
            return
        }
        
        
        if startDate.timeIntervalSince1970 < Date().timeIntervalSince1970 {
            Helper.show(alert: "Start date must be greater than now.")
            return
        }
        
        guard let endDate = self.endDate else {
            Helper.show(alert: "Please, select end date.")
            return
        }
        
        if endDate.timeIntervalSince1970 < startDate.timeIntervalSince1970 {
            Helper.show(alert: "End date must be greater than start date.")
            return
        }
        
        guard let address = self.addressField.text, !address.isEmpty else {
            Helper.show(alert: "Please, select an event place.")
            return
        }
        
        
        let event = Event()
        event.name = eventName
        event.latitude = coordinate.latitude
        event.longitude = coordinate.longitude
        
        event.dateTimeStart = startDate
        event.dateTimeEnd = endDate
        event.address = address
        
        let validation = validateEventInputs()
        
        if !validation.success {
            Helper.show(alert: validation.message)
            return
        }
        
        if let eventMedia = self.imageMedia{
            event.photo = imageMedia?.getAbsolute() ?? ""

            self.showHud()
            if eventMedia.uploadStatus == .uploaded {
                createEvent(event: event)
                
            }else {
                eventMedia.upload(completion: { (media, status, error) in
                    if status {
                        self.createEvent(event: event)
                    }
                    if let error = error {
                        self.hideHud()
                        Helper.show(alert: error)
                    }
                })
                self.hideHud()

            }
        }else if let bingMedia = self.bingImage{
            self.showHud()
            event.photo = bingMedia.path
            createEvent(event: event)
        }
    }
    
    func createEvent(event: Event){
        EventAPI.create(event: event, completion: { (createdEvent, error) in
            self.hideHud()
            if let event = createdEvent {
                ExploreModelView.shared.addEvent(event: event)
                self.pop()
            }else {
                if let error = error {
                    Helper.show(alert: error.message)
                }
            }
        })
    }
    
    func createChatRoom() {
        
        if self.imageMedia == nil && self.bingImage == nil {
            Helper.show(alert: "Please, select chat room image.")
            return
        }
        
        guard let chatName = nameField.text, !chatName.isEmpty else {
            Helper.show(alert: "Please, select chat room name.")
            return
        }
        
        guard let coordinate = addressCoordinate else {
            Helper.show(alert: "Please, select chat room place.")
            return
        }
        
        guard let address = addressField.text, !address.isEmpty else {
            Helper.show(alert: "Please, select chat room place.")
            return
        }
        
        guard let proximity = chatProximity  else {
            Helper.show(alert: "Please, select an proximity distance.")
            return }
        
        
        let chatRoom = ChatRoom()
        chatRoom.name = chatName
        chatRoom.proximity = proximity
        chatRoom.latitude = coordinate.latitude
        chatRoom.longitude = coordinate.longitude
        chatRoom.address = address
        
        let validation = validateChatRoomInputs()
        if !validation.success {
            Helper.show(alert: validation.message)
            return
        }
        self.showHud()
        if let eventMedia = self.imageMedia{
            chatRoom.photo = imageMedia?.getAbsolute() ?? ""
            
            if eventMedia.uploadStatus == .uploaded {
                createChatRoom(room: chatRoom)
            } else {
                eventMedia.upload(completion: { (media, status, error) in
                    if status {
                        self.createChatRoom(room: chatRoom)
                    }
                    if let error = error {
                        self.hideHud()
                        Helper.show(alert: error)
                    }
                })
                self.hideHud()

            }
        }else if let bingMedia = self.bingImage{
            self.showHud()
            chatRoom.photo = bingMedia.path
            self.createChatRoom(room: chatRoom)
        }
    }
    
    func createChatRoom(room: ChatRoom){
        ChatRoomAPI.createRoom(chatRoom: room, completion: { (createdChatRoom, error) in
            self.hideHud()
            
            if let chatRoom = createdChatRoom {
                ExploreModelView.shared.addChatRoom(chatroom: chatRoom)
                
                let exploreConversationVC = ExploreConversationController.create(chatRoom: chatRoom)
                exploreConversationVC.isCreationScreen = true
                let nav = UINavigationController.init(rootViewController: exploreConversationVC)
                delay(delay: 0.1, closure: {
                    self.showModal(nav, animated: true, completion: {
                        self.pop(false)
                    })
                })
            }
            if let error = error {
                Helper.show(alert: error.message)
            }
        })
    }
    
    
    func validateEventInputs() -> (success: Success, message: ErrorMessage) {
        
        if self.imageMedia == nil && self.bingImage == nil {
            return (false, "Please, select event image.")
        }
        
        guard let eventName = nameField.text, !eventName.isEmpty else {
            return (false, "Please, select event name.")
        }
        
        if addressCoordinate == nil {
            return (false, "Please, select a event place.")
        }
        
        guard let startDate = self.startDate else {
            return (false, "Please, select start date.")
        }
        
        if startDate.timeIntervalSince1970 < Date().timeIntervalSince1970 {
            return (false, "Start date must be greater than now.")
        }
        
        guard let endDate = self.endDate else {
            return (false, "Please, select end date.")
        }
        
        if endDate.timeIntervalSince1970 < startDate.timeIntervalSince1970 {
            return (false, "End date must be greater than start date.")
        }
        
        return (true, "")
    }
    
    func validateChatRoomInputs() -> (success: Success, message: ErrorMessage) {
        
        if self.imageMedia == nil && self.bingImage == nil {
            return (false, "Please, select chat room image.")
        }
        
        guard let eventName = nameField.text, !eventName.isEmpty else {
            return (false, "Please, select chat room name.")
        }
        
        if addressCoordinate == nil {
            return (false, "Please, select a chat room place.")
        }
        
        if chatProximity == nil {
            return (false, "Please, select an proximity distance.")
        }
        
        return (true, "")
        
    }
    
    func openCamera(_ sender: AnyObject) {
        
        isCameraController = true
        
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
            self.imageView.image = image
            self.bingImage = nil
            
            self.imageView.contentMode = .scaleAspectFill
            let resize = image.resizePostImage()
            let media = Media.create(for: resize)
            self.imageMedia = media
            self.ivCameraSmall.isHidden = true
        }
        picker.dismiss(animated: true, completion: {
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
            self.photoLibraryPermission.show(to: self.view)
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
                    self.photoLibraryPermission.show(to: self.view)
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
    
    func datePickerValueChanged(picker: UIDatePicker) {
        if startDateTextField.isFirstResponder {
            startDate = picker.date
        } else if endDateTextFied.isFirstResponder {
            endDate = picker.date
        }
    }
    
    func pickerNextButtonClicked(nextButton: UIBarButtonItem) {
        startDateTextField.resignFirstResponder()
        endDateTextFied.resignFirstResponder()
    }
    
}

//MARK: - EXTENSIONS

extension CreateChatorEventController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isEvent {
            let cell = tableView.dequeueCreateEventTableCell(index: indexPath)
            
            cell.startDateChanged = {[weak self] date in
                self?.startDate = date
            }
            
            cell.endDateChanged = {[weak self] date in
                self?.endDate = date
            }
            
            return cell
        }else {
            
            let cell = tableView.dequeueCreateChatTableCell(index: indexPath)
            
            cell.proximityChanged = { [weak self] value in
                self?.chatProximity = value
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}

extension CreateChatorEventController: WebImageDelegate{
    func webImageChosen(image: BingImage) {
        self.bingImage = image
        self.imageMedia = nil
        self.imageView.kf.setImage(with: image.getImageUrl())
    }
}

extension CreateChatorEventController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
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

extension CreateChatorEventController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == startDateTextField {
            dateTimePicker.minimumDate = Date()
            dateTimePicker.date = startDate ?? Date()
        } else if textField == endDateTextFied {
            if let startDate = startDate {
                dateTimePicker.minimumDate = startDate
                dateTimePicker.date = endDate ?? Date()
            }
        }
        
        return true
    }
}

extension CreateChatorEventController : GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("error: \(error)")
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        addressField.text = place.formattedAddress
        addressCoordinate = place.coordinate
        
        self.dismiss(animated: true)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true)
    }
}

extension CreateChatorEventController {
    static func create() -> CreateChatorEventController {
        return UIStoryboard.explore.instantiateViewController(withIdentifier: "CreateChatorEventController") as! CreateChatorEventController
    }
}
