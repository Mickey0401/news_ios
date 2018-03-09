//
//  Login.swift
//  havr
//
//  Created by Agon Miftari on 5/10/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import SwiftyJSON


class Login {
    
    var username: String?
    var password: String?
    
    
    func create(from json: JSON) -> Login? {
    
        if let username = json["username"].string, let password = json["password"].string {
            let l = Login()
            
            l.username = username
            l.password = password
            
            return l
        }
        return nil
    }
}
