//
//  BorderedButton.swift
//  havr
//
//  Created by Alexandr Lobanov on 12/4/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

enum ButtonStyle {
    case facebook
    case borderred(cornerRadius: CGFloat, title: String)
    case custom(title: String, cornerRadius: CGFloat, color: UIColor)
    case standart(title: String)
    
    var cornerRadius: CGFloat {
        switch self {
        case .facebook:
            return 20
        case .borderred(cornerRadius: let radius, title: _):
            return radius
        case .custom(title: _, cornerRadius: let radius, color: _):
            return radius
        case .standart:
            return 0
        }
    }
    
    var color: UIColor {
        switch self {
        case .facebook:
            return  UIColor.facebookButton
        case .standart, .borderred:
            return UIColor.clear
        case .custom(title: _, cornerRadius: _, color: let color):
            return color
        }
    }
    
    var title: String {
        switch self {
        case .facebook:
            return "Log in with Facebook"
        case .borderred(cornerRadius: _, title: let title):
            return title
        case .custom(title: let title, cornerRadius: _, color: _):
            return title
        case .standart(title: let title):
            return title
        }
    }
}

class BorderedButton: UIButton {
    
    var style: ButtonStyle?

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
        layer.cornerRadius = 3.0
        layer.borderWidth = 1.5
        layer.borderColor = UIColor.lightGrayBorder.cgColor
        clipsToBounds = true
    }
    
    func disable() {
        isEnabled = false
        isHidden = true
        alpha = 0
    }
    
    func enable() {
        isEnabled = true
        isHidden = false
        alpha = 1
    }
}
