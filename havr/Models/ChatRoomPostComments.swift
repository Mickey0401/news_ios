//
//  ChatRoomPostComments.swift
//  havr
//
//  Created by Ismajl Marevci on 7/8/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON

class ChatRoomPostComments: NSObject {
    var post: ChatRoomPost!
    var comments: [ChatRoomPost] = []
    var pagination: Pagination!
    var created: Date!
    
    var chatRoomPostModel = ExploreConversationModelView()
    
    static func create(for post: ChatRoomPost, with comments: [ChatRoomPost]) -> ChatRoomPostComments {
        let o = ChatRoomPostComments()
        o.post = post
        o.comments.append(contentsOf: comments)
        o.pagination = Pagination()
        o.created = Date()
        
        return o
    }
    
    @discardableResult
    func addComments(comments: [ChatRoomPost]) -> [ChatRoomPost] {
        var commentsAdded: [ChatRoomPost] = []
        
        for comment in comments {
            if !self.comments.contains(where: { $0.id == comment.id}) {
                commentsAdded.append(comment)
            }
        }
//        let array = commentsAdded + self.comments
        self.comments += commentsAdded
        
        chatRoomPostModel.mergePosts(posts: self.comments)
        
        return self.comments
    }
    
    func reloadPosts() {
        chatRoomPostModel.mergePosts(posts: self.comments)
    }
    
    func delete(comment: ChatRoomPost) {
        for (index,c) in comments.enumerated() {
            if c.id == comment.id {
                self.comments.remove(at: index)
            }
        }
    }
}
