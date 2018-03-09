//
//  ConversationMessages.swift
//  havr
//
//  Created by Personal on 7/8/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

class ConversationMessages: NSObject {
    var conversation: Conversation!
    var messages: [Message] = []
    
    var pagination: Pagination = Pagination()
    
    var conversationMessage = MessagesModelView()
    
    static func create(conversation: Conversation, messages: [Message], pagination: Pagination) -> ConversationMessages {
        let c = ConversationMessages()
        c.conversation = conversation
        c.messages = messages
        c.pagination = pagination
        
        return c
    }
    
    func mergeMessages(messages: [Message]) {
        for message in messages {
            if let index = self.messages.indexOf(message: message) {
                self.messages[index] = message
            } else {
                self.messages.append(message)
            }
        }
        
        self.messages = self.messages.sorted(by: {$0.createdAt.timeIntervalSince1970 < $1.createdAt.timeIntervalSince1970})
    }
    
    @discardableResult
    func markSeenAllMessages() -> Bool {
        var value = false
        for m in messages where m.isMine && !m.isSeen {
            m.isSeen = true
            value = true
        }
        
        return value
    }
}
