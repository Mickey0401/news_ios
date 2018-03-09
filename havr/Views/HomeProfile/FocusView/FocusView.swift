//
//  FocusView.swift
//  havr
//
//  Created by Agon Miftari on 4/21/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

class FocusView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "FocusView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }

}
