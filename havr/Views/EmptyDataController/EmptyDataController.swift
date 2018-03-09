//
//  EmptyDataView.swift
//  havr
//
//  Created by Ismajl Marevci on 6/21/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

protocol EmptyDataControllerDelegate: class {
    func emptyDataController(sender: EmptyDataController, didPress action: UIButton)
}

class EmptyDataController: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    weak var delegate: EmptyDataControllerDelegate?
    
    static func createForLocation() -> EmptyDataController {
        let view = UIView.load(fromNib: "EmptyDataController") as! EmptyDataController
        view.titleLabel.text = "No Location"
        view.messageLabel.text = nil
        view.imageView.image = #imageLiteral(resourceName: "map-locator")
        view.actionButton.setTitle("Settings", for: .normal)
        view.actionButton.isHidden = false
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
        self.delegate?.emptyDataController(sender: self, didPress: sender)
    }
}
