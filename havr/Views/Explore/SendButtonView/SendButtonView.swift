//
//  SendButtonView.swift
//  havr
//
//  Created by Agon Miftari on 8/16/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

protocol SendButtonViewDelegate: class {
    func sendButtonView(sender: SendButtonView, didPressSend button: UIButton)
}

class SendButtonView: UIView {

    //MARK: - OUTLETS
    @IBOutlet weak var sendButton: UIButton!
    
    //MARK: - VARIABLES
    weak var delegate: SendButtonViewDelegate?

    
    //MARK: - LIFE CYCLE
    static func loadViewFromNib() -> SendButtonView {
        let view = UIView.load(fromNib: "SendButtonView") as! SendButtonView
        return view
    }

    //MARK: - ACTIONS
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        self.delegate?.sendButtonView(sender: self, didPressSend: sender)
    }
}
