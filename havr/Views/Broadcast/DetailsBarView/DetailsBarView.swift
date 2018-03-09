//
//  DetailsBarView.swift
//  havr
//
//  Created by Ismajl Marevci on 4/24/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import Alamofire

protocol DetailsBarViewDelegate: class {
    func detailsBarView(sender: DetailsBarView, didPressSend button: UIButton, with message: String)
    func detailsBarView(sender: DetailsBarView, didPressMedia button: UIButton)
    func detailsBarView(sender: DetailsBarView, didRecordAt url: URL)
    func detailsBarView(sender: DetailsBarView, didChange height: CGFloat)
    func detailsBarView(sender: DetailsBarView, didBecomeFirstResponder textView: UITextView)
    func detailsBarView(sender: DetailsBarView, didOverlay button: UIButton)
    func detailsBarView(sender: DetailsBarView, didChangeText text: String)
    func detailsBarView(sender: DetailsBarView, didSelectUser user: User, at index: IndexPath)
}

extension DetailsBarViewDelegate {
    
}

class DetailsBarView: UIView {
    
    //MARK: - OUTLETS
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var attachButton: UIButton!
    @IBOutlet weak var overlayButton: UIButton!
    @IBOutlet weak var messageTextView: GrowingTextView!
    @IBOutlet weak var vMsgBorder: UIView!
    @IBOutlet weak var attachButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var mentionViewHeightConstrain: NSLayoutConstraint!
    
    @IBOutlet weak var recordingButton: RecordingButton!
    @IBOutlet weak var recordingDurationLabel: UILabel!
    @IBOutlet weak var recordingView: UIView!
    @IBOutlet weak var cancelRecordingScrollView: UIScrollView!
    
    //MARK: - VARIABLES
    var canSentMessage: Bool = false
    
    var users: [User] = [] {
        didSet {
            if users.count == 0 {
                showMentionsView = false
                self.collectionView.isHidden = true
            } else {
                showMentionsView = true
                self.collectionView.isHidden = false
            }
            
            self.collectionView.reloadData()
            self.collectionView.layoutIfNeeded()
        }
    }
    
    fileprivate var searchRequest: DataRequest?
    fileprivate var searchTimer: Timer?
    
    var showMentionsView: Bool = false {
        didSet {
            if showMentionsView {
                mentionViewHeightConstrain.constant = 40
            } else {
                mentionViewHeightConstrain.constant = 0
            }
            self.collectionView.reloadData()
            self.collectionView.collectionViewLayout.invalidateLayout()
            self.layoutIfNeeded()
        }
    }
    
    var canShowMentions: Bool = true
    
    var recordingOperation: RecordingOperation!

    weak var delegate: DetailsBarViewDelegate?
    
    static func loadViewFromNib() -> DetailsBarView {
        let view = UIView.load(fromNib: "DetailsBarView") as! DetailsBarView
        view.messageTextView.delegate = view
        view.messageTextView.trimWhiteSpaceWhenEndEditing = false
        
        view.vMsgBorder.layer.borderColor = UIColor.HexToColor("#D9DCDF").cgColor
        view.vMsgBorder.layer.cornerRadius = 15.0
        view.vMsgBorder.layer.borderWidth = 1.0
        view.vMsgBorder.layer.masksToBounds = true

        return view
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionInit()
        self.autoresizingMask = .flexibleHeight
        
        recordingOperation = RecordingOperation(span: 0.3, refreshRate: 0.25, recordingTime: 180)
        recordingOperation.delegate = self
        recordingButton.delegate = self
        
        showMentionsView = false
    }
    
    override var intrinsicContentSize: CGSize {
        return self.bounds.size
    }
    
