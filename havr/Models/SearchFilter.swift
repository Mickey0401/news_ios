//
//  SearchFilter.swift
//  havr
//
//  Created by Ismajl Marevci on 5/28/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import RealmSwift

class SearchFilter: Object {
    dynamic var id: Int = 0
    dynamic var fullName: String = ""
    dynamic var username: String = ""
    
    dynamic var minAge: Int = 13
    dynamic var maxAge: Int = 99
    dynamic var gender: String = "Other"
    dynamic var distance: Int = 999999
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    func store() {
        CacheManager.store(object: self)
    }
    
    static func get() -> SearchFilter?{
        return CacheManager.shared.objects(SearchFilter.self).first
    }
    
    static func reset(){
        let filter = SearchFilter()
        if let user = AccountManager.currentUser{
            if user.age < 18{
                filter.minAge = 13
                filter.maxAge = 17
            }else{
                filter.minAge = 18
                filter.maxAge = 99
            }
        }
        if let f = SearchFilter.get(){
            filter.gender = f.gender
            filter.distance = f.distance
        }
        filter.store()
    }
}
