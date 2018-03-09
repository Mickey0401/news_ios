//
//  SignUp.swift
//  havr
//
//  Created by Agon Miftari on 5/10/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import SwiftyJSON

class SignUp {
    
    var email : String?
    var full_name : String?
    var username : String?
    var password : String?
    
    
    static func create(from json: JSON) -> SignUp? {
        if let email = json["email"].string, let full_name = json["full_name"].string, let username = json["username"].string, let password = json["password"].string  {
            
            let s = SignUp()
            
            s.email = email
            s.full_name = full_name
            s.username = username
            s.password = password
            
            return s
        }
        return nil
    }

}
