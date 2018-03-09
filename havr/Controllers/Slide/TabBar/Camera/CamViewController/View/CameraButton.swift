//
//  CameraButton.swift
//  havr
//
//  Created by Yuriy G. on 1/23/18.
//  Copyright © 2018 Tenton LLC. All rights reserved.
//
import UIKit

class CameraButton: CamButton {
    
    private var circleBorder: CALayer!
    private var innerCircle: UIView!
    private var circle: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        drawButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        drawButton()   
    }

    public func tap() {
        self.Tap()
    }

    private func drawButton() {
        self.backgroundColor = UIColor.clear
        
        circleBorder = CALayer()
        circleBorder.backgroundColor = UIColor.clear.cgColor
        circleBorder.borderWidth = 3.0
        circleBorder.bounds = self.bounds
        circleBorder.position = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        circleBorder.cornerRadius = self.frame.size.width / 2
        layer.insertSublayer(circleBorder, at: 0)

        circle = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width - 10, height: self.bounds.size.height - 10))
        circle.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        circle.layer.cornerRadius = circle.frame.size.width / 2
        circle.clipsToBounds = true
        self.addSubview(circle)
        
        setButtonColor()
    }
    
    public func setButtonColor(_ isDark: Bool = false) {
        circleBorder.borderColor = isDark ? UIColor.white.cgColor : Color.purpleColor.cgColor
        circle.backgroundColor = isDark ? UIColor.white : Color.darkBlueColor
    }
    
    public  func growButton() {
        circle.alpha = 0
        
        innerCircle = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        innerCircle.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        innerCircle.backgroundColor = UIColor.red
        innerCircle.layer.cornerRadius = innerCircle.frame.size.width / 2
        innerCircle.clipsToBounds = true
        self.addSubview(innerCircle)
        
        UIView.animate(withDuration: 0.6, delay: 0.0, options: .curveEaseOut, animations: {
            self.innerCircle.transform = CGAffineTransform(scaleX: 62.4, y: 62.4)
            self.circleBorder.setAffineTransform(CGAffineTransform(scaleX: 1.352, y: 1.352))
            self.circleBorder.borderWidth = (4 / 1.352)

        }, completion: nil)
    }
    
    public func shrinkButton() {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
            self.innerCircle.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.circleBorder.setAffineTransform(CGAffineTransform(scaleX: 1.0, y: 1.0))
            self.circleBorder.borderWidth = 4.0
        }, completion: { (success) in
            self.innerCircle.removeFromSuperview()
            self.innerCircle = nil
            self.circle.alpha = 1.0
        })
    }
}
