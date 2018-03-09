//
//  ChatRoomHeaderView.swift
//  havr
//
//  Created by Ismajl Marevci on 7/8/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

class ChatRoomHeaderView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    static func createHeader(title: String, url: URL) -> ChatRoomHeaderView {
        let view = UIView.load(fromNib: "ChatRoomHeaderView") as! ChatRoomHeaderView
        view.titleLabel.text = "Welcome to \(title)"
        view.imageView.kf.setImage(with: url)
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
