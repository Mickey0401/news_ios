//
//  NotificationsAPI.swift
//  havr
//
//  Created by Arben Pnishi on 6/10/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class NotificationsAPI: NSObject {
    static func getNotifications(page: Int, completion: @escaping (([APNotification]?,Pagination?,HSError?) -> Void)) {
        let parameters: Parameters = [
            "page": page,
            ]
        
        let request = RequestREST(resource: "notifications/", method: .get, parameters: parameters)
        
        ServiceREST.request(with: request) { (response) in
            if let results = response.json["results"].array, let pagination = Pagination.create(from: response.json["pagination"]) {
                var connections: [APNotification] = []
                
                for item in results {
                    if let n = APNotification.create(from: item) {
                        connections.append(n)
                    }
                }
                completion(connections, pagination, nil)
            } else {
                completion(nil, nil, response.hsError(message: "Something went wrong"))
            }
        }
    }
}
