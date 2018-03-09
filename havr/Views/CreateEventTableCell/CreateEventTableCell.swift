//
//  CreateEventTableCell.swift
//  havr
//
//  Created by Agon Miftari on 6/27/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

class CreateEventTableCell: UITableViewCell {
    
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateTextFied: UITextField!

    var startDateChanged: ((Date) -> Void)? = nil
    var endDateChanged: ((Date) -> Void)? = nil
    
    var startDate: Date? {
        didSet {
            startDateTextField.text = startDate?.toString
            if let startDate = startDate {
                startDateChanged?(startDate)
            }
        }
    }
    var endDate: Date? {
        didSet {
            endDateTextFied.text = endDate?.toString
            if let endDate = endDate {
                endDateChanged?(endDate)
            }
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

    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    func setup(){
        
        startDateTextField.inputView = dateTimePicker
        endDateTextFied.inputView = dateTimePicker
        
        startDateTextField.inputAccessoryView = toolbarPicker
        endDateTextFied.inputAccessoryView = toolbarPicker
        
        startDateTextField.delegate = self
        endDateTextFied.delegate = self
        
        dateTimePicker.addTarget(self, action: #selector(datePickerValueChanged), for: UIControlEvents.valueChanged)
    }
    
    
    func datePickerValueChanged(picker: UIDatePicker) {
        if startDateTextField.isFirstResponder {
            startDate = picker.date
        } else if endDateTextFied.isFirstResponder {
            endDate = picker.date
        }
    }
    
    
    func nextButtonClicked(nextButton: UIBarButtonItem) {
        startDateTextField.resignFirstResponder()
        endDateTextFied.resignFirstResponder()
    }
    
}

extension CreateEventTableCell: UITextFieldDelegate {
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

extension UITableView {
    func dequeueCreateEventTableCell(index: IndexPath) -> CreateEventTableCell {
        return self.dequeueReusableCell(withIdentifier: "CreateEventTableCell", for: index) as! CreateEventTableCell
    }
    
    func registerCreateEventTableCell() {
        let nib = UINib(nibName: "CreateEventTableCell", bundle: nil)
        self.register(nib, forCellReuseIdentifier: "CreateEventTableCell")
    }
}
