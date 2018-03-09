//
//  UserInterest.swift
//  havr
//
//  Created by Personal on 5/23/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

class UserInterest: Object {
    dynamic var isActive: Bool = false
    dynamic var isSelected: Bool = false
    dynamic var item: Interest? = Interest()
    
    static func create(from json: JSON) -> UserInterest? {
        if let interest = Interest.create(from: json["interest"]) {
            
            let u = UserInterest()
            if let isActive = json["is_active"].bool{
                u.isActive = isActive
            }
            u.item = interest
            return u
        }
        return nil
    }
    
    static func create(from interest: Interest) -> UserInterest{
        let u = UserInterest()
        u.item = interest
        return u
    }
    
    func isSaved() -> Bool {
        if let item = self.item {
            return item.id == 64
        }
        return false
    }
    
    func isMoments() -> Bool {
        if let item = self.item {
            return item.id == 65
        }
        return false
    }
    
    func isReaction() -> Bool{
        if let item = self.item{
            return item.id == 51
        }
        return false
    }
}

extension UserInterest{
    static func == (lhs:UserInterest, rhs:UserInterest) -> Bool{
        return lhs.item!.id == rhs.item!.id
    }
}
