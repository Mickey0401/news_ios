//
//  EventPostAPI.swift
//  havr
//
//  Created by Personal on 7/10/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class EventPostAPI {
    static func getPosts(byEvent id: Int, page: Int, completion: @escaping (([EventPost]?,Pagination?,HSError?) -> Void)) {
        
        let parameters: Parameters = [
            "page" : page,
            "page_size" : 50
        ]
        
        let request = RequestREST(resource: "events/\(id)/posts/", method: .get, parameters: parameters)
        
        ServiceREST.request(with: request) { (response) in
            if let jsonEvents = response.json["results"].array, let pagination = Pagination.create(from: response.json["pagination"]) {
                
                var posts: [EventPost] = []
                
                jsonEvents.forEach({ (item) in
                    if let e = EventPost.create(from: item, event: id) {
                        posts.append(e)
                    }
                })
                
                completion(posts, pagination, nil)
                
            } else {
                let error = response.hsError(message: "Something went wrong.")
                completion(nil, nil, error)
            }
        }
    }
    
    static func create(event: EventPost, completion: @escaping ((EventPost?, HSError?) -> Void)) {
        let parameters = event.toParameters
        
        let request = RequestREST(resource: "events/\(event.eventId)/posts/", method: .post, parameters: parameters)
        
        ServiceREST.request(with: request) { (response) in
            if let event = EventPost.create(from: response.json, event: event.eventId) {
                completion(event, nil)
            } else {
                let error = response.hsError(message: "Something went wrong.")
                completion(nil, error)
            }
        }
    }
    
    static func update(event: EventPost, completion: @escaping ((EventPost?, HSError?) -> Void)) {
        let parameters = event.toParameters
        
        let request = RequestREST(resource: "events/\(event.eventId)/posts/\(event.id)", method: .put, parameters: parameters)
        
        ServiceREST.request(with: request) { (response) in
            if let event = EventPost.create(from: response.json, event: event.eventId) {
                completion(event, nil)
            } else {
                let error = response.hsError(message: "Something went wrong.")
                completion(nil, error)
            }
        }
    }
    
    static func delete(event: EventPost, completion: @escaping ((Success, HSError?) -> Void)) {
        
        let request = RequestREST(resource: "events/\(event.eventId)/posts/\(event.id)", method: .delete, parameters: nil)
        
        ServiceREST.request(with: request) { (response) in
            if response.isHttpSuccess {
                completion(true, nil)
            } else {
                let error = response.hsError(message: "Something went wrong.")
                completion(false, error)
            }
        }
    }
    
    static func likeEvent(event: EventPost, completion: @escaping ((Success, HSError?) -> Void)) {
        
        let request = RequestREST(resource: "events/\(event.eventId)/posts/\(event.id)?like", method: .get, parameters: nil)
        
        ServiceREST.request(with: request) { (response) in
            if response.isHttpSuccess {
                completion(true, nil)
            } else {
                let error = response.hsError(message: "Could not like post.")
                completion(false, error)
            }
        }
    }
    
    static func unlikeEvent(event: EventPost, completion: @escaping ((Success, HSError?) -> Void)) {
        let request = RequestREST(resource: "events/\(event.eventId)/posts/\(event.id)?unlike", method: .get, parameters: nil)
        
        ServiceREST.request(with: request) { (response) in
            if response.isHttpSuccess {
                completion(true, nil)
            } else {
                let error = response.hsError(message: "Could not unlike post.")
                completion(false, error)
            }
        }
    }
    
    static func report(post: EventPost, reportMessage: ReportPostMessage, reportPlace: ReportPostPlace, completion: @escaping ((Bool, HSError?) -> Void)) {
        
        let parameters: Parameters = [
            "post_id": post.id,
            "message": reportMessage.rawValue,
            "place": reportPlace.rawValue
        ]
        
        let request = RequestREST(resource: "report/", method: .post, parameters: parameters)
        
        ServiceREST.request(with: request) { (response) in
            if response.isHttpSuccess {
                completion(true,nil)
            }else {
                let error = response.hsError(message: "Coult not report post.")
                completion(false, error)
            }
        }
    }
}

