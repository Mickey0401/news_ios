//
//  RoundedImageView.swift
//  havr
//
//  Created by Alexandr Lobanov on 12/1/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

class RoundedImageView: UIImageView {
    
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
        clipsToBounds = true


    }
}

class RoundedInnerBorderImageView: UIImageView {
    
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
        let borderWidth = 2.0
        frame = frame.insetBy(dx: CGFloat(-borderWidth), dy: CGFloat(-borderWidth))
        layer.borderColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
        layer.borderWidth = 1
        layer.cornerRadius = bounds.width / 2.0
        clipsToBounds = true
    }
}

