//
//  ConnectionsAPI.swift
//  havr
//
//  Created by Ismajl Marevci on 6/1/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

enum ConnectionActionType: String{
    case connect = "connect"
    case accept  = "accept"
    case decline = "decline"
    case remove  = "remove"
    case requested = "requested"
    case block = "block"
    case unblock = "unblock"
}
class ConnectionsAPI: NSObject {
    
    static func getConnections(for userId: Int, page: Int, completion: @escaping (([User]?,Pagination?,HSError?) -> Void)) {
        let parameters: Parameters = [
            "page": page,
        ]
        
        let request = RequestREST(resource: "accounts/\(userId)/connections/", method: .get, parameters: parameters)
        
        ServiceREST.request(with: request) { (response) in
            if let results = response.json["results"].array, let pagination = Pagination.create(from: response.json["pagination"]) {
                var users: [User] = []
                
                for item in results {
                    if let user = User.create(from: item["user_to"]) {
                        if let status = item["status"].string{
                            user.status = ConnectionStatus(rawValue: status)!
                        }
                        users.append(user)
                    }
                }
                completion(users, pagination, nil)
            } else {
                completion(nil, nil, response.hsError(message: "Something went wrong"))
            }
        }
    }
    
    @discardableResult
    static func searchConnection(username: String, page: Int, userId : Int, completion: @escaping ((String,[User]?,Pagination?,HSError?) -> Void)) -> DataRequest {
        let parameters: Parameters = [
            "username" : username,
            "page": page,
            "page_size" : 10,
            "user_to" : userId
        ]
        
        let request = RequestREST(resource: "accounts/\(userId)/connections/", method: .get, parameters: parameters)
        
        return ServiceREST.request(with: request) { (response) in
            if let results = response.json["results"].array, let pagination = Pagination.create(from: response.json["pagination"]) {
                var users: [User] = []
                
                for item in results {
                    if let u = User.create(from: item["user_to"]) {
                        users.append(u)
                    }
                }
                
                completion(username, users, pagination, nil)
            } else {
                completion(username, nil, nil, response.hsError(message: "Something went wrong"))
            }
        }

    }
    static func searchForCurrent(username: String, page: Int, completion: @escaping ((String,[User]?,Pagination?,HSError?) -> Void)) {
        
//        GET /api/accounts/{user_id}/connections/
//        note: if you want retrieve connections for current user, then the same result will be achived via GET
//        /api/accounts/current/connections/
        
        let parameters: Parameters = [
            "full_name" : username,
            "page": page,
            "page_size" : 10
        ]
        
        let request = RequestREST(resource: "accounts/current/connections/", method: .get, parameters: parameters)
        
        ServiceREST.request(with: request) { (response) in
            if let results = response.json["results"].array, let pagination = Pagination.create(from: response.json["pagination"]) {
                var users: [User] = []
                
                for item in results {
                    if let u = User.create(from: item["user_to"]) {
                        users.append(u)
                    }
                }
                
                completion(username, users, pagination, nil)
            } else {
                completion(username, nil, nil, response.hsError(message: "Something went wrong"))
            }
        }
    }
    
    static func makeAction(with type: ConnectionActionType, userId : Int, completion: @escaping (Bool, HSError?) -> Void){
        let parameters: Parameters = [
            "user_to" : userId,
            "action" : type.rawValue
        ]
        
        let request = RequestREST(resource: "accounts/current/connections/", method: .post, parameters: parameters)
        
        ServiceREST.request(with: request) { (response) in
            if response.json["user_to"] != JSON.null{
                completion(true, nil)
            } else {
                completion(false, response.hsError(message: "Something went wrong"))
            }
        }
    }
    
    static func excludeFromNearbySearch(with userId : Int, completion: @escaping (Bool, HSError?) -> Void){
        let parameters: Parameters = [
            "user_to" : userId,
            "action" : "nearbyexclude"
        ]
        
        let request = RequestREST(resource: "accounts/current/connections/", method: .post, parameters: parameters)
        
        ServiceREST.request(with: request) { (response) in
            if response.json["user_to"] != JSON.null{
                completion(true, nil)
            } else {
                completion(false, response.hsError(message: "Something went wrong"))
            }
        }
    }
    
    static func getBlockedList(page: Int, completion: @escaping (([User]?,Pagination?,HSError?) -> Void)) {
        
        //GET /api/accounts/current/connections/blocked-users/
        let parameters: Parameters = [
            "page": page,
        ]
        
        let request = RequestREST(resource: "accounts/current/connections/blocked-users/", method: .get, parameters: parameters)
        
        ServiceREST.request(with: request) { (response) in
            if let results = response.json["results"].array, let pagination = Pagination.create(from: response.json["pagination"]) {
                var users: [User] = []
                
                for item in results {
                    if let user = User.create(from: item["user_to"]) {
                        if let status = item["status"].string{
                            user.status = ConnectionStatus(rawValue: status)!
                        }
                        users.append(user)
                    }
                }
                completion(users, pagination, nil)
            } else {
                completion(nil, nil, response.hsError(message: "Something went wrong"))
            }
        }
    }
    static func blockUser(with type: ConnectionActionType, userId : Int, completion: @escaping (Bool, HSError?) -> Void){
        
      /*    POST /api/accounts/current/connections/
            for you connection status will be 'blocked'
            for user, with id specified in "user_to", connection status will be 'blocking'
      */
        let parameters: Parameters = [
            "user_to" : userId,
            "action" : type.rawValue
        ]
        
        let request = RequestREST(resource: "accounts/current/connections/", method: .post, parameters: parameters)
        
        ServiceREST.request(with: request) { (response) in
            if response.json["user_to"] != JSON.null{
                completion(true, nil)
            } else {
                completion(false, response.hsError(message: "Something went wrong"))
            }
        }
    }
}
