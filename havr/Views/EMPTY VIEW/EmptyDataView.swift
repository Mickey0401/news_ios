//
//  EmptyDataView.swift
//  havr
//
//  Created by Ismajl Marevci on 6/21/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

protocol EmptyDataViewDelegate: class {
    func emptyDataView(sender: EmptyDataView, didPress action: UIButton)
}

class EmptyDataView: UIView {
    @IBOutlet weak var emtyDescriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var laterButton: UIButton!
    
    @IBOutlet weak var constWidImgView: NSLayoutConstraint!
    weak var delegate: EmptyDataViewDelegate?
    
    var laterButtonPressed : (() -> Void)? = nil
    
    static func createForMessages() -> EmptyDataView {
        let view = UIView.load(fromNib: "EmptyDataView") as! EmptyDataView
        view.titleLabel.text = ""
        view.messageLabel.text = nil
        //view.actionButton.setTitle("Create", for: .normal)
        //view.actionButton.isHidden = true
        view.imageView.image = nil
        view.actionButton.isHidden = true
        view.constWidImgView.constant = 0.0
        return view
    }
    static func createForRetryMessages() -> EmptyDataView {
        let view = UIView.load(fromNib: "EmptyDataView") as! EmptyDataView
        view.titleLabel.text = "No conversations"
        view.messageLabel.text = nil
        view.actionButton.setTitle("Retry", for: .normal)
        view.emtyDescriptionLabel.isHidden = true
        view.imageView.image = #imageLiteral(resourceName: "EMPTY message icon")
        view.actionButton.isHidden = false
        return view
    }
    
    static func createForSearch() -> EmptyDataView {
        let view = UIView.load(fromNib: "EmptyDataView") as! EmptyDataView
        view.titleLabel.text = ""
        view.emtyDescriptionLabel.isHidden = true
        view.messageLabel.text = ""
        view.constWidImgView.constant = 0.0
        //view.actionButton.setTitle("Back", for: .normal)
        //view.actionButton.isHidden = true
//        view.imageView.image = #imageLiteral(resourceName: "EMPTY search icon")
        view.actionButton.isHidden = true
        return view
    }
    static func createForNewMessage() -> EmptyDataView {
        let view = UIView.load(fromNib: "EmptyDataView") as! EmptyDataView
        view.titleLabel.text = "New Message"
        view.messageLabel.text = "Find your connections and write them"
        //view.actionButton.setTitle("Back", for: .normal)
        //view.actionButton.isHidden = true
        view.emtyDescriptionLabel.isHidden = true

        view.imageView.image = #imageLiteral(resourceName: "EMPTY message icon")
        view.actionButton.isHidden = true
        return view
    }
    static func createForBlocked() -> EmptyDataView {
        let view = UIView.load(fromNib: "EmptyDataView") as! EmptyDataView
        view.emtyDescriptionLabel.text = "No connected users yet"
        view.titleLabel.isHidden = true
        view.messageLabel.text = nil
        //view.actionButton.setTitle("Back", for: .normal)
        //view.actionButton.isHidden = true
        view.imageView.image = nil
        view.actionButton.isHidden = true
        return view
    }
    
    static func createForFailedProducts() -> EmptyDataView {
        let view = UIView.load(fromNib: "EmptyDataView") as! EmptyDataView
        view.titleLabel.text = "No internet connection."
        view.messageLabel.text = nil
        view.emtyDescriptionLabel.isHidden = true

        //view.actionButton.setTitle("Try again", for: .normal)
        //view.actionButton.isHidden = false
        view.imageView.image = #imageLiteral(resourceName: "wifi icon")
        view.actionButton.isHidden = true
        return view
    }
    
