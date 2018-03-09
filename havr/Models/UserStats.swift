//
//  UserStats.swift
//  havr
//
//  Created by Personal on 5/22/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON

class UserStats: Object {
    dynamic var posts: Int = 0
    dynamic var connections: Int = 0
    dynamic var viewsCount: Int = 0
    
    static func create(from json: JSON) -> UserStats? {
        if let posts = json["posts"].int, let connections = json["connections"].int, let viewsCount = json["views_counter"].int {
            
            let u = UserStats()
            u.posts = posts
            u.connections = connections
            u.viewsCount = viewsCount
            
            return u
        }
        
        return nil
    }
}
