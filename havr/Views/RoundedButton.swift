//
//  RoundedButton.swift
//  havr
//
//  Created by Alexandr Lobanov on 12/4/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {
    override var bounds: CGRect {
        get {
            return super.bounds
        }
        set {
            super.bounds = newValue
            setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width / 2.0
        clipsToBounds = false
    }
}
