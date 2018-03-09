//
//  ChatRoomPostsManager.swift
//  havr
//
//  Created by Ismajl Marevci on 7/8/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

class ChatRoomPostsManager: NSObject {
    static var shared = ChatRoomPostsManager()
    
    var chatRoomPosts: [ChatRoomPostComments] = []
    
    func getOrCreatePost(for posti: ChatRoomPost) -> ChatRoomPostComments {
        for post in chatRoomPosts {
            if post.post.id == posti.id {
                return post
            }
        }
        
        let create = ChatRoomPostComments.create(for: posti, with: [])
        chatRoomPosts.append(create)
        return create
    }
    
    func clear() {
        chatRoomPosts.removeAll()
    }
}
