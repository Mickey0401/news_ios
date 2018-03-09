//
//  MyActivityHeaderView.swift
//  havr
//
//  Created by Agon Miftari on 5/3/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

protocol MyActivityViewDelegate : class {
    
    func myActivity(addChatOrEvent sender: UIButton)
}

class MyActivityHeaderView: UIView {
    
    @IBOutlet weak var addEventOrChatButton: UIButton!
    
    
    static var shared = MyActivityHeaderView()
    weak var delegate: MyActivityViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    class func instanceFromNib() -> UIView {
        return UINib(nibName: "MyActivityHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    @IBAction func addEventOrChatButtonPressed(_ sender: UIButton) {
        
        self.delegate?.myActivity(addChatOrEvent: sender)
        
    }
}
