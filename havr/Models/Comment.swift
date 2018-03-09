//
//  Comment.swift
//  havr
//
//  Created by Arben Pnishi on 6/5/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

class Comment: Object {
    var id: Int = 0
    var postId: Int = 0
    var user: User! = User()
    var text: String = ""
    var createdDate: Date = Date()
    
    var media: Media? = nil
    
    static func create(from json: JSON) -> Comment? {
        
        if let id = json["pk"].int, let postId = json["post"].int, let createdDate = Date.create(from: json["created"].string), let user = User.create(from: json["user"]), let text = json["text"].string {
            
            let c = Comment()
            
            if let media = Media.create(fromPostEvent: json["media"]){
                c.media = media
            }
            
            c.id = id
            c.postId = postId
            c.user = user
            c.text = text
            c.createdDate = createdDate
            
            return c
        }
        
        return nil
    }
}
