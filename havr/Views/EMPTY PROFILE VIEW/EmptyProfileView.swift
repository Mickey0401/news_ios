//
//  EmptyProfileView.swift
//  havr
//
//  Created by Agon Miftari on 7/12/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

class EmptyProfileView: UIView {

    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!

    
    static func createForNoInternet() -> EmptyProfileView {
        let view = UIView.load(fromNib: "EmptyProfileView") as! EmptyProfileView
        
        view.imageView.image = nil
        view.titleLabel.text = "No internet connection"
        view.messageLabel.text = "Please check your wifi and try again"
        
        return view
        
    }
    
    static func createForPrivateProfile() -> EmptyProfileView {
        let view = UIView.load(fromNib: "EmptyProfileView") as! EmptyProfileView
        
        view.imageView.image = nil
        view.titleLabel.text = "Private Account"
        view.messageLabel.text = "Request to connect with this user to see their \n videos and photos"
        
        return view
    }
    
    static func createForNoPostsInInterest() -> EmptyProfileView {
        let view = UIView.load(fromNib: "EmptyProfileView") as! EmptyProfileView
        
        view.imageView.image = #imageLiteral(resourceName: "noimage icon")
        view.titleLabel.text = "No posts in this interest"
        view.messageLabel.text = "Try another one"
        
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
    
}
