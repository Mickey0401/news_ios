//
//  Alamofire.swift
//  havr
//
//  Created by Personal on 8/22/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

extension Dictionary where Key == String, Value == Any {
    var json: JSON {
        return JSON(self)
    }
}
