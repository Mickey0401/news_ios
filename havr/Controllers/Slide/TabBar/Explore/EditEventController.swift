//
//  EditEventController.swift
//  havr
//
//  Created by Agon Miftari on 5/3/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import GooglePlaces

class EditEventController: UIViewController {
    
    //MARK: - OUTLETS
    @IBOutlet weak var editImageButton: RoundedButton!
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var editImageView: RoundedImageView!
    @IBOutlet weak var addressField: UITextField!
    
    @IBOutlet weak var dateField: UITextField!
    
    @IBOutlet weak var timeField: UITextField!
    @IBOutlet weak var addressIconButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var timeButton: UIButton!
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    //MARK: - VARIABLES
    var event: Event!
    
    var addressCoordinate: CLLocationCoordinate2D?
    var imageMedia : Media?
    var bingImage: BingImage?
    var startDate: Date! {
        didSet {
            dateField.text = startDate.toString
        }
    }
    var endDate: Date! {
        didSet {
            timeField.text = endDate.toString
        }
    }
    
    lazy var dateTimePicker: UIDatePicker = {
        let p = UIDatePicker(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 220))
        p.datePickerMode = .dateAndTime
        return p
    }()
    
    lazy var toolbarPicker: UIToolbar = {
        let t = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        let nextItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(nextButtonClicked))
        t.items = [ UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil), nextItem]
        return t
    }()
    
    //MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
        fetchEvent()
    }
    
    func commonInit(){
        dateTimePicker.addTarget(self, action: #selector(datePickerValueChanged), for: UIControlEvents.valueChanged)
        
        dateField.inputAccessoryView = toolbarPicker
        timeField.inputAccessoryView = toolbarPicker
        
        dateField.inputView = dateTimePicker
        timeField.inputView = dateTimePicker
        
        dateField.delegate = self
        timeField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.shared.statusBarStyle = .default
    }
    func datePickerValueChanged(picker: UIDatePicker) {
        if dateField.isFirstResponder {
            startDate = picker.date
        } else if timeField.isFirstResponder {
            endDate = picker.date
        }
    }
    
    //MARK: - ACTIONS
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
    
    @IBAction func addressIconButtonPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        deleteEvent()
    }
    
    @IBAction func dateButtonPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func timeButtonPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func addressButtonPressed(_ sender: UIButton) {
        let autoCompleteVC = GMSAutocompleteViewController()
        autoCompleteVC.delegate = self
        
        self.present(autoCompleteVC, animated: true, completion: nil)
    }
    
    @IBAction func doneBarButtonPressed(_ sender: UIBarButtonItem) {
//        guard let eventMedia = self.imageMedia else {
//            Helper.show(alert: "Please, select event image.")
//            return
//        }
        
        guard let eventName = nameField.text, !eventName.isEmpty else {
            Helper.show(alert: "Please, select event name.")
            
            return
        }
        guard let coordinate = addressCoordinate else {
            Helper.show(alert: "Please, select a event place.")
            return
        }
        
        guard let startDate = self.startDate else {
            Helper.show(alert: "Please, select start date.")
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
        
        guard let address = self.addressField.text else {
            return
        }
        
        let ev = Event()
        ev.id = self.event.id
        ev.name = eventName
        ev.latitude = coordinate.latitude
        ev.longitude = coordinate.longitude
        
        ev.dateTimeStart = startDate
        ev.dateTimeEnd = endDate
        ev.address = address
        ev.photo = self.event.photo
        let validation = validateInputs()
        
        if !validation.success {
            Helper.show(alert: validation.message)
            return
        }
        
        if let media = self.imageMedia{
            ev.photo = media.getAbsolute()
            if media.uploadStatus == .uploaded {
                self.updateEvent(event: ev)
            }else {
                media.upload(completion: { (media, status, error) in
                    if status {
                        self.updateEvent(event: ev)
                    }
                    
                    if let error = error {
                        self.hideHud()
                        Helper.show(alert: error)
                    }
                })
            }

        }else if let bingImage = self.bingImage{
            ev.photo = bingImage.path
            self.updateEvent(event: ev)
        }else{
            self.updateEvent(event: ev)
        }
    }
    
    func updateEvent(event: Event){
        self.showHud()
        EventAPI.update(event: event, completion: { (updatedEvent, error) in
            self.hideHud()
            if let event = updatedEvent {
                ExploreModelView.shared.updateEvent(event: event)
                
                self.hideModal()
            }else {
                if let error = error {
                    Helper.show(alert: error.message)
                }
            }
        })
    }
    @IBAction func cancelBarButtonPressed(_ sender: UIBarButtonItem) {
        self.hideModal()
    }
    
    //MARK: - Functions
    func nextButtonClicked(nextButton: UIBarButtonItem) {
        dateField.resignFirstResponder()
        timeField.resignFirstResponder()
    }
    
    func fetchEvent() {
        if let event = event {
            nameField.text = event.name
            addressField.text = event.address
            if let image = event.getImageUrl() {
                editImageView.kf.setImage(with: image, placeholder: Constants.cameraBackground)
            }else {
                editImageView.image = Constants.cameraBackground
            }
            
            startDate = event.dateTimeStart
            endDate = event.dateTimeEnd
            
            dateField.text = event.dateTimeStart.toString
            timeField.text = event.dateTimeEnd.toString
//            imageMedia = event.media
            
            addressCoordinate = event.location?.coordinate
        }
    }
    
    
    func validateInputs() -> (success: Success, message: ErrorMessage) {

        
        guard let eventName = nameField.text, !eventName.isEmpty else {
            return (false, "Please, select event name.")
        }
        
        if addressCoordinate == nil {
            return (false, "Please, select a event place.")
        }
        
        guard let startDate = self.startDate else {
            return (false, "Please, select start date.")
        }
        
        guard let endDate = self.endDate else {
            return (false, "Please, select end date.")
        }
        
        if endDate.timeIntervalSince1970 < startDate.timeIntervalSince1970 {
            return (false, "End date must be greater than start date.")
        }
        
        return (true, "")
    }
    
    //Camera Function
    func openCamera(_ sender: AnyObject) {
        
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
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
    
    func deleteEvent(){
        let alert = UIAlertController(title: "Alert", message: "Are you sure you want to delete this event?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
            //Delete Event API
            
            EventAPI.delete(event: self.event, completion: { (success, error) in
                if success {
                    self.hideModal()
                }else {
                    if let error = error {
                        Helper.show(alert: error.message)
                    }
                }
            })
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
}


//MARK: TextField Delegate
extension EditEventController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == dateField {
            dateTimePicker.date = startDate ?? Date()
        } else if textField == timeField {
            if let startDate = startDate {
                dateTimePicker.minimumDate = startDate
                dateTimePicker.date = endDate ?? Date()
            }
        }
        
        return true
    }
}

extension EditEventController: WebImageDelegate{
    func webImageChosen(image: BingImage) {
        self.bingImage = image
        self.imageMedia = nil
        self.editImageView.kf.setImage(with: image.getImageUrl())
    }
}

extension EditEventController {
    static func create() -> EditEventController {
        return UIStoryboard.explore.instantiateViewController(withIdentifier: "EditEventController") as! EditEventController
    }
}

extension EditEventController : GMSAutocompleteViewControllerDelegate {
    
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

extension EditEventController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
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
