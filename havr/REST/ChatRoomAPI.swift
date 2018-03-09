//
//  ChatRoomAPI.swift
//  havr
//
//  Created by Arben Pnishi on 6/13/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

struct ChatroomWrapper {
    var chatroom: [ChatRoom]
    var pagination: Pagination
}

class ChatRoomAPI: NSObject {
    @discardableResult
    static func getRooms(role: String?, page: Int, name: String? = nil, completion: @escaping (([ChatRoom]?,Pagination?,HSError?) -> Void)) -> DataRequest {
        var parameters: Parameters = [
            "page": page,
            "page_size": 100
            ]
        
        if let name = name {
            parameters["name"] = name
        }
        
        let request = RequestREST(resource: "chatrooms/", method: .get, parameters: parameters)
        
        return ServiceREST.request(with: request) { (response) in
            if let results = response.json["results"].array, let pagination = Pagination.create(from: response.json["pagination"]) {
                var broadcasts: [ChatRoom] = []
                
                for item in results {
                    if let n = ChatRoom.create(from: item) {
                        broadcasts.append(n)
                    }
                }
                completion(broadcasts, pagination, nil)
            } else {
                completion(nil, nil, response.hsError(message: "Something went wrong"))
            }
        }
    }
    
    static func createRoom(chatRoom: ChatRoom, completion: @escaping ((ChatRoom?, HSError?) -> Void)){
        let parameters: Parameters = [
            "name": chatRoom.name,
            "proximity": chatRoom.proximity >= 50 ? 999999.0 : chatRoom.proximity,
            "latitude": chatRoom.latitude.roundTo(places: 5),
            "longitude": chatRoom.longitude.roundTo(places: 5),
            "photo" : chatRoom.photo,
            "address" : chatRoom.address
        ]
        
        let request = RequestREST(resource: "chatrooms/", method: .post, parameters: parameters)
        
        ServiceREST.request(with: request) { (response) in
            if let room = ChatRoom.create(from: response.json){
                completion(room, nil)
            } else {
                completion(nil, response.hsError(message: "Something went wrong"))
            }
        }
    }
    
    static func updateRoom(with id: Int, chatRoom: ChatRoom, completion: @escaping ((ChatRoom?, HSError?) -> Void)){
        let parameters: Parameters = [
            "name": chatRoom.name,
            "proximity": chatRoom.proximity >= 50 ? 999999.0 : chatRoom.proximity,
            "latitude": chatRoom.latitude.roundTo(places: 5),
            "longitude": chatRoom.longitude.roundTo(places: 5),
            "photo": chatRoom.photo,
            "address" : chatRoom.address
        ]
        
        let request = RequestREST(resource: "chatrooms/\(id)/", method: .put, parameters: parameters)
        
        ServiceREST.request(with: request) { (response) in
            if let room = ChatRoom.create(from: response.json){
                completion(room, nil)
            } else {
                completion(nil, response.hsError(message: "Something went wrong"))
            }
        }
    }
    static func searchRooms(name: String, page: Int, completion: @escaping ((String, ChatroomWrapper?, HSError?) -> Void)) {
        let parameters: Parameters = [
            "page": page,
            "page_size": 50,
            "name": name
        ]
        
        let request = RequestREST(resource: "chatrooms/", method: .get, parameters: parameters)
        
        ServiceREST.request(with: request) { (response) in
            if let results = response.json["results"].array, let pagination = Pagination.create(from: response.json["pagination"]) {
                var broadcasts: [ChatRoom] = []
                
                for item in results {
                    if let n = ChatRoom.create(from: item) {
                        broadcasts.append(n)
                    }
                }
                let wrapper = ChatroomWrapper(chatroom: broadcasts, pagination: pagination)
                completion(name, wrapper, nil)
            } else {
                completion(name, nil, response.hsError(message: "Something went wrong"))
            }
        }
    }
    
    static func deleteRoom(with id: Int, completion: @escaping ((Bool, HSError?) -> Void)){
        
        let request = RequestREST(resource: "chatrooms/\(id)/", method: .delete, parameters: nil)
        
        ServiceREST.request(with: request) { (response) in
            if response.isHttpSuccess{
                completion(true, nil)
            } else {
                completion(false, response.hsError(message: "Something went wrong"))
            }
        }
    }
    
    static func joinRoom(with id: Int, completion: @escaping ((Bool, HSError?) -> Void)){
        
        let request = RequestREST(resource: "chatrooms/\(id)/?join", method: .get, parameters: nil)
        
        ServiceREST.request(with: request) { (response) in
            if response.isHttpSuccess{
                completion(true, nil)
            } else {
                completion(false, response.hsError(message: "Something went wrong"))
            }
        }
    }
    
    static func leaveRoom(with id: Int, completion: @escaping ((Bool, HSError?) -> Void)){
        
        let request = RequestREST(resource: "chatrooms/\(id)/?leave", method: .get, parameters: nil)
        
        ServiceREST.request(with: request) { (response) in
            if response.isHttpSuccess{
                completion(true, nil)
            } else {
                completion(false, response.hsError(message: "Something went wrong"))
            }
        }
    }
}
