//
//  NotificationCenterTableCell.swift
//  havr
//
//  Created by Ismajl Marevci on 6/5/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

protocol NotificationCenterTableDelegate: class {
    func notificationCenter(sender: NotificationCenterTableCell, didPressAcceptButton button: UIButton)
    func notificationCenter(sender: NotificationCenterTableCell, didPressDeclineButton button: UIButton)
    func notificationCenter(sender: NotificationCenterTableCell, didPressViewProfileButton button: UIButton)
}

class NotificationCenterTableCell: UITableViewCell {
    //MARK: - OUTLETS
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var viewProfileButton: UIButton!
    @IBOutlet weak var notificationTimeLabel: UILabel!
    @IBOutlet weak var notificationBodyLabel: UILabel!
    @IBOutlet weak var notificationTitleLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    //MARK: - VARIABLES
    
    var delegate: NotificationCenterTableDelegate?
    var notification: APNotification!{
        didSet{
            setValues()
        }
    }
    var index: Int = 0
    
    //MARK: - LIFE CYCLE
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setValues(){
        let username = notification.userPerformed.fullName
        let otherTitle = getSubtitleFromType()
        
        if notification.type == .acceptedConnection {
            notificationTitleLabel.notificationTitleRegular(title: otherTitle, subTitle: username)
        }else {
            notificationTitleLabel.notificationTitle(title: username, subTitle: otherTitle)
        }
        if getBodyFromType() != "" {
            notificationBodyLabel?.text = getBodyFromType()
           // notificationBodyLabel.frame.size.height = notificationBodyLabel.
        }else {
            notificationBodyLabel?.text = nil
            notificationBodyLabel?.frame.size.height = 0
        }
        
        notificationTimeLabel.text = notification.timestamp.timeAgoSinceDate()
        if let image = notification.userPerformed.getUrl() {
            userImageView.kf.setImage(with: image, placeholder: Constants.defaultImageUser)
        }else {
            userImageView.image = Constants.defaultImageUser
        }
        
        if let post = notification.post {
            postImageView.kf.setImage(with: post.getImageUrl())
            
        }
        
        
    }
    
    func getSubtitleFromType() -> String{
        switch notification.type {
        case .acceptedConnection:
            return "Meet your new connection,"
            
        case .requestedConnection:
            return "sent you a connection request"
            
        case .declinedConnection:
            return "'s invitation to connect is declined"
            
        case .likedPost:
            return "supported your post"
            
        case .commentedOnPost:
            return "commented on your post"
            
        case .mentionedOnPost:
            return "mentioned you in a post"
        case .chatDeleted:
            return "deleted your mutual chat conversation"
            
        default:
            return ""
        }
    }
    
    func getBodyFromType() -> String{
        switch notification.type {
        case .acceptedConnection:
            return "Meet your new connection, \(notification.userPerformed.username)"
            
        case .requestedConnection:
            return "I'd like to connect with you on Havr"
            
        case .declinedConnection:
            return "You can still send an invitation to connect"
            
        case .mentionedOnPost:
            return "\(notification.post?.title ?? "No caption")"
            
        case .likedPost:
            return "\(notification.post?.title ?? "No caption")"
            
        case .commentedOnPost:
            return "\(notification.post?.title ?? "No caption")"
                    
        default:
            return ""
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if (selected) {
            self.userImageView.backgroundColor = Apperance.appBlueColor
            if let accept = self.acceptButton{
                if let decline = self.declineButton {
//                    accept.backgroundColor = Apperance.appBlueColor
                    decline.backgroundColor = UIColor.white
                }
            }else if let viewprofile = self.viewProfileButton {
                viewprofile.backgroundColor = UIColor.white
            }
        }else {
            self.userImageView.backgroundColor = Apperance.appBlueColor
            if let accept = self.acceptButton{
                if let decline = self.declineButton {
//                    accept.backgroundColor = Apperance.appBlueColor
                    decline.backgroundColor = UIColor.white
                }
            }else if let viewprofile = self.viewProfileButton {
                viewprofile.backgroundColor = UIColor.white
            }
        }
    }
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if (highlighted) {
            self.userImageView.backgroundColor = Apperance.appBlueColor
            if let accept = self.acceptButton{
                if let decline = self.declineButton {
                    accept.backgroundColor = Apperance.appBlueColor
                    decline.backgroundColor = UIColor.white
                }
            }else if let viewprofile = self.viewProfileButton {
                viewprofile.backgroundColor = UIColor.white
            }
        }else {
            self.userImageView.backgroundColor = Apperance.appBlueColor
            if let accept = self.acceptButton{
                if let decline = self.declineButton {
//                    accept.backgroundColor = Apperance.appBlueColor
                    decline.backgroundColor = UIColor.white
                }
            }else if let viewprofile = self.viewProfileButton {
                viewprofile.backgroundColor = UIColor.white
            }
        }
    }
    
    //MARK: - ACTIONS
    @IBAction func declineButtonPressed(_ sender: UIButton) {
        self.delegate?.notificationCenter(sender: self, didPressDeclineButton: sender)
    }
    @IBAction func acceptButtonPressed(_ sender: UIButton) {
        self.delegate?.notificationCenter(sender: self, didPressAcceptButton: sender)
    }
    @IBAction func viewProfileButton(_ sender: UIButton) {
        self.delegate?.notificationCenter(sender: self, didPressViewProfileButton: sender)
    }
}

//MARK: - EXTENSIONS
extension UITableView {
    func registerNCCommentTableCell() {
        let nib = UINib(nibName: "NCCommentTableCell", bundle: nil)
        self.register(nib, forCellReuseIdentifier: "NCCommentTableCell")
    }
    
    func registerNCInvitationTableCell() {
        let nib = UINib(nibName: "NCAcceptedTableCell", bundle: nil)
        self.register(nib, forCellReuseIdentifier: "NCAcceptedTableCell")
    }
    func registerNCAcceptDenyTableCell() {
        let nib = UINib(nibName: "NCRequestedTableCell", bundle: nil)
        self.register(nib, forCellReuseIdentifier: "NCRequestedTableCell")
    }
    func registerNCDeclinedTableCell() {
        let nib = UINib(nibName: "NCRequestedTableCell", bundle: nil)
        self.register(nib, forCellReuseIdentifier: "NCRequestedTableCell")
    }
    func registerNCOneLineTableCell() {
        let nib = UINib(nibName: "NCOneLineTableCell", bundle: nil)
        self.register(nib, forCellReuseIdentifier: "NCOneLineTableCell")
    }
    
    func dequeueNotificationCenterTableCell(identifier: String, indexPath: IndexPath) -> NotificationCenterTableCell {
        return self.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! NotificationCenterTableCell
    }
}
