//
//  Conversation.swift
//  havr
//
//  Created by Personal on 7/6/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON

class Conversation: Object {
    dynamic var id: Int = 0
    dynamic var createdAt: Date = Date()
    dynamic var user: User! = nil
    dynamic var unSeenCount: Int = 0
    dynamic var lastMessage: Message! = nil
    
    static func create(json: JSON) -> Conversation? {
        
        if let id = json["id"].int, let createdAt = Date.create(from: json["timestamp"].string), let user = User.create(from: json["user"]) {
            let c = Conversation()
            c.id = id
            c.createdAt = createdAt
            c.user = user
            c.unSeenCount = json["unseen_messages"].int ?? 0
            
            if let lastMessage = Message.create(json: json["last_message"], conversation: id) {
                c.lastMessage = lastMessage
            }
            
            return c
        }
        
        return nil
    }
    
    func getDescription() -> String {
        
        guard let lastMessage = self.lastMessage else { return "No messages" }
        
        let message: String = lastMessage.getDescription()
        
        if lastMessage.isMine {
            return "You: " + message
        }
        
        return message
    }
    
    func getLastUpdatedDate() -> Date {
        return lastMessage?.createdAt ?? createdAt
    }
    
    func getTitle() -> String {
        return user.fullName
    }
    
    func getTime() -> String {
        let formater = DateFormatter()
        formater.timeStyle = .short
        
        return formater.string(from: getLastUpdatedDate())
    }
    func getDate() -> String {
        guard lastMessage != nil else { return "" }
        return lastMessage.createdAt.toConversation
    }
    
    func getUserImageUrl() -> URL? {
        return user?.getUrl() ?? nil
    }
    
    func getUserPlaceholder() -> UIImage? {
        return Constants.defaultImageUser
    }
}
