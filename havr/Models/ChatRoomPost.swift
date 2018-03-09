//
//  ChatRoomPost.swift
//  havr
//
//  Created by Personal on 6/29/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

class ChatRoomPost: Object {

    dynamic var id: Int = 0
    dynamic var media: Media? = nil
    dynamic var likesCount: Int = 0
    dynamic var title: String = ""
    dynamic var text: String = ""
    dynamic var date: Date = Date()
    dynamic var isOwner: Bool = false
    dynamic var user: User? = User()
    dynamic var isLiked: Bool = false
    dynamic var isAnon: Bool = false
    dynamic var hasMedia: Bool = false
    dynamic var commentsCount: Int = 0
    
    static func create(from json: JSON) -> ChatRoomPost? {
        if let id = json["id"].int, let isAnon = json["is_anon"].bool, let date = Date.create(from: json["created"].string), let isOwner = json["is_owner"].bool, let isLiked = json["is_liked"].bool, let commentsCount = json["comments_count"].int, let likedCount = json["likes_count"].int {
            
            let cp = ChatRoomPost()

            if isAnon == false {
                if let user = User.create(from: json["owner"]) {
                    cp.user = user
                }else {
                    return nil
                }
            }
            
            if let title = json["title"].string{
                cp.title = title
            }
            
            if let text = json["text"].string{
                cp.text = text
            }
            
            if let media = Media.create(fromPostEvent: json["media"]){
                cp.media = media
            }
            
            cp.id = id
            cp.isAnon = isAnon
            cp.date = date
            cp.isOwner = isOwner
            cp.isLiked = isLiked
            cp.commentsCount = commentsCount
            cp.likesCount = likedCount

            return cp
        }
        return nil
    }
    
    static func create(comment json: JSON) -> ChatRoomPost? {
        if let id = json["id"].int, let isAnon = json["is_anon"].bool, let date = Date.create(from: json["created"].string), let isOwner = json["is_owner"].bool, let isLiked = json["is_liked"].bool, let likedCount = json["likes_count"].int {
            
            let cp = ChatRoomPost()
            
            if isAnon == false {
                if let user = User.create(from: json["owner"]) {
                    cp.user = user
                }else {
                    return nil
                }
            }
            
            if let text = json["text"].string{
                cp.text = text
            }
            
            if let media = Media.create(fromPostEvent: json["media"]){
                cp.media = media
            }
            
            cp.id = id
            cp.isAnon = isAnon
            cp.date = date
            cp.isOwner = isOwner
            cp.isLiked = isLiked
            cp.likesCount = likedCount
            
            return cp
        }
        return nil
    }
    
    func isMine() ->  Bool {
        if let user = user {
            if user.id == AccountManager.currentUser?.id {
                return true
            }
        }
        if isOwner {
            return true
        }
        return false
    }
    
    func getCellIdentifier() -> String{
        if isMine() {
            
            return "ECSenderTextTableCell"
        }else {
           return "ECReceiverTextTableCell"
        }
    }
    func getCommentCellIdentifier() -> String{
        if isMine() {
            if !hasMedia {
                return "ECSenderCommentTableCell"
            }
            return "ECSenderTextTableCell"
        }else {
            if !hasMedia {
                return "ECReceiverCommentTableCell"
            }
            return "ECReceiverTextTableCell"
        }
    }
    func getTime() -> String {
        let formater = DateFormatter()
        formater.timeStyle = .short
        
        return formater.string(from: date)
    }
}

extension ChatRoomPost {
    static func == (lhs: ChatRoomPost, rhs: ChatRoomPost) -> Bool{
        return lhs.id == rhs.id
    }
}

extension Array where Element: ChatRoomPost {
    func indexOf(post: ChatRoomPost) -> Int? {
        for (index,item) in self.enumerated() {
            if item == post {
                return index
            }
        }
        
        return nil
    }
}

