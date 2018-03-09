//
//  UserStatus.swift
//  havr
//
//  Created by Personal on 8/22/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

enum UserOnlineStatusTypes: Int {
    case online = 0
    case recently = 1
    case daysAgon = 3
    case month = 7
    case whileAgon = 30
    
    init?(json: JSON) {
        guard let lastSeen = json["other_user_last_seen_at"].int else { return nil }
        guard let status = UserOnlineStatusTypes.init(rawValue: lastSeen)  else { return nil }
        
        self = status
    }
    
    var description: String {
        switch self {
        case .online:
            return "Online"
        case .recently:
            return "last seen recently"
        case .daysAgon:
            return "last seen days ago"
        case .month:
            return "last seen this month"
        case .whileAgon:
            return "last seen a while ago"
        }
    }
}

/*
    0 - online
    1 - last seen recently - from 1 min to 3 days ago
    3 - last seen days ago - from 3 days to 7 days ago
    7 - last seen this month - from 7 days to 1 month
    30 - last seen a while ago - more than 1 month ago
 */
