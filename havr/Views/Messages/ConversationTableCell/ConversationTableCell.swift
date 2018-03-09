//
//  ConversationTableCell.swift
//  havr
//
//  Created by Ismajl Marevci on 4/28/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

protocol ConversationTableCellDelegate: class {
    func conversationTableCell(sender: ConversationTableCell, didSelectAt image: UIImage)
    func conversationTableCell(sender: ConversationTableCell, didPressRetry button: UIButton)
}

enum CornerType: UInt8 {
    case TOP_LEFT = 1
    case TOP_RIGHT =  2
    case BOTTOM_LEFT = 4
    case BOTTOM_RIGHT = 8
    
    var intValue: UInt8 {
        return self.rawValue
    }
}

class ConversationTableCell: UITableViewCell {

    var message: Message! {
        didSet {
            setValues()
        }
    }
    @IBOutlet weak var shadowView: CornerSpecView!
    
    @IBOutlet weak var rightImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var messageLabel: SRCopyableLabel!
    @IBOutlet weak var messageImageView: UIImageView!
    @IBOutlet weak var retryButton: UIButton!
    
    
    weak var delegate: ConversationTableCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupTap()
        messageImageView?.clipsToBounds = true
    }
    
    func setupShadow() {
        shadowView.shadowColor = UIColor.init(red255: 208, green255: 208, blue255: 208)
        shadowView.shadowOpacity = 0.6
        shadowView.shadowOffset = CGSize.zero
        shadowView.masksToBounds =  false
    }
    
    func setupCorners(cornerType: UIRectCorner) {
        self.shadowView.corners = cornerType
    }
        
    func setupTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(mediaPressed))
        tap.delegate = self
        tap.numberOfTapsRequired = 1
        self.messageImageView?.isUserInteractionEnabled = true
        self.messageImageView?.addGestureRecognizer(tap)
    }
    func mediaPressed() {
        if let image = messageImageView.image {
            self.delegate?.conversationTableCell(sender: self, didSelectAt: image)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selec ted state
    }
    
    internal func setValues() {
        if let message = message {
            timeLabel.text = message.getTime()
            if message.hasMedia {
                messageImageView?.kf.setImage(with: message.getImageUrl())
                messageLabel?.text = nil
            } else {
                messageLabel?.text = message.text
                messageImageView?.image = nil
            }
            
            switch message.messageStatus {
            case .created, .sending:
                self.rightImageView?.isHidden = true
                self.retryButton?.isHidden = true
                self.rightImageView?.image = Constants.defaultSentMessageGrayImage
            case .sent:
                self.rightImageView?.isHidden = false
                self.retryButton?.isHidden = true
                self.rightImageView?.image = Constants.defaultSentMessageGrayImage

            case .failed:
                self.retryButton?.isHidden = false
                self.rightImageView?.image = Constants.defaultSentMessageGrayImage
            }
            
            if message.isSeen {
                self.rightImageView?.image = Constants.defaultSeenMessageBlueImage
            }
        }
        
        self.layoutIfNeeded()
        setupShadow()
    }
    @IBAction func retryButtonClicked(_ sender: UIButton) {
        self.delegate?.conversationTableCell(sender: self, didPressRetry: sender)
    }
}
extension UITableView {
    func registerReceiverImageTableCell() {
        let nib = UINib(nibName: "ReceiverImageTableCell", bundle: nil)
        self.register(nib, forCellReuseIdentifier: "ReceiverImageTableCell")
    }
    func registerReceiverTextTableCell() {
        let nib = UINib(nibName: "ReceiverTextTableCell", bundle: nil)
        self.register(nib, forCellReuseIdentifier: "ReceiverTextTableCell")
    }
    func registerSenderImageTableCell() {
        let nib = UINib(nibName: "SenderImageTableCell", bundle: nil)
        self.register(nib, forCellReuseIdentifier: "SenderImageTableCell")
    }
    
    func registerSenderTextTableCell() {
        let nib = UINib(nibName: "SenderTextTableCell", bundle: nil)
        self.register(nib, forCellReuseIdentifier: "SenderTextTableCell")
    }
    func registerSenderTextWithoutStatusTableCell() {
        let nib = UINib(nibName: "SenderTextWithoutStatusTableCell", bundle: nil)
        self.register(nib, forCellReuseIdentifier: "SenderTextWithoutStatusTableCell")
    }
    func registerSenderImageWithoutStatusTableCell() {
        let nib = UINib(nibName: "SenderImageWithoutStatusTableCell", bundle: nil)
        self.register(nib, forCellReuseIdentifier: "SenderImageWithoutStatusTableCell")
    }
    
    func dequeueConversationMessageTableCell(identifier: String, indexPath: IndexPath) -> ConversationTableCell {
        return self.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! ConversationTableCell
        
    }
}
