//
//  MessageBarView.swift
//  havr
//
//  Created by Ismajl Marevci on 4/24/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

protocol MessageBarViewDelegate: class {
    func messageBarView(sender: MessageBarView, didPressSend button: UIButton, with message: String)
    func messageBarView(sender: MessageBarView, didRecordAt url: URL)
    func messageBarView(sender: MessageBarView, didPressMedia button: UIButton)
    func messageBarView(sender: MessageBarView, didChange height: CGFloat)
    func messageBarView(sender: MessageBarView, didBecomeFirstResponder textView: UITextView)
    func messageBarView(sender: MessageBarView, didChangeText text: String)
    
}

class MessageBarView: UIView {
    
    //MARK: - OUTLETS
    @IBOutlet weak var recordingDurationLabel: UILabel!
    @IBOutlet weak var recordingView: UIView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var recordingButton: RecordingButton!
    @IBOutlet weak var attachButton: UIButton!
    @IBOutlet weak var messageTextView: GrowingTextView!
    @IBOutlet weak var vMsgBorder: UIView!
    @IBOutlet weak var cancelRecordingScrollView: UIScrollView!
    
    //MARK: - VARIABLES
    var canSentMessage: Bool = false
    weak var delegate: MessageBarViewDelegate?
    
    var recordingOperation: RecordingOperation!
    
    static func loadViewFromNib() -> MessageBarView {
        let view = UIView.load(fromNib: "MessageBarView") as! MessageBarView
        view.messageTextView.delegate = view
        view.messageTextView.trimWhiteSpaceWhenEndEditing = false
        view.vMsgBorder.layer.borderColor = UIColor.HexToColor("#D9DCDF").cgColor
        view.vMsgBorder.layer.cornerRadius = 18.0
        view.vMsgBorder.layer.borderWidth = 2.0
        view.vMsgBorder.layer.masksToBounds = true
        return view
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        recordingOperation = RecordingOperation(span: 0.3, refreshRate: 0.25, recordingTime: 180)
        recordingOperation.delegate = self
        recordingButton.delegate = self
    }
    
    //MARK: - ACTIONS
    @IBAction func recordingTouchDown(_ sender: UIButton) {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        recordingOperation.start()
    }
    
    @IBAction func recordingTouchUp(_ sender: UIButton) {
        recordingOperation.end()
    }
    @IBAction func recordingTouchUpOutside(_ sender: UIButton) {
        recordingOperation.end()
    }
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        if let message = messageTextView.text, !message.trim.isEmpty {
            self.delegate?.messageBarView(sender: self, didPressSend: sender, with: message.trim)
            messageTextView.text = nil
            updateSendButton(text: "")
        }
    }
    @IBAction func attachButtonPressed(_ sender: UIButton) {
        self.delegate?.messageBarView(sender: self, didPressMedia: sender)
    }

    @discardableResult override func resignFirstResponder() -> Bool {
        return messageTextView.resignFirstResponder()
    }
}
//MARK: - EXTENSIONS
extension MessageBarView : GrowingTextViewDelegate {
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        self.delegate?.messageBarView(sender: self, didChange: height)
    }
    func textViewDidChangeText(_ textView: GrowingTextView, with text: String) {
        
        updateSendButton(text: text.trim)
        self.delegate?.messageBarView(sender: self, didChangeText: text.trim)
    }
    func updateSendButton(text: String = "") {
        UIView.animate(withDuration: 0.25) {
            if text.isEmpty {
                self.sendButton.isHidden = true
                self.recordingButton?.isHidden = false
            } else {
                self.sendButton.isHidden = false
                self.recordingButton?.isHidden = true
            }
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.delegate?.messageBarView(sender: self, didBecomeFirstResponder: textView)
        return true
    }
}

//MARK: - Recording Operations Delegate
extension MessageBarView : RecordingOperationDelegate {
    func recordingOperation(sender: RecordingOperation, willStartRecording url: URL) {
        print("Recording start")
        Sound.stopAll()
        UIView.animate(withDuration: 0.2, animations: {
            self.recordingView.isHidden = false
            self.recordingButton.adjustsImageWhenHighlighted = false
            self.recordingButton.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
            self.recordingButton.setImage(#imageLiteral(resourceName: "M recording icon"), for: UIControlState())
        })
        
        self.cancelRecordingScrollView.contentOffset = CGPoint.zero
        
        
        
    }
    func recordingOperation(sender: RecordingOperation, isRecordingAt time: TimeInterval) {
        recordingDurationLabel.text = "\(time.toTimeLeftVideo(currentSeconds: 0.0)) sec"
        print("Recording update view: Seconds passed: \(time)")
        
        if Int(time) % 2 == 0 {
            SocketManager.shared.sendRecording { (success) in
                print(success)
            }
        }
    }

    func recordingOperation(sender: RecordingOperation, didFinishRecordingAt url: URL) {
        print("Recording finishes at url: \(url)")
        recordingDurationLabel.text = "00:00 sec"
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        UIView.animate(withDuration: 0.2, animations: {
            self.recordingView.isHidden = true
            self.recordingButton.adjustsImageWhenHighlighted = false
            
            self.recordingButton.transform = CGAffineTransform.identity
            self.recordingButton.setImage(#imageLiteral(resourceName: "M audio icon"), for: UIControlState())
        })
        
        self.delegate?.messageBarView(sender: self, didRecordAt: url)
        
    }
    
    func recordingOperation(sender: RecordingOperation, recordingAborted error: ErrorMessage, canceled: Bool) {
        print("Recording aborted")
        UIView.animate(withDuration: 0.2, animations: {
            self.recordingView.isHidden = true
            self.recordingButton.adjustsImageWhenHighlighted = false
            
            self.recordingButton.transform = CGAffineTransform.identity
//            self.recordingButton.setImage(#imageLiteral(resourceName: "M audio icon"), for: UIControlState())
            self.recordingButton.setImage(#imageLiteral(resourceName: "M audio icon grey"), for: UIControlState())
        })
        
        if !canceled && !error.isEmpty {
            Helper.show(alert: error)
        }
    }
}

//MARK: Recording Button Delegate
extension MessageBarView: RecordingButtonDelegate {
    func recordingButton(sender: RecordingButton, touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return  }
        let offset = touch.previousLocation(in: self).x - touch.location(in: self).x
    
        let scrollPosition = CGPoint(x: cancelRecordingScrollView.contentOffset.x + offset, y: cancelRecordingScrollView.contentOffset.y)
        print(scrollPosition)
        if scrollPosition.x > 150 {
            recordingOperation.cancel()
        }
        
        self.cancelRecordingScrollView.contentOffset = scrollPosition
    }
}
