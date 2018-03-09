//
//  BroadcastAPI.swift
//  havr
//
//  Created by Arben Pnishi on 6/11/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class BroadcastAPI: NSObject {
    static func getBroadcasts(page: Int, textToSearch: String? = nil, completion: @escaping (([BroadcastPost]?,Pagination?,HSError?) -> Void)) {
        var parameters: Parameters = [
            "page": page,
            ]
        if let text = textToSearch{
            parameters["text"] = text.lowercased()
        }
        
        let request = RequestREST(resource: "broadcast/", method: .get, parameters: parameters)
        
        ServiceREST.request(with: request) { (response) in
            if let results = response.json["results"].array, let pagination = Pagination.create(from: response.json["pagination"]) {
                var broadcasts: [BroadcastPost] = []
                
                for item in results {
                    if let n = BroadcastPost.create(from: item) {
                        broadcasts.append(n)
                    }
                }
                completion(broadcasts, pagination, nil)
            } else {
                completion(nil, nil, response.hsError(message: "Something went wrong"))
            }
        }
    }
}
//MARK: - get keyword based on user interests
extension BroadcastAPI {
    static func getKeywords(completion: @escaping ([UserKeywordInterest], HSError?) -> Void) {
        let request = RequestREST(resource: "broadcast/keywords/", method: .get, parameters: nil, headers: nil)
        ServiceREST.request(with: request) { (response) in
            var result = [UserKeywordInterest]()
            guard let results = response.json.dictionary else {
                completion(result, HSError(message: "Can't serialize data", code: 38))
                return
            }
            let keys = results.keys.sorted()
            for key in keys {
                if let model = UserKeywordInterest.decode(response.json[key]) {
                    result.append(model)
                }
            }
            completion(result, nil)
        }
    }
}
