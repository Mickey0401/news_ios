//
//  EventPost.swift
//  havr
//
//  Created by Personal on 7/10/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON
import Alamofire

class EventPost: Object {
    
    dynamic var id: Int = 0
    dynamic var eventId: Int = 0
    dynamic var title: String = "."
    dynamic var text: String = "."
    dynamic var hasMedia: Bool = false
    dynamic var media: Media? = Media()
    dynamic var created: Date = Date()
    dynamic var isAnon: Bool = false
    dynamic var isOwner: Bool = false
    dynamic var isLiked: Bool = false
    dynamic var likesCount: Int = 0
    dynamic var commentsCount: Int = 0
    
    dynamic var user: User? = User()
    
    static func create(from json: JSON, event eventId: Int) -> EventPost? {
        
        if let id = json["id"].int, let title = json["title"].string, let text = json["text"].string, let created = Date.create(from: json["created"].string), let media = Media.create(fromPostEvent: json["media"]) {
            
            let e = EventPost()
            e.id = id
            e.title = title
            e.text = text
            e.created = created
            
                
            e.hasMedia = true
            e.media = media
        
            e.likesCount = json["likes_count"].int ?? 0
            e.commentsCount = json["comments_count"].int ?? 0
            e.isLiked = json["is_liked"].bool ?? false
            e.eventId = eventId
            
            e.isAnon = json["is_anon"].bool ?? true
            
            if !e.isAnon {
                e.user = User.create(from: json["owner"])
            }
            
            return e
        }
        
        return nil
    }
    
    static func create(from media: Media, event id: Int) -> EventPost {
        let event = EventPost()
        event.media = media
        event.hasMedia = true
        event.eventId = id
        
        event.user = AccountManager.currentUser
        event.isOwner = true
        
        return event
    }
    
    
    var toParameters: Parameters  {
        var parameters: Parameters = [
            "title" : self.title,
            "text" : self.text,
            "is_anon" : self.isAnon
        ]
        
        if hasMedia, let media = self.media {
            
            var mediaParameters: Parameters = [
                "url" : media.getUrl().absoluteString,
                "width" : media.width.description,
                "height" : media.height.description
            ]
            
            if media.isVideo() {
                mediaParameters["length"] = Int(media.videoLength)
            }
            
            parameters["media"] = mediaParameters
        }
        
        
        return parameters
    }
    
    var duration: TimeInterval {
        
        if let media = self.media, media.isVideo() && media.videoLength > 0 {
            return media.videoLength
        }
        
        return 5.0
    }
    
}
/*
 "title": "Test title",
 "text": "Main text. Text. Test. Text. Test.",
 "media": {
 "url": "http://test.video.com/video1.mkv",
 "width": 1280,
 "height": 1024,
 "length": 240
 },
 "is_anon": true
 
 
"id": 1,
"title": "Test title",
"text": "Main text. Text. Test. Text. Test.",
"media": {
    "url": "http://test.video.com/video1.mkv",
    "width": 1280,
    "height": 1024,
    "length": 240
},
"created": "2017-07-10T11:38:43.876569Z",
"is_anon": true,
"is_owner": true,
"is_liked": false,
"likes_count": 0,
"comments_count": 0

 
 {
 "media" : {
 "length" : null,
 "url" : "https:\/\/havr.s3.amazonaws.com\/PWDJTEHqOI1bXRLEOSLB3H7UWMuBArMvB0JbWKlvY2brIrMe.jpg",
 "width" : 360,
 "height" : 640
 },
 "likes_count" : 0,
 "id" : 2,
 "text" : ".",
 "created" : "2017-07-11T21:07:06.107007Z",
 "is_owner" : true,
 "owner" : {
 "username" : "herolind",
 "pk" : 7,
 "full_name" : "Herolind",
 "connection_status" : null,
 "photo" : "https:\/\/havr.s3.amazonaws.com\/uHkQrGcBJaJW5zXtWXe8FoBNTO4ieHzep6E0XmbJHEJi0GUg.jpg"
 },
 "title" : ".",
 "is_liked" : false,
 "is_anon" : false,
 "comments_count" : 0
 }
 
 
 */

