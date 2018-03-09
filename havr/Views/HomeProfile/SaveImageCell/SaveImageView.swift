//
//  SaveImageView.swift
//  havr
//
//  Created by Ismajl Marevci on 8/15/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
protocol SaveImageViewDelegate : class {
    func saveImageView(sender: SaveImageView, didPressSaveButton button: UIButton)
}

class SaveImageView: UICollectionReusableView {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var saveLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    
    weak var delegate: SaveImageViewDelegate? = nil

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        self.delegate?.saveImageView(sender: self, didPressSaveButton: sender)
    }
}
