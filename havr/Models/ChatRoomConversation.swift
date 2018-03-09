//
//  ChatRoomConversation.swift
//  havr
//
//  Created by Personal on 6/29/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON

class ChatRoomConversation: NSObject {
    var chatRoom: ChatRoom!
    var posts: [ChatRoomPost] = []
    var pagination: Pagination!
    var created: Date!
    
    var chatRoomPostModel = ExploreConversationModelView()
    
    static func create(for chatRoom: ChatRoom, with posts: [ChatRoomPost]) -> ChatRoomConversation {
        let o = ChatRoomConversation()
        o.chatRoom = chatRoom
        o.posts.append(contentsOf: posts)
        o.pagination = Pagination()
        o.created = Date()
        
        return o
    }
    
    @discardableResult
    func addPosts(posts: [ChatRoomPost]) -> [ChatRoomPost] {
        var postAdded: [ChatRoomPost] = []
        
        for post in posts {
            if !self.posts.contains(where: { $0.id == post.id}) {
                postAdded.append(post)
            }
        }
//        let array = self.posts
        self.posts += postAdded
        reloadPosts()
        
        return self.posts
    }
    
    func reloadPosts() {
        chatRoomPostModel.mergePosts(posts: self.posts)
    }
    
    func delete(post: ChatRoomPost) {
        for (index,p) in self.posts.enumerated() {
            if p.id == post.id {
                self.posts.remove(at: index)
            }
        }
    }
}
