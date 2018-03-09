//
//  ResourcesManager.swift
//  havr
//
//  Created by Ismajl Marevci on 5/23/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import RealmSwift

class ResourcesManager : NSObject {
    
    static var userInterests = [UserInterest]()
    
    static var userKeywords: [UserKeywordInterest]? = nil
    static var keywordAsParam: String? = nil
    
    static var allInterests: [UserInterest] = []
    
    static var activeInterests: [UserInterest] {
        return userInterests.filter({ (item) -> Bool in
            return item.isActive
        }).map({ (item) -> UserInterest in
            return item
        })
    }
    
    static var activeInterestsWithoutSaved: [UserInterest] {
        return userInterests.filter({ $0.isActive && !$0.isSaved() && !$0.isMoments() })
    }
    
    static var inactiveInterests: [UserInterest] {
        
        return userInterests.filter({ (item) -> Bool in
            return item.isActive == false
        }).map({ (item) -> UserInterest in
            return item
        })
    }
    
    static var trendingInterests = [UserInterest]()
    
    static func clear() {
        if userKeywords != nil {
            userKeywords!.removeAll()
        }
        keywordAsParam = nil
        userInterests.removeAll()
        allInterests.removeAll()
        trendingInterests.removeAll()
    }
}