    static func createForChatsEvents() -> EmptyDataView {
        let view = UIView.load(fromNib: "EmptyDataView") as! EmptyDataView
        view.titleLabel.text = "No chats or events"
        view.messageLabel.text = nil
        view.emtyDescriptionLabel.isHidden = true

//        view.actionButton.setTitle("Create", for: .normal)
        //view.actionButton.isHidden = true
        view.imageView.image = #imageLiteral(resourceName: "chatt icon")
        view.actionButton.isHidden = true
        return view
    }
    static func createForChatRoomPosts() -> EmptyDataView {
        let view = UIView.load(fromNib: "EmptyDataView") as! EmptyDataView
        view.titleLabel.text = "No Posts yet"
        view.messageLabel.text = nil
        view.emtyDescriptionLabel.isHidden = true

        //view.actionButton.setTitle("Create", for: .normal)
        //view.actionButton.isHidden = true
        view.imageView.image = #imageLiteral(resourceName: "chatt icon")
        view.actionButton.isHidden = true
        return view
    }
    static func createForChatRoomComments() -> EmptyDataView {
        let view = UIView.load(fromNib: "EmptyDataView") as! EmptyDataView
        view.titleLabel.text = "No comments yet"
        view.messageLabel.text = nil
        view.emtyDescriptionLabel.isHidden = true

        //view.actionButton.setTitle("Create", for: .normal)
        //view.actionButton.isHidden = true
        view.imageView.image = #imageLiteral(resourceName: "chatt icon")
        view.actionButton.isHidden = true
        return view
    }
    
    static func createForNoPostsInEvent() -> EmptyDataView {
        let view = UIView.load(fromNib: "EmptyDataView") as! EmptyDataView
        view.titleLabel.text = "No posts in this event"
        view.emtyDescriptionLabel.isHidden = true

        view.messageLabel.text = "Tap Create to add new post."
        view.actionButton.setTitle("Create", for: .normal)
        
        view.imageView.image = #imageLiteral(resourceName: "chatt icon")
        view.actionButton.isHidden = false
        return view
    }
    
    static func createForNotifications() -> EmptyDataView {
        
        let view = UIView.load(fromNib: "EmptyDataView") as! EmptyDataView
        
        view.titleLabel.text = nil
        view.messageLabel.text = nil
        view.emtyDescriptionLabel.isHidden = true


        view.imageView.image = #imageLiteral(resourceName: "EMPTY notification icon")
        view.actionButton.isHidden = true
       
        return view
    }
    
    static func createForSomethingWrong() -> EmptyDataView {
        let view = UIView.load(fromNib: "EmptyDataView") as! EmptyDataView
        
        view.actionButton.setTitle("Tap to reload", for: .normal)
        view.actionButton.isHidden = false
        view.titleLabel.text = "Something went wrong"
        view.emtyDescriptionLabel.isHidden = true

        view.messageLabel.text = nil
        view.imageView.image = #imageLiteral(resourceName: "EMPTY wrong icon")
        
        return view
    }
    
    static func createForNoResults() -> EmptyDataView {
        let view = UIView.load(fromNib: "EmptyDataView") as! EmptyDataView
        
        view.actionButton.isHidden = true
        view.titleLabel.text = "No results found"
        view.titleLabel.font = UIFont.sfProDisplaySemiboldFont(17)
        view.emtyDescriptionLabel.isHidden = true
        view.constWidImgView.constant = 0.0
        //view.imageView.isHidden = true
        //view.messageLabel.text = "Don’t give up! Keep lookin..."
        view.messageLabel.text = "Please check that all words are spelled correctly, or try another name, interest or keyword."
        view.messageLabel.font = UIFont.sfProDisplayRegularFont(15)
        //view.imageView.image = #imageLiteral(resourceName: "Empty crayon icon")
        
        return view
    }
    
    
    func show(to view: UIView) {
        self.frame = view.frame
        self.removeFromSuperview()
        view.addSubview(self)
        view.bringSubview(toFront: self)
    }
    
    func hide() {
        self.removeFromSuperview()
    }
    @IBAction func actionButtonClicked(_ sender: UIButton) {
        self.delegate?.emptyDataView(sender: self, didPress: sender)
    }
    @IBAction func laterButtonPressed(_ sender: UIButton) {
        self.laterButtonPressed?()
    }
}
