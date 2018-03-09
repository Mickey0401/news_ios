//
//  GradientUIView.swift
//  Bopazar
//
//  Created by Lindi on 8/30/16.
//  Copyright © 2016 Tenton. All rights reserved.
//

import UIKit

@IBDesignable

class GradientUIView: UIView {
    
    fileprivate let gradientLayer = CAGradientLayer()
    
    @IBInspectable var color1: UIColor = UIColor.init(red: 242/255, green: 78/122, blue: 122/255, alpha: 1) { didSet { updateColors() } }
    @IBInspectable var color2: UIColor = UIColor.init(red: 254/255, green: 200/255, blue: 98/255, alpha: 1)  { didSet { updateColors() } }
    
    @IBInspectable var gradientOrientation : Bool = true {
        didSet {
            configureGradient()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureGradient()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureGradient()
    }
    
    func configureGradient() {
        
        if(gradientOrientation)
        {
            gradientLayer.startPoint = CGPoint(x: 0, y: 1)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        }
        else{
            gradientLayer.startPoint = CGPoint(x:1, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        }
        
        updateColors()
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = bounds
    }
    
    fileprivate func updateColors() {
        gradientLayer.colors = [color1.cgColor, color2.cgColor]
    }

}
