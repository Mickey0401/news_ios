//
//  AgePickerView.swift
//  havr
//
//  Created by Personal on 5/30/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

class AgePickerView: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    var startAge = 13
    var endAge = 99
    
    var selectedValue: Int? {
        didSet {
            if let value = selectedValue, value != 0, value >= 13, value <= 99 {
                self.selectRow(value - startAge, inComponent: 0, animated: false)
            }
        }
    }
    
    var selectedValueChanged: ((AgePickerView) -> Void)? = nil
    
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
        return endAge - startAge
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return (startAge + row).description
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedValue = startAge + row
        selectedValueChanged?(self)
    }
}