    func collectionInit() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerMentionsCollectionCell()
        collectionView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5)
        collectionView.isHidden = true
    }
    
    //MARK: - ACTIONS
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        if let message = messageTextView.text, !message.trim.isEmpty {
            delegate?.detailsBarView(sender: self, didPressSend: sender, with: message.trim)
            messageTextView.text = nil
            updateSendButton(text: "")
        }
    }
    
    @IBAction func recordingTouchDown(_ sender: UIButton) {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        recordingOperation.start()
    }
    
    @IBAction func recordingTouchUp(_ sender: UIButton) {
        recordingOperation.end()
        //recordingOperation.audioRecorderDidFinishRecording(, successfully: true)
    }
    @IBAction func recordingTouchUpOutside(_ sender: UIButton) {
        recordingOperation.end()
    }
    
    @IBAction func attachButtonPressed(_ sender: UIButton) {
        self.delegate?.detailsBarView(sender: self, didPressMedia: sender)
    }
    
    @IBAction func overlayButtonPressed(_ sender: UIButton) {
        self.delegate?.detailsBarView(sender: self, didOverlay: sender)
    }

    @discardableResult override func resignFirstResponder() -> Bool {
        return messageTextView.resignFirstResponder()
    }
    
    fileprivate func textChangeUpdateMentionView() {
        if canShowMentions == false { return }
        
        guard let lastWord = getLeftWordNearCursor() else { return }
        
        if lastWord.contains("@") {
            searchUsers(word: lastWord)
        } else {
            searchUsers(word: "")
        }
    }
    
    fileprivate func searchUsers(word: String) {
        if word.isEmpty {
            searchTimer?.invalidate()
            searchRequest?.cancel()
            searchRequest = nil
            users = []
            return
        }
        
        if word == "@" {
            
        } else {
            
            let username = word.replacingOccurrences(of: "@", with: "").trim
            
            searchTimer?.invalidate()
            searchRequest?.cancel()
            searchRequest = nil
            
            searchTimer = Timer.after(0.1, {
                self.searchRequest = ConnectionsAPI.searchConnection(username: username, page: 1, userId: AccountManager.userId, completion: {[weak self](username, users, _, error) in
                    guard let `self` = self else { return }
                    
                    if let users = users, let currentText = self.getLeftWordNearCursor()?.replacingOccurrences(of: "@", with: "") {
                        if username == currentText {
                            self.users = users
                        }
                    }
                })
            })
            
        }
    }
    
    fileprivate func getLeftWordNearCursor() -> String? {
        
        guard let cursorPosition = messageTextView.selectedTextRange else { return nil }
        let startRange = messageTextView.beginningOfDocument
        
        guard let range = messageTextView.textRange(from: startRange, to: cursorPosition.start) else { return nil }
        
        guard let text = messageTextView.text(in: range) else { return nil }
        
        guard let lastWord = text.components(separatedBy: " ").last else { return nil }
        
        return lastWord
    }
    
    fileprivate func getLeftRangeNearCursor() -> UITextRange? {
        
        guard let cursorWord = getLeftWordNearCursor() else { return nil }
        
        guard let cursorPosition = messageTextView.selectedTextRange else { return nil }
        
        guard let startRange = messageTextView.position(from: cursorPosition.start, offset: -cursorWord.characters.count ) else { return nil }
        
        guard let range = messageTextView.textRange(from: startRange, to: cursorPosition.start) else { return nil }
        
        return range
    }
    
    func getColoredText(text:String) -> NSMutableAttributedString{
        let string:NSMutableAttributedString = NSMutableAttributedString(string: text)
        let words:[NSString] = text.components(separatedBy: " ") as [NSString]
        
        for word in words {
            if (word.hasPrefix("@")) {
                let range:NSRange = (string.string as NSString).range(of: word as String)
                string.addAttribute(NSForegroundColorAttributeName, value: UIColor.HexToColor("#0480E5"), range: range)
            }
        }
        
        return string
    }
}

//MARK: - EXTENSIONS
extension DetailsBarView : GrowingTextViewDelegate {
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        UIView.animate(withDuration: 0.2) { 
            self.layoutIfNeeded()
        }
        self.delegate?.detailsBarView(sender: self, didChange: height)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        //self.messageTextView.attributedText = getColoredText(text: textView.text)
        return true
    }
    
    func textViewDidChangeText(_ textView: GrowingTextView, with text: String) {
        updateSendButton(text: text.trim)
        textChangeUpdateMentionView()        
        self.delegate?.detailsBarView(sender: self, didChangeText: text.trim)
    }
    func updateSendButton(text: String = "") {
        UIView.animate(withDuration: 0.25) {
            if text.isEmpty || self.canSentMessage == false {
                self.sendButton.isHidden = true
                self.recordingButton?.isHidden = false
            } else {
                self.sendButton.isHidden = false
                self.recordingButton?.isHidden = true
            }
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.delegate?.detailsBarView(sender: self, didBecomeFirstResponder: textView)
        return true
    }
}


extension DetailsBarView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueMentionsCollectionCell(indexpath: indexPath)
        
        let user = users[indexPath.row]
        cell.nameLabel.text = "@\(user.username)"
        cell.fullnameLabel.text = user.fullName
        
        if let image = user.getUrl() {
            cell.ivPhoto.kf.setImage(with: image, placeholder: user.getPlaceholder())
        }else {
            cell.ivPhoto.image = #imageLiteral(resourceName: "defaultImageUser")
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let user = users[indexPath.row]
        let font = UIFont.robotoRegularFont(12)

        let fontAttributes = [NSFontAttributeName: font] // it says name, but a UIFont works
        let size = ((user.username.count > user.fullName.count ? user.username : user.fullName) as NSString).size(attributes: fontAttributes)
        return CGSize.init(width: size.width + 33, height: 45)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let user = users[indexPath.row]
        
        guard let range = getLeftRangeNearCursor() else { return }
        
        messageTextView.replace(range, withText: "@" + user.username + " ")
        
        self.users = []
    }
}

extension DetailsBarView : RecordingOperationDelegate {
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
        
//        if Int(time) % 2 == 0 {
//            SocketManager.shared.sendRecording { (success) in
//                print(success)
//            }
//        }
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
        
        self.delegate?.detailsBarView(sender: self, didRecordAt: url)
        
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
extension DetailsBarView: RecordingButtonDelegate {
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
