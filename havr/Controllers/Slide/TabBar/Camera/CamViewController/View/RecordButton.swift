//
//  RecordButton.swift
//  havr
//
//  Created by Yuriy G. on 1/26/18.
//  Copyright © 2018 Tenton LLC. All rights reserved.
//

import UIKit
import AVFoundation
import PRTween

@IBDesignable
class RecordButton: CamButton {
    
    
    private weak var tweenOperation : PRTweenOperation?
    private var startPlayer : AVAudioPlayer?
    private var stopPlayer : AVAudioPlayer?
    private var isRecordingScale : CGFloat = 1.0 {
        didSet {
            setNeedsDisplay()
        }
    }

    @IBInspectable open var playSounds = true

    @IBInspectable open var frameColor : UIColor = RecordButtonKit.recordFrameColor {
        didSet {
            setNeedsDisplay()
        }
    }
 
    @IBInspectable open var isRecording : Bool = false {
        didSet {
            #if !TARGET_INTERFACE_BUILDER
                //  Stop any running animation
                if let tweenOperation = tweenOperation {
                    PRTween.sharedInstance().remove(tweenOperation)
                }
                
                //  Animate from one state to another (either 0 -> 1 or 1 -> 0)
                let period = PRTweenPeriod.period(withStartValue: isRecordingScale,
                                                  endValue: isRecording ? 0.0 : 1.0,
                                                  duration: 0.5) as! PRTweenPeriod
                
                tweenOperation = PRTween.sharedInstance().add(period, update: { (p) in
                    self.isRecordingScale = p!.tweenedValue
                }, completionBlock: nil)
                
            #else
                //  Don't animate in IB as the changes will not be shown
                isRecordingScale = isRecording ? 0.0 : 1.0
            #endif
        }
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let result = super.beginTracking(touch, with: event)
    
        return result
    }
    
    override func sendAction(_ action: Selector, to target: Any?, for event: UIEvent?) {

        isRecording = !isRecording
        
        isRecording ? self.startRecordingPress() : self.stopRecordingPress()

        super.sendAction(action, to: target, for: event)
    }
    
    override func draw(_ rect: CGRect) {
        let buttonFrame = bounds
        let pressed = isHighlighted || isTracking
        
        RecordButtonKit.drawRecordButton(frame: buttonFrame,
                                         recordButtonFrameColor:frameColor,
                                         isRecording: isRecordingScale,
                                         isPressed: pressed)
    }

    public func setButtonColor(_ isDark: Bool) {
        frameColor = isDark ? UIColor.white : Color.purpleColor
    }
        
    override var isHighlighted: Bool {
        get {
            return super.isHighlighted
        }
        set {
            super.isHighlighted = isHighlighted
            setNeedsDisplay()
        }
    }
}
