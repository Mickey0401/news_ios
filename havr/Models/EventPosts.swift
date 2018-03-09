//
//  EventsPosts.swift
//  havr
//
//  Created by Personal on 7/10/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import Foundation
import RealmSwift

class EventPosts: NSObject {
    var event: Event!
    var posts: [EventPost] = []
    
    var pagination = Pagination()
    
    var fetchedPosts: Bool = false
}
