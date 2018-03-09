//
//  EventPostsManager.swift
//  havr
//
//  Created by Personal on 7/10/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import Foundation

class EventPostsManager: NSObject {
    static var shared = EventPostsManager()
    
    var eventsPosts: [EventPosts] = []
    
    func getOrCreate(for event: Event) -> EventPosts {
        for e in eventsPosts {
            if e.event.id == event.id {
                return e
            }
        }
        
        let e = EventPosts()
        e.event = event
        
        eventsPosts.append(e)
        
        return e
    }
    
    func clear() {
        eventsPosts.removeAll()
    }
}
