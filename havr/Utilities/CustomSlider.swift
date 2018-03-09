//
//  CustomSlider.swift
//  havr
//
//  Created by Ismajl Marevci on 10/2/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//
import UIKit
public class CustomSlider: UISlider {
    
    var label: UILabel
    var labelXMin: CGFloat?
    var labelXMax: CGFloat?
    var labelText: ()->String = { "" }
    
    required public init?(coder aDecoder: NSCoder) {
        label = UILabel()
        super.init(coder: aDecoder)
        self.addTarget(self, action:  #selector(onValueChanged), for: UIControlEvents())
    }
    
    func setup(){
        labelXMin = frame.origin.x + 16
        labelXMax = frame.origin.x + self.frame.width - 14
        let labelXOffset: CGFloat = labelXMax! - labelXMin!
        let valueOffset: CGFloat = CGFloat(self.maximumValue - self.minimumValue)
        let valueDifference: CGFloat = CGFloat(self.value - self.minimumValue)
        let valueRatio: CGFloat = CGFloat(valueDifference/valueOffset)
        let labelXPos = CGFloat(labelXOffset*valueRatio + labelXMin!)
        label.frame = CGRect(x: labelXPos, y: self.frame.origin.y - 25, width: 200, height: 25)
        label.text = "\(Int(self.value))"
        self.superview!.addSubview(label)
        
    }
    func updateLabel(){
        label.text = labelText()
        let labelXOffset: CGFloat = labelXMax! - labelXMin!
        let valueOffset: CGFloat = CGFloat(self.maximumValue - self.minimumValue)
        let valueDifference: CGFloat = CGFloat(self.value - self.minimumValue)
        let valueRatio: CGFloat = CGFloat(valueDifference/valueOffset)
        let labelXPos = CGFloat(labelXOffset*valueRatio + labelXMin!)
        label.frame = CGRect(x: labelXPos - label.frame.width / 2, y: self.frame.origin.y - 25, width: 200, height: 25)
        label.textAlignment = .center
        label.textColor = UIColor.black
        label.font = UIFont.robotoRegularFont(15)
        self.superview!.addSubview(label)
    }
    public override func layoutSubviews() {
        labelText = { "\(Int(self.value))" }
        setup()
        updateLabel()
        super.layoutSubviews()
        super.layoutSubviews()
    }
    func onValueChanged(sender: CustomSlider){
        updateLabel()
    }
}
