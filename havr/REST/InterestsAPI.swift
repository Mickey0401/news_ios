//
//  InterestsAPI.swift
//  havr
//
//  Created by Personal on 5/23/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class InterestsAPI: NSObject {
    static func getAll(completion: @escaping (([UserInterest]?, HSError?) -> Void)) {
        
        let parameters: Parameters = [
            "page_size" : 100
        ]
        
        let request = RequestREST(resource: "interests/choices/", method: .get, parameters: parameters)
        
        ServiceREST.request(with: request) { (response) in
            if let jsonInterests = response.json["results"].array, response.isHttpSuccess {
                var interests = [UserInterest]()
                
                jsonInterests.forEach({ (item) in
                    if let i = Interest.create(from: item) {
                        let u = UserInterest.create(from: i)
                        interests.append(u)
                    }
                })
                
                completion(interests, nil)
            } else {
                let error = response.hsError(message: "Could not load interests.")
                completion(nil, error)
            }
        }
    }
    
    static func getMine(completion: @escaping (([UserInterest]?, HSError?) -> Void)) {
        
        let request = RequestREST(resource: "interests/", method: .get, parameters: nil)
        
        ServiceREST.request(with: request) { (response) in
            if let jsonInterests = response.json.array, response.isHttpSuccess {
                var interests = [UserInterest]()
                
                jsonInterests.forEach({ (item) in
                    if let i = UserInterest.create(from: item) {
                        interests.append(i)
                    }
                })
                
                completion(interests, nil)
            } else {
                let error = response.hsError(message: "Could not load interests.")
                completion(nil, error)
            }
        }
    }
    static func getInterest(for userId: Int, completion: @escaping (([UserInterest]?, HSError?) -> Void)) {
        
        let request = RequestREST(resource: "accounts/\(userId)/interests/", method: .get, parameters: nil)
        
        ServiceREST.request(with: request) { (response) in
            if let jsonInterests = response.json.array, response.isHttpSuccess {
                var interests = [UserInterest]()
                
                jsonInterests.forEach({ (item) in
                    if let i = UserInterest.create(from: item) {
                        interests.append(i)
                    }
                })
                
                completion(interests, nil)
            } else {
                let error = response.hsError(message: "Could not load interests.")
                completion(nil, error)
            }
        }
    }
    

    
    static func getTrending(completion: @escaping (([UserInterest]?, HSError?) -> Void)) {
        
        let request = RequestREST(resource: "interests/trending/", method: .get, parameters: nil)
        
        ServiceREST.request(with: request) { (response) in
            if let jsonInterests = response.json["results"].array, response.isHttpSuccess {
                var interests = [UserInterest]()
                
                jsonInterests.forEach({ (item) in
                    let dict: JSON = ["interest" : item]
                    if let i = UserInterest.create(from: dict) {
                        interests.append(i)
                    }
                })
                
                completion(interests, nil)
            } else {
                let error = response.hsError(message: "Could not load trending interests.")
                completion(nil, error)
            }
        }
    }
    
    static func addInterest(name: String, completion: @escaping ((Bool, HSError?) -> Void)) {
        let parameters: Parameters = [
            "name" : name
        ]
        
        let request = RequestREST(resource: "interests/", method: .put, parameters: parameters)
        
        ServiceREST.request(with: request) { (response) in
            if response.isHttpSuccess{
                completion(true, nil)
            }else{
                let error = response.hsError(message: "Could not add interest.")
                completion(false, error)
            }
        }
    }
    
    static func addInterests(interests: [UserInterest], completion: @escaping ((Bool, HSError?) -> Void)) {
        var names: [Parameters] = []
        for interest in interests {
            let name: Parameters = [
                "name" : interest.item!.name
            ]
            if interest.item!.name == "saved" { continue }
            names.append(name)
        }
        let parameters: Parameters = [
            "all" : names
        ]
        
        let request = RequestREST(resource: "interests/", method: .put, parameters: parameters)
        
        ServiceREST.request(with: request) { (response) in
            if response.isHttpSuccess{
                completion(true, nil)
            }else{
                let error = response.hsError(message: "Could not add interest.")
                completion(false, error)
            }
        }
    }
    
    static func deleteInterest(name: String, completion: @escaping ((Bool, HSError?) -> Void)) {
        
        let parameters: Parameters = [
            "name" : name
        ]
        let request = RequestREST(resource: "interests/", method: .delete, parameters: parameters)
       
        ServiceREST.request(with: request) { (response) in
            if response.isHttpSuccess{
                completion(true, nil)
            }else{
                let error = response.hsError(message: "Could not delete interest.")
                completion(false, error)
            }
        }
    }
}
