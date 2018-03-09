//
//  ConversationManager.swift
//  havr
//
//  Created by Personal on 7/8/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

class ConversationManager: NSObject {
    static var shared = ConversationManager()
    
    var conversationsMessages: [ConversationMessages] = []
    
    func getOrCreate(with conversation: Conversation) -> ConversationMessages {
        for c in self.conversationsMessages {
            if c.conversation.id == conversation.id {
                return c
            }
        }
        
        //create and store
        let a = ConversationMessages.create(conversation: conversation, messages: [], pagination: Pagination())
        conversationsMessages.append(a)
        return a
    }
    
    
    func conversation(with userId: Int) -> Conversation? {
        for c in conversationsMessages {
            if c.conversation.user.id == userId {
                return c.conversation
            }
        }
        
        return nil
    }
    
    func conversation(withChannelId id: Int) -> Conversation? {
        for c in conversationsMessages {
            if c.conversation.id == id {
                return c.conversation
            }
        }
        
        return nil
    }
    
    func delete(conversationId id: Int) {
        for (index,c) in conversationsMessages.enumerated() {
            if c.conversation.id == id {
                conversationsMessages.remove(at: index)
            }
        }
    }
    
    func clear() {
        conversationsMessages.removeAll()
    }
}
