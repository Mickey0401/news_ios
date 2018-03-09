//
//  ConversationAPI.swift
//  havr
//
//  Created by Personal on 7/6/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ConversationAPI: NSObject {
    static func get(limit: Int = 30, page: Int = 0, completion: @escaping (([Conversation]?,Pagination?, HSError?) -> Void)) {
        
        let parameters: Parameters = [
            "page" : page,
            "page_size" : limit
        ]
        
        let request = RequestREST(resource: "chat/", method: .get, parameters: parameters)
        
        ServiceREST.request(with: request) { (response) in
            if let jsonConversations = response.json["results"].array, let pagination = Pagination.create(from: response.json["pagination"]) {
                
                var conversations = [Conversation]()
                
                jsonConversations.forEach({ (item) in
                    if let c = Conversation.create(json: item) {
                        conversations.append(c)
                    }
                })
                
                conversations = conversations.sort() //sort
                
                completion(conversations, pagination, nil)
                
            } else {
                let error = response.hsError(message: "Something went wrong.")
                completion(nil,nil, error)
            }
        }
    }
    
    static func getMessages(conversation id: Int, limit: Int = 10, lastMessage date: Date, page: Int = 1, completion: @escaping (([Message]?, Pagination?, HSError?) -> Void)) {
        let parameters: Parameters = [
            "page" : page,
            "page_size" : limit,
            "create_date" : date.toServer
        ]
        
        let request = RequestREST(resource: "chat/\(id)/messages/", method: .get, parameters: parameters)
        
        ServiceREST.request(with: request) { (response) in
            if let jsonMessages = response.json["results"].array, let pagination = Pagination.create(from: response.json["pagination"]) {
                var messages = [Message]()
                
                jsonMessages.forEach({ (item) in
                    if let m = Message.create(json: item, conversation: id) {
                        messages.append(m)
                    }
                })
                
                
                let sorted = messages.sorted(by: { (first, second) -> Bool in
                    return first.createdAt.timeIntervalSince1970 < second.createdAt.timeIntervalSince1970
                })
                
                completion(sorted, pagination, nil)
                
            } else {
                let error = response.hsError(message: "Something went wrong.")
                completion(nil,nil, error)
            }
        }
    }
    
    static func getConversation(user id: Int, completion: @escaping ((Conversation?, HSError?) -> Void)) {
        
        let request = RequestREST(resource: "chat/?user_id=\(id)", method: .get, parameters: nil)
        
        ServiceREST.request(with: request) { (response) in
            if let conversationId = response.json["channel_id"].int, response.isHttpSuccess {
                
                let c = Conversation()
                c.id = conversationId
                completion(c, nil)
                
            } else {
                let error = response.hsError(message: "Something went wrong")
                completion(nil, error)
            }
        }
    }
    
    static func getOlderMessages(conversation id: Int, lastMessage date: Date, limit: Int = 30, page: Int = 1, completion: @escaping (([Message]?, Pagination?, HSError?) -> Void) ) {
        
    }
    
    static func markAsSeen(conversation id: Int, completion: @escaping ((Success, HSError?) -> Void)) {
        let parameters = [
            "page_size" : 1
        ]
        
        let request = RequestREST(resource: "chat/\(id)/messages/?seenAll", method: .get, parameters: parameters)
        
        ServiceREST.request(with: request) { (response) in
            if response.isHttpSuccess {
                completion(true, nil)
            } else {
                completion(false, response.hsError())
            }
        }
        
    }
    
    static func delete(conversation id: Int, deleteAll: Bool, completion: @escaping ((Success, HSError?) -> Void)) {
        
        var path = "chat/\(id)/"
        if deleteAll {
            path = path.appending("?all")
        }
        
        let request = RequestREST(resource: path, method: .delete, parameters: nil)
        
        ServiceREST.request(with: request) { (response) in
            
            if response.isHttpSuccess || response.isHttpNotFound {
                completion(true, nil)
            } else {
                let error = response.hsError(message: "Could not complete your request. Please try again.")
                completion(false, error)
            }
            
            print(response.json)
        }
        
    }
}
