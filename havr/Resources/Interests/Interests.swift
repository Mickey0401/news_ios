//
//  Interests.swift
//  havr
//
//  Created by Ismajl Marevci on 5/23/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON

class Interest : Object {
    dynamic var name : String = ""
    dynamic var picture : String = ""
    dynamic var id: Int = 0
    dynamic var isSeen : Bool = true
    
    static func create(from json: JSON) -> Interest? {
        if let name = json["name"].string, let picture = json["picture"].string, let id = json["pk"].int  {
            
            let i = Interest()
            i.name = name
            i.picture = picture
            i.id = id
            
            if let isSeen = json["is_seen"].bool {
                i.isSeen = isSeen
            }
            
            return i
        }
        return nil
    }
    
    func getUrl() -> URL? {
        return URL(string: picture)
    }
}

