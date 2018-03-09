//
//  ExploreModelView.swift
//  havr
//
//  Created by Personal on 6/27/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import Foundation
import GoogleMaps

class ExploreModelView: NSObject {
    static var shared: ExploreModelView = ExploreModelView()
    
    var allChatRooms: [ChatRoom] = [] {
        didSet {
            chatRoomsChanged()
        }
    }
    
    var allEvents: [Event] = [] {
        didSet {
            eventsChanged()
        }
    }
    
    var allChatRoomsPagination = Pagination()
    var allEventsPagination = Pagination()
    
    // NONE MEMBER
    
    var noneMyChatRooms: [ChatRoom] = [] {
        didSet {
            noneMyChatEventsChanged()
        }
    }
    
    var noneMyEvents: [Event] = [] {
        didSet {
            noneMyChatEventsChanged()
        }
    }
    
    
    // MINE
    var myChatRooms: [ChatRoom] = [] {
        didSet {
            myChatEventsChanged()
        }
    }
    var myEvents: [Event] = [] {
        didSet {
            myChatEventsChanged()
        }
    }
    
    
    var myExplore: [MapObject] = [] {
        didSet {
            //reorder myexplore
            myExplore = myExplore.sorted(by: { (item, item2) -> Bool in
                if let item = item as? Event, let item2 = item2 as? Event {
                    return item.distance ?? 0 < item2.distance ?? 0
                } else if let item = item as? Event, let item2 = item2 as? ChatRoom {
                    return item.distance ?? 0 < item2.distance ?? 0
                } else if let item = item as? ChatRoom, let item2 = item2 as? Event {
                    return item.distance ?? 0 < item2.distance ?? 0
                } else if let item = item as? ChatRoom, let item2 = item2 as? ChatRoom {
                    return item.distance ?? 0 < item2.distance ?? 0
                } else {
                    return true
                }
            })
        }
    }
    
    var noneMyExlore: [MapObject] = [] {
        didSet {
            noneMyExlore = noneMyExlore.sorted(by: { (item, item2) -> Bool in
                if let item = item as? Event, let item2 = item2 as? Event {
                    return item.distance ?? 0 < item2.distance ?? 0
                } else if let item = item as? Event, let item2 = item2 as? ChatRoom {
                    return item.distance ?? 0 < item2.distance ?? 0
                } else if let item = item as? ChatRoom, let item2 = item2 as? Event {
                    return item.distance ?? 0 < item2.distance ?? 0
                } else if let item = item as? ChatRoom, let item2 = item2 as? ChatRoom {
                    return item.distance ?? 0 < item2.distance ?? 0
                } else {
                    return true
                }
            })
        }
    }
    
    
    var allMapObjects: [MapObject] {
        return myExplore + noneMyExlore
    }
    
    fileprivate func chatRoomsChanged() {
        myChatRooms = allChatRooms.filter { $0.isOwner == true }
        noneMyChatRooms = allChatRooms.filter { $0.isOwner == false }
        
        print("Chat Rooms Changed")
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ExploreModelViewChanged"), object: nil)
    }
    
    fileprivate func eventsChanged() {
        myEvents = allEvents.filter{ $0.isOwner == true }
        noneMyEvents = allEvents.filter { $0.isOwner == false }
        
        print("Events Changed")
    }
    
    fileprivate func myChatEventsChanged() {
        
        var items: [MapObject] = []
        
        myChatRooms.forEach { (item) in
            items.append(item)
        }
        
        myEvents.forEach { (item) in
            items.append(item)
        }
        
        myExplore = items
    }
    
    fileprivate func noneMyChatEventsChanged() {
        var items: [MapObject] = []
        
        noneMyChatRooms.forEach { (item) in
            items.append(item)
        }
        
        noneMyEvents.forEach { (item) in
            items.append(item)
        }
        
        noneMyExlore = items
    }
    
    func deleteChatRoom(chatroom id: Int) {
        for (index,c) in self.allChatRooms.enumerated() {
            if c.id == id {
                self.allChatRooms.remove(at: index)
            }
        }
    }
    
    func updateChatRoom(chatroom: ChatRoom) {
        for (index,c) in self.allChatRooms.enumerated() {
            if c.id == chatroom.id {
                self.allChatRooms[index] = chatroom
            }
        }
    }
    
    func addChatRoom(chatroom: ChatRoom) {
        self.allChatRooms.insert(chatroom, at: 0)
    }
    
    func updateEvent(event: Event) {
        for (index, e) in self.allEvents.enumerated() {
            if e.id == event.id {
                self.allEvents[index] = event
            }
        }
    }
    
    func addEvent(event: Event) {
        self.allEvents.insert(event, at: 0)
    }
    
    
    func getItem(for marker: GMSMarker) -> Any? {
        for item in allChatRooms {
            if let mk = item.marker, mk == marker {
                return item
            }
        }
        
        for item in allEvents {
            if let mk = item.marker, mk == marker {
                return item
            }
        }
        
        return nil
    }
}
