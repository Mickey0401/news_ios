//
//  CornerSpecView.swift
//  havr
//
//  Created by CloudStream on 2/22/18.
//  Copyright © 2018 Tenton LLC. All rights reserved.
//

import Foundation
import UIKit
open class CornerSpecView :UIView {
    var corners :UIRectCorner = UIRectCorner.allCorners {
        didSet {
            setupCorners()
        }
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        setupCorners()
    }
    
    func setupCorners() {
        self.cornerRadius = 0.0
        let maskPath: UIBezierPath = UIBezierPath.init(roundedRect: CGRect.init(x: 0.0, y: 0.0, width: self.frame.size.width, height: self.frame.size.height), byRoundingCorners: corners , cornerRadii: CGSize.init(width: 15.0, height: 15.0))
        let maskLayer = CAShapeLayer.init()
        maskLayer.frame = CGRect.init(x: 0.0, y: 0.0, width: self.bounds.size.width, height: self.bounds.size.height)
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
}
