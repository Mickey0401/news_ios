//
//  ChatRoomConversationsManager.swift
//  havr
//
//  Created by Personal on 6/29/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

class ChatRoomConversationsManager: NSObject {
    static var shared = ChatRoomConversationsManager()
    
    var chatConversations: [ChatRoomConversation] = []
    
    func getOrCreateConversation(for chatRoom: ChatRoom) -> ChatRoomConversation {
        for chatConversation in chatConversations {
            if chatConversation.chatRoom.id == chatRoom.id {
                return chatConversation
            }
        }
        
        let create = ChatRoomConversation.create(for: chatRoom, with: [])
        chatConversations.append(create)
        return create
    }
    
    func clear() {
        chatConversations.removeAll()
    }
}
