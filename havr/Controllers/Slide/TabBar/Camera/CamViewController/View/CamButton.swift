//
//  CamButton.swift
//  havr
//
//  Created by Yuriy G. on 1/19/18.
//  Copyright © 2018 Tenton LLC. All rights reserved.
//

import UIKit

//MARK: Public Protocol Declaration

public protocol CamButtonDelegate: class {
    
    func buttonWasTapped()
    
    func buttonDidBeginLongPress()

    func buttonDidEndLongPress()
    
    func longPressDidReachMaximumDuration()
    
    func setMaxiumVideoDuration() -> Double
    
    func setVideoRecordingTime(_ seconds: Int)
}

// MARK: Public View Declaration
/// UIButton Subclass for Capturing Photo and Video with CamViewController

open class CamButton: UIButton {
    
    public weak var delegate: CamButtonDelegate?    
    
    fileprivate var timer : Timer?
    fileprivate var seconds = 0
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func startRecordingPress() {
        delegate?.buttonDidBeginLongPress()
        startTimer()
    }
    
    public func stopRecordingPress() {
        invalidateTimer()
        delegate?.buttonDidEndLongPress()
    }
    
    public func Tap() {
        delegate?.buttonWasTapped()
    }
    
    @objc fileprivate func LongPress(_ sender:UILongPressGestureRecognizer!)  {
        switch sender.state {
        case .began:
            delegate?.buttonDidBeginLongPress()
            startTimer()
        case .ended:
            invalidateTimer()
            delegate?.buttonDidEndLongPress()
        default:
            break
        }
    }
    
    @objc fileprivate func timerFinished() {
        invalidateTimer()
        delegate?.longPressDidReachMaximumDuration()
    }
    
    @objc fileprivate func timerProgressing() {
        seconds += 1
        delegate?.setVideoRecordingTime(seconds)
        if let duration = delegate?.setMaxiumVideoDuration() {
            if duration <= Double(seconds) {
                timerFinished()
            }
        }
       
    }
    
    fileprivate func startTimer() {
        seconds = 0
        if let duration = delegate?.setMaxiumVideoDuration() {
            if duration != 0.0 && duration > 0.0 {
                timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:  #selector(CamButton.timerProgressing), userInfo: nil, repeats: true)
            }
        }
    }
    
    
    fileprivate func invalidateTimer() {
        timer?.invalidate()
        timer = nil
        seconds = 0
    }    
    

}
