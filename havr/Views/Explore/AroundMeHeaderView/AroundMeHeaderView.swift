//
//  AroundMeHeaderView.swift
//  havr
//
//  Created by Agon Miftari on 5/3/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit



class AroundMeHeaderView: UIView {

    @IBOutlet weak var headerLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "AroundMeHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
}
