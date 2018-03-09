//
//  RoundedSearchBar.swift
//  havr
//
//  Created by CloudStream on 2/19/18.
//  Copyright © 2018 Tenton LLC. All rights reserved.
//

import Foundation
import UIKit

class RoundedSearchBar :UISearchBar {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let frame = self.subviews.last?.subviews[1].frame
        self.subviews.last?.subviews[1].frame = CGRect.init(x: (frame?.origin.x)!, y: 0, width: (frame?.size.width)!, height: 30)
    }
}

