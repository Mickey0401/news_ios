//
//  AllowPermissionView.swift
//  havr
//
//  Created by Agon Miftari on 7/15/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

class AllowPermissionView: UIView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    @IBOutlet weak var laterButton: UIButton!
    
    var permissionButtonPressed: (() -> Void)? = nil
    var laterButtonPressed: (() -> Void)? = nil
    
    static func createForLocation() -> AllowPermissionView {
        let view = UIView.load(fromNib: "AllowPermissionView") as! AllowPermissionView
        
        view.imageView.image = #imageLiteral(resourceName: "Permission Location")
        view.titleLabel.text = "Where are you?"
        view.messageLabel.text = nil

        view.laterButton.isHidden = true
        view.actionButton.setTitle("Turn on location", for: .normal)
        
        return view
        
    }
    
    static func createForNotification() -> AllowPermissionView {
        let view = UIView.load(fromNib: "AllowPermissionView") as! AllowPermissionView
        
        view.imageView.image = #imageLiteral(resourceName: "Permission Notifications")
        view.titleLabel.text = "Activity Notifications"
        view.messageLabel.text = nil
        
        view.actionButton.setTitle("Turn on notifications", for: .normal)
        
        return view
    }
    
    static func createForPhotoLibrary() -> AllowPermissionView {
        let view = UIView.load(fromNib: "AllowPermissionView") as! AllowPermissionView
        
        view.actionButton.setTitle("Enable Access to Library", for: .normal)
        view.actionButton.isHidden = false
        view.titleLabel.text = "Please Allow Access to Your Photos and Videos"
        view.messageLabel.text = nil
        view.imageView.image = #imageLiteral(resourceName: "EMPTY photolibrary icon")
        
        view.laterButton.isHidden = false
        
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
    @IBAction func actionButtonPressed(_ sender: UIButton) {
        
        self.permissionButtonPressed?()

    }
    
    @IBAction func laterButtonPressed(_ sender: UIButton) {
        
        self.laterButtonPressed?()
    }
    
}
