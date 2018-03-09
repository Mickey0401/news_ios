//
//  TimeLabelBgView.swift
//  havr
//
//  Created by Yevhenii Lytvinenko on 1/23/18.
//  Copyright © 2018 Tenton LLC. All rights reserved.
//

import UIKit

@IBDesignable
class TimeLabelBgView: UIView {
    
    //MARK: Overriding
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateUI()
    }
    
    //MARK: UI config
    
    func updateUI() {
        backgroundColor = UIColor.white.withAlphaComponent(0.3)
        layer.cornerRadius = frame.height / 2.0
    }
}
