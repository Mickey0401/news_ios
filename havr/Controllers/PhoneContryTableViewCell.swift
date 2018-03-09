//
//  PhoneContryTableViewCell.swift
//  havr
//
//  Created by Alexandr Lobanov on 12/26/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

class PhoneContryTableViewCell: UITableViewCell {

    @IBOutlet weak var phoneCodeLabel: UILabel!
    @IBOutlet weak var contryNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updatWith(model: CountryPhone) {
        phoneCodeLabel.text = model.dialCode
        contryNameLabel.text = model.name
    }

}
