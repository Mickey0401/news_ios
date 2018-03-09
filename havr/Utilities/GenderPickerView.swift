//
//  GenderPickerView.swift
//  havr
//
//  Created by Personal on 5/30/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

class GenderPickerView: UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var items = ["Not specified", "Male","Female"]
    
    var selectedValue: String? {
        didSet {
            if let value = selectedValue, let index = items.index(of: value) {
                self.selectRow(index, inComponent: 0, animated: false)
            }
        }
    }
    
    var selectedValueChanged: ((GenderPickerView) -> Void)? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup() {
        self.delegate = self
        self.dataSource = self
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return items[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedValue = items[row]
        selectedValueChanged?(self)
    }
}
