//
//  CreateEventView.swift
//  havr
//
//  Created by Agon Miftari on 5/2/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

class CreateEventView: UIView {

    var view : UIView!
    @IBOutlet weak var chatRoomButton: UIButton!
    
    @IBOutlet weak var eventButton: UIButton!
    
    var isEventHidden = false
    
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var timeField: UITextField!
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    
    
    var cameraButtonPressed: ((_ sender: UIButton) -> Void)? = nil
    var cancelButtonPressed: (() -> Void)? = nil
    var shouldLayoutSubviews: (() -> Void)? = nil
    var createButtonPressed: (() -> Void)? = nil
    var addressButtonPressed: (() -> Void)? = nil
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
       setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup(){
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        
        dateField.inputView = datePicker
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: UIControlEvents.valueChanged)

        
        let timePicker = UIDatePicker()
        timePicker.datePickerMode = .time
        datePicker.maximumDate = Date()
        
        timeField.inputView = timePicker
        timePicker.addTarget(self, action: #selector(timePickerValueChanged), for: UIControlEvents.valueChanged)
        
        addSubview(view)
    }
    
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        return UINib(nibName: "CreateEventView", bundle: bundle).instantiate(withOwner: self, options: nil)[0] as! UIView
    }
    
    func datePickerValueChanged(picker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateField.text = dateFormatter.string(from: picker.date)
    }
    
    func timePickerValueChanged(picker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        timeField.text = dateFormatter.string(from: picker.date)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.cancelButtonPressed?()
    }
    
    @IBAction func createButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func chatRoomButtonPressed(_ sender: UIButton) {
        isEventHidden = true
        
        self.shouldLayoutSubviews?()
        
    }

    @IBAction func eventButtonPressed(_ sender: UIButton) {
        isEventHidden = false
        self.shouldLayoutSubviews?()
    }
    
    @IBAction func cameraButtonPressed(_ sender: UIButton) {
        self.cameraButtonPressed?(sender)
        
    }
    @IBAction func addressButtonPressed(_ sender: UIButton) {
        
        self.addressButtonPressed?()
    }
}
