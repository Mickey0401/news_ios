//
//  GZRangeSlider.swift
//  RangeSlider
//
//  Created by zzh on 16/1/3.
//  Copyright © 2016年 Gavin Zeng. All rights reserved.
//

import Foundation
import UIKit

class GZRangeSlider: UIControl{
    fileprivate var leftHandleLayer: CALayer!
    fileprivate var rightHandleLayer: CALayer!
    fileprivate var normalbackImageView: UIImageView!
    fileprivate var highlightedImageView: UIImageView!
    fileprivate var leftTextLayer: CATextLayer!
    fileprivate var rightTextLayer: CATextLayer!
    
    fileprivate var barHeight: CGFloat = 3
    fileprivate var barWidth: CGFloat = 0
    fileprivate var handleWidth: CGFloat = 30
    fileprivate var handleHeight: CGFloat = 30
    
    fileprivate var insideMax: Int = 1000
    fileprivate var insideMin: Int = 0
    fileprivate var leftValue: Int = 0
    fileprivate var rightValue: Int = 0
    fileprivate var insideAccuracy: Int = 1
    
    fileprivate var previouslocation = CGPoint.zero
    
    fileprivate var isLeftSelected = false
    fileprivate var isRightSelected = false
    
    var valueChangeClosure: ((_ minValue: Int, _ maxValue: Int) -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setInitValue()
        
        barWidth = frame.width - 2 * handleWidth
        normalbackImageView = UIImageView()
        normalbackImageView.layer.cornerRadius = 4
        normalbackImageView.backgroundColor = UIColor(red255: 145, green255: 167, blue255: 189).withAlphaComponent(0.2)
        normalbackImageView.frame = CGRect(x: handleWidth * 0.5,y: 0.5 * (frame.height - barHeight),width: frame.width - handleWidth,height: barHeight)
        addSubview(normalbackImageView)
        
        highlightedImageView = UIImageView()
        highlightedImageView.backgroundColor = UIColor(red255: 145, green255: 167, blue255: 189).withAlphaComponent(0.2)
        highlightedImageView.frame = CGRect(x: handleWidth * 0.5 ,y: 0.5 * (frame.height - barHeight),width: frame.width - handleWidth,height: barHeight)
        addSubview(highlightedImageView)
        
        leftHandleLayer = createHandleLayer()
        leftHandleLayer.frame = CGRect(x: 0, y: 0.5 * (frame.height - handleHeight), width: handleWidth, height: handleHeight)
        layer.addSublayer(leftHandleLayer)
        
        rightHandleLayer = createHandleLayer()
        rightHandleLayer.frame = CGRect(x: frame.width - handleWidth, y: leftHandleLayer.frame.minY, width: handleWidth, height: handleHeight)
        layer.addSublayer(rightHandleLayer)
        
        let kTextWidth: CGFloat = 50
        let kTextHeight: CGFloat = 20
        leftTextLayer = createTextLayer()
        leftTextLayer.string = "\(insideMin)"
        layer.addSublayer(leftTextLayer)
        leftTextLayer.frame = CGRect(x: leftHandleLayer.frame.minX - 0.5 * (kTextWidth - leftHandleLayer.frame.width), y: leftHandleLayer.frame.minY - kTextHeight, width: kTextWidth, height: kTextHeight)
        
        rightTextLayer = createTextLayer()
        rightTextLayer.string = "\(insideMax)"
        layer.addSublayer(rightTextLayer)
        rightTextLayer.frame = CGRect(x: rightHandleLayer.frame.minX - 0.5 * (kTextWidth - leftHandleLayer.frame.width), y: leftTextLayer.frame.minY, width: kTextWidth, height: kTextHeight)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: public method
    func setRange(_ minRange: Int, maxRange: Int, accuracy: Int){
        assert(maxRange >= minRange, "maxRange = \(maxRange) less than minRange = \(minRange)")
        insideMax = maxRange
        insideMin = minRange
        insideAccuracy = accuracy
        setInitValue()
        setLabelText()
    }
    
    func setCurrentValue(_ left: Int, right: Int){
        if left >= right{
            return
        }
        leftValue = max(insideMin,left)
        leftValue = min(insideMax,leftValue)
        
        rightValue = max(right,insideMin)
        rightValue = min(rightValue,insideMax)
        
        let range = insideMax - insideMin
        let leftX = CGFloat(leftValue - insideMin)/CGFloat(range)
        let rightX = CGFloat(rightValue - insideMin)/CGFloat(range)
        
        leftHandleLayer.frame = CGRect(x: leftX * barWidth, y: 0.5 * (frame.height - handleHeight), width: handleWidth, height: handleHeight)
        rightHandleLayer.frame = CGRect(x: rightX * barWidth + leftHandleLayer.frame.width, y: leftHandleLayer.frame.minY, width: handleWidth, height: handleHeight)
        
        setLabelText()
        updateHighlightedBar()
    }
    
    //MARK: private method
    fileprivate func setInitValue(){
        leftValue = insideMin
        rightValue = insideMax
    }
    
    fileprivate func updateHighlightedBar(){
        highlightedImageView.frame = CGRect(x: leftHandleLayer.frame.maxX - 0.5 * handleWidth,y: 0.5 * (frame.height - barHeight), width: rightHandleLayer.frame.minX - leftHandleLayer.frame.maxX + handleWidth,height: barHeight)
        setLabelText()
        valueChangeClosure?(leftValue/insideAccuracy * insideAccuracy,rightValue/insideAccuracy * insideAccuracy)
    }
    
    fileprivate func setLabelText(){
        leftTextLayer.string = "\(leftValue/insideAccuracy * insideAccuracy)"
        leftTextLayer.frame = CGRect(x: leftHandleLayer.frame.minX - 0.5 * (50 - leftHandleLayer.frame.width), y: leftHandleLayer.frame.minY - 20, width: 50, height: 20)

        
        
        rightTextLayer.string = "\(rightValue/insideAccuracy * insideAccuracy)"
        
        rightTextLayer.frame = CGRect(x: rightHandleLayer.frame.minX - 0.5 * (50 - leftHandleLayer.frame.width), y: leftTextLayer.frame.minY, width: 50, height: 20)

    }
    
    fileprivate func createHandleLayer() -> CALayer{
        let layer = CALayer()
        let gradientLayer = CAGradientLayer()
        let color1: UIColor = UIColor.init(red: 201/255, green: 206/255, blue: 212/255, alpha: 1)
        let color2: UIColor = UIColor.init(red: 230/255, green: 233/255, blue: 235/255, alpha: 1)
        gradientLayer.colors = [color1.cgColor, color2.cgColor]
        gradientLayer.endPoint = CGPoint(x:1, y: 0)
        gradientLayer.startPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        gradientLayer.cornerRadius = 15
        layer.insertSublayer(gradientLayer, at: 0)
        return layer
    }
    
    fileprivate func createTextLayer() -> CATextLayer{
        let layer = CATextLayer()
        layer.contentsScale = UIScreen.main.scale
        layer.foregroundColor = UIColor.black.cgColor
        layer.fontSize = 15
        layer.alignmentMode = "center"
        return layer
    }
}

//MARK: touch
extension GZRangeSlider{
    fileprivate func setHitRect(_ rect: CGRect) -> CGRect{
        let offset:CGFloat = 10
        return CGRect(x: rect.minX, y: rect.minY - offset, width: rect.width, height: 2 * offset + rect.height)
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        previouslocation = touch.location(in: self)
        isLeftSelected = setHitRect(leftHandleLayer.frame).contains(previouslocation)
        isRightSelected = setHitRect(rightHandleLayer.frame).contains(previouslocation)
        return isLeftSelected || isRightSelected
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        let deltaLocation = (location.x - previouslocation.x)
        previouslocation = location
        
        if isLeftSelected{
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            leftHandleLayer.frame.origin.x = max(leftHandleLayer.frame.origin.x + deltaLocation, normalbackImageView.frame.minX + 0.5 * handleWidth - leftHandleLayer.frame.width)
            leftHandleLayer.frame.origin.x = min(leftHandleLayer.frame.origin.x, rightHandleLayer.frame.origin.x - leftHandleLayer.frame.width)
            leftValue = Int(leftHandleLayer.frame.origin.x/barWidth * CGFloat(insideMax - insideMin)) + insideMin
            updateHighlightedBar()
            CATransaction.commit()
            
        }else if isRightSelected{
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            rightHandleLayer.frame.origin.x = min(rightHandleLayer.frame.origin.x + deltaLocation,frame.width - rightHandleLayer.frame.width)
            rightHandleLayer.frame.origin.x = max(rightHandleLayer.frame.origin.x,leftHandleLayer.frame.origin.x + leftHandleLayer.frame.width)
            rightValue = Int((rightHandleLayer.frame.origin.x - leftHandleLayer.frame.width)/barWidth * CGFloat(insideMax - insideMin)) + insideMin
            updateHighlightedBar()
            CATransaction.commit()
        }
        
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        isLeftSelected = false
        isRightSelected = false
    }
    
    
}

