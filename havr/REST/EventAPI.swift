//
//  EventAPI.swift
//  havr
//
//  Created by Ismajl Marevci on 6/22/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

struct EventWrapper {
    var events: [Event]
    var pagination: Pagination
}

class EventAPI: NSObject {
    
    static func joinEvent(event: Event, completion: @escaping ((Success,HSError?) -> Void)) {
        
        let request = RequestREST(resource: "events/\(event.id)/?join", method: .get, parameters: nil)
        
        ServiceREST.request(with: request) { (response) in
            if Event.create(from: response.json) != nil {
                completion(true, nil)
            } else {
                let error = response.hsError(message: "Something went wrong.")
                completion(false, error)
            }
        }
    }
    
    static func leaveEvent(event: Event, completion: @escaping ((Success,HSError?) -> Void)) {
        
        let request = RequestREST(resource: "events/\(event.id)/?leave", method: .get, parameters: nil)
        
        ServiceREST.request(with: request) { (response) in
            if Event.create(from: response.json) != nil {
                completion(true, nil)
            } else {
                let error = response.hsError(message: "Something went wrong.")
                completion(false, error)
            }
        }
    }
    
    @discardableResult
    static func getEvents(status: EventStatus? = nil, name: String? = nil, maxDistance: Double? = nil, completion: ((EventWrapper?, HSError?) -> Void)? = nil) -> DataRequest {
        var parameters: Parameters = [
            "page_size": 50
        ]
        
        if let status = status {
            parameters["status"] = status.rawValue
        }
        
        if let name = name {
            parameters["name"] = name
        }
        
        if let maxDistance = maxDistance {
            parameters["max_distance"] = maxDistance
        }
        
        
        
        let request = RequestREST(resource: "events/", method: .get, parameters: parameters)
        
        return ServiceREST.request(with: request) { (response) in
            if let jsonEvents = response.json["results"].array, let pagination = Pagination.create(from: response.json["pagination"]) {
                
                var events: [Event] = []
                
                jsonEvents.forEach({ (item) in
                    if let event = Event.create(from: item) {
                        events.append(event)
                    }
                })
                let wrapper = EventWrapper(events: events, pagination: pagination)
                completion?(wrapper, nil)
            } else {
                let error = response.hsError(message: "Could not load events.")
                completion?(nil, error)
            }
        }
        
    }
    static func searchEvents(by name: String, page: Int, completion: ((String, EventWrapper?, HSError?) -> Void)? = nil) {
        let parameters: Parameters = [
            "page": page,
            "page_size": 50,
            "name": name
        ]
        
        let request = RequestREST(resource: "events/", method: .get, parameters: parameters)
        
        ServiceREST.request(with: request) { (response) in
            if let jsonEvents = response.json["results"].array, let pagination = Pagination.create(from: response.json["pagination"]) {
                
                var events: [Event] = []
                
                jsonEvents.forEach({ (item) in
                    if let event = Event.create(from: item) {
                        events.append(event)
                    }
                })
                let wrapper = EventWrapper(events: events, pagination: pagination)
                completion?(name, wrapper, nil)
            } else {
                let error = response.hsError(message: "Could not load events.")
                completion?(name, nil, error)
            }
        }
        
    }
    

    static func getByName(event: Event, completion: @escaping ((Event?, HSError?) -> Void)) {
        
        // GET /api/events/{event_id}/
        
        let parameters: Parameters = [
            "event_id" : event.id
        ]
        
        let request = RequestREST(resource: ["events",event.id], method: .get, parameters: parameters)
        
        ServiceREST.request(with: request) { (response) in
            
            if let event = Event.create(from: response.json) {
                completion(event, nil)
            }else {
                let error = response.hsError(message: "Could not load event.")
                completion(nil, error)
            }
        }
    }
    
    
    static func create(event: Event, completion: @escaping ((Event?, HSError?)-> Void)) {
        
        // POST /api/events/
        
        let parameters : Parameters = [
            "name": event.name,
            "description": event.eventDescription,
            "photo": event.photo,
            "address" : event.address,
            "latitude" : event.latitude.roundTo(places: 5),
            "longitude" : event.longitude.roundTo(places: 5),
            "datetime_start": event.dateTimeStart.toServer,
            "datetime_end": event.dateTimeEnd.toServer
        ]
        
        let request = RequestREST(resource: "events/", method: .post, parameters: parameters)
        
        ServiceREST.request(with: request) { (response) in
            
            if let event = Event.create(from: response.json) {
                
               completion(event, nil)
            }
            else {
                completion(nil, response.hsError(message: "Something went wrong"))
            }
        }
   
    }
    
    
    
    static func delete(event: Event, completion: @escaping ((Bool, HSError?) -> Void)) {
        
        //DELETE /api/events/{event_id}/
        
        let request = RequestREST(resource: "events/\(event.id)/", method: .delete, parameters: nil)
        
        ServiceREST.request(with: request) { (response) in
            if response.isHttpSuccess {
                completion(true,nil)
            }else {
                let error = response.hsError(message: "Could not delete event.")
                completion(false, error)
            }
        }
    }
    
    static func update(event: Event, completion: @escaping ((Event?, HSError?) -> Void)) {
        
        let parameters : Parameters = [
            "name": event.name,
            "description": event.eventDescription,
            "photo": event.photo,
            "address" : event.address,
            "latitude" : event.latitude.roundTo(places: 5),
            "longitude" : event.longitude.roundTo(places: 5),
            "datetime_start": event.dateTimeStart.toServer,
            "datetime_end": event.dateTimeEnd.toServer
        ]
        
        //PATCH /api/events/{event_id}/ -> -> note: PATCH for partial update and PUT for full update
        
        let request = RequestREST(resource: "events/\(event.id)/", method: .put, parameters: parameters)
        
        ServiceREST.request(with: request) { (response) in
            if let event = Event.create(from: response.json){
                completion(event, nil)
            }else{
                let error = response.hsError(message: "Could not update event")
                completion(nil, error)
            }
        }
    }
}
