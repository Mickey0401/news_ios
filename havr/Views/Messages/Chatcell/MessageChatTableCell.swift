//
//  MessageChatTableCell.swift
//  havr
//
//  Created by Personal on 4/26/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

class MessageChatTableCell: UITableViewCell {
    
    @IBOutlet weak var badgeCounterLabel: UILabel!
    @IBOutlet weak var badgeView: UIView!
    @IBOutlet weak var userImageView: RoundedImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var chatRoomLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var typeImageView: UIImageView!
    
    @IBOutlet weak var messageLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var typeWidthConstraint: NSLayoutConstraint!
    var conversation: Conversation! {
        didSet {
            setValues()
        }
    }
    
    let badgeViewColor = UIColor(red255: 13, green255: 148, blue255: 243)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.chatRoomLabel.text = ""
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if (selected) {
            self.badgeView.backgroundColor = badgeViewColor
        }else {
            self.badgeView.backgroundColor = badgeViewColor
        }
    }
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if (highlighted) {
            self.badgeView.backgroundColor = badgeViewColor
        }else {
            self.badgeView.backgroundColor = badgeViewColor
        }
    }
    
    fileprivate func setValues() {
        self.messageLabel.text = conversation.getDescription()
        self.titleLabel.text = conversation.getTitle()
        self.timeLabel.text = conversation.getDate()
        self.userImageView.kf.setImage(with: conversation.getUserImageUrl(), placeholder: conversation.getUserPlaceholder())
        self.badgeView.isHidden = conversation.unSeenCount == 0
        self.badgeCounterLabel.text = conversation.unSeenCount.toString
        
        if let lastConversationMessage = conversation.lastMessage {
            if lastConversationMessage.hasMedia {
                typeImageView.isHidden = false
                typeWidthConstraint.constant = 20
                messageLeadingConstraint.constant = 8
                typeImageView.image = #imageLiteral(resourceName: "M camera icon")
            }else {
                typeImageView.isHidden = true
                typeWidthConstraint.constant = 0
                messageLeadingConstraint.constant = 0
            }
        }else {
            typeImageView.isHidden = true
            typeWidthConstraint.constant = 0
            messageLeadingConstraint.constant = 0
        }
    }
    
}

extension UITableView {
    func dequeueMessageChatTableCell(index: IndexPath) -> MessageChatTableCell {
        return self.dequeueReusableCell(withIdentifier: "MessageChatTableCell", for: index) as! MessageChatTableCell
    }
    
    func registerMessageChatTableCell() {
        let nib = UINib(nibName: "MessageChatTableCell", bundle: nil)
        self.register(nib, forCellReuseIdentifier: "MessageChatTableCell")
    }
}
