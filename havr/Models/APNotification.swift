//
//  APNotification.swift
//  havr
//
//  Created by Arben Pnishi on 6/10/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

enum NotificationType: String {
    case requestedConnection = "Requested Connection"
    case acceptedConnection = "Accepted Connection"
    case declinedConnection = "Declined Connection"
    case likedPost = "Liked Post"
    case commentedOnPost = "Commented Post"
    case mentionedOnPost = "Mentioned"
    case chatDeleted = "Deleted Chat"
    case other = ""
}

class APNotification: NSObject {
    var id: Int = 0
    var userPerformed = User()
    var title: String = ""
    var timestamp: Date = Date()
    var type: NotificationType = .other
    var post: Post? = nil
    
    static func create(from json: JSON) -> APNotification? {
        if let id = json["pk"].int, let user = User.create(from: json["user_performed"]), let title = json["title"].string, let timestamp = Date.create(from: json["timestamp"].string) {
            
            let notification = APNotification()
            notification.id = id
            notification.userPerformed = user
            notification.title = title
            notification.timestamp = timestamp
            if let type = NotificationType.init(rawValue: title){
                notification.type = type
            }
            if let post = Post.create(from: json["post"]) {
                notification.post = post
            }
            
            return notification
        }
        return nil
    }
}
