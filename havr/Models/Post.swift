//
//  Post.swift
//  havr
//
//  Created by Personal on 5/23/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON
import AVFoundation

class Post: NSObject {
    var id: Int = 0
    var isStored: Bool = false
    var title: String = ""
    var postDescription: String = ""

    var interest: Interest? = Interest()
    var likesCount: Int = 0
    var postComment: Int = 0
    var createdDate: Date = Date()
    
    var author: User! = User()
    var owner: User! = User()
    var previousOwner: User? = nil
    
    var isLiked: Bool = false
    var lastComments = [Comment]()
    var isMainBroadCast: Bool = false
    
    var media: Media! = Media()
    
    func  isSaved() -> Bool  {
        return UserStore.shared.isSavedPost(id: id)
    }
    
    //Video
    var player = AVPlayer()
    var playerItem: AVPlayerItem?
    var isPlayingVideo: Bool{
        return player.isPlaying
    }
    
    static func create(from json: JSON) -> Post? {
        
        let post = json["post"]
        
        if let id = json["pk"].int, let title = post["title"].string, let createdDate = Date.create(from: post["created"].string), let user = User.create(from: post["author"]), let owner = User.create(from: json["owner"]), let description = post["description"].string, let interest = Interest.create(from: post["interest"]), let media = Media.create(from: post) {
            
            let p = Post()
            p.isStored = json["is_stored"].boolValue
            p.id = id
            p.title = title
            p.postDescription = description
            p.createdDate = createdDate
            p.author = user
            p.owner = owner
            
            if  let isLiked = json["is_liked"].bool {
                p.isLiked = isLiked
            }
            
            p.interest = interest
            
            p.likesCount = json["likes_count"].int ?? 0
            p.postComment = json["comments_count"].int ?? 0
            
            if let previous = User.create(from: json["prev_owner"]){
                p.previousOwner = previous
            }
            
            if let results = json["last_comments"].array{
                var array: [Comment] = []
                for item in results {
                    if let c = Comment.create(from: item) {
                        array.append(c)
                    }
                }
                p.lastComments = array.reversed()
            }
            
            p.media = media
            return p
        }
        
        return nil
    }
    
    func isReaction() -> Bool {
        
        if let interest = self.interest {
            return interest.id == 51
        }
        
        return false
    }
    
    func getImageUrl() -> URL? {
        return media.getImageUrl()
    }
    
    func getSourceUrl() -> URL? {
        return media.getUrl()
    }
    func getType() -> MediaType{
        if media.isVideo(){
            return .video
        }else if media.isGif(){
            return .gif
        }
        return .image
    }

    func isImage() -> Bool{
        return media.isImage()
    }
    
    func isGif() -> Bool {
        return media.isGif()
    }
    
    func isVideo() -> Bool {
        return media.isVideo()
    }
    
    func isMine() -> Bool {
        if let authorId = author?.id {
            return AccountManager.userId == authorId
        }
        return false
    }
    
    func isPromoted() -> Bool {
        guard let owner = owner else { return false }
        guard let author = author else { return false }
        
        return owner == author
    }
}

extension Post{
    static func == (lhs: Post, rhs: Post) -> Bool{
        return lhs.id == rhs.id
    }
}
