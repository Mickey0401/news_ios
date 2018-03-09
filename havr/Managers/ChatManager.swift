//
//  ChatManager.swift
//  havr
//
//  Created by Personal on 7/6/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

class ChatManager: NSObject {
    static var shared = ChatManager()
    
    fileprivate var recordingTimer: Timer?
    
    override init() {
        super.init()
        SocketManager.shared.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(networkChanged), name: Notification.Name(rawValue: "ReachabilityChangedNotification"), object: nil)
    }
    
    weak var chatsController: ChatsController?
    
    var conversations: [Conversation] = [] {
        didSet {
            updateBadge()
        }
    }
    
    weak var conversationController: ConversationController?
    
    func start() {
        loadConversations()
    }
    
    
    func getConversation(user id: Int, completion: @escaping ((Conversation?, HSError?) -> Void)) {
        ConversationAPI.getConversation(user: id, completion: completion)
    }
    
    func send(message: Message, conversation: Conversation, completion: @escaping ((Message, Success, ErrorMessage?) -> Void)) {
        if let conversation = self.conversations.contains(conversation: conversation.id) {
            conversation.lastMessage = message
            chatsController?.reorder()
            
            sendMessage(message: message, conversation: conversation, completion: completion)
        } else {
            conversation.lastMessage = message
            chatsController?.conversations.append(conversation)
            
            chatsController?.reorder()
            sendMessage(message: message, conversation: conversation, completion: completion)
        }
    }
    
    func resend(message: Message, conversation: Conversation, completion: @escaping ((Message, Success, ErrorMessage?) -> Void)) {
        sendMessage(message: message, conversation: conversation, completion: completion)
    }
    
    fileprivate func sendMessage(message: Message, conversation: Conversation, completion: @escaping ((Message, Success, ErrorMessage?) -> Void)) {
        message.messageStatus = .sending
        if message.hasMedia {
            if message.media.uploadStatus == .uploaded {
                self.sendSocket(message: message, conversation: conversation, completion: completion)
            } else {
                message.media.upload(completion: { (media, success, error) in
                    if success {
                        message.media.uploadStatus = .uploaded
                        self.sendSocket(message: message, conversation: conversation, completion: completion)
                    } else {
                        message.messageStatus = .failed
                        message.media.uploadStatus = .failed
                        completion(message, false, nil)
                    }
                })
            }
        } else {
            self.sendSocket(message: message, conversation: conversation, completion: completion)
        }
    }
    
    
    fileprivate func sendSocket(message: Message, conversation: Conversation, completion: @escaping ((Message, Success, ErrorMessage?) -> Void)) {
        if conversation.id == SocketManager.shared.conversationId {
            SocketManager.shared.sendMessage(message: message, completion: completion)
        } else {
            message.messageStatus = .failed
            completion(message, false, "")
        }
    }
    
    func networkChanged(notification: Notification) {
        if NetworkManager.isConnected && self.conversationController != nil {
            if SocketManager.shared.socket.isConnected == false {
               SocketManager.shared.reconnect()
            }
        }
    }
    
    func loadConversations(reset: Bool = true) {
        ConversationAPI.get(limit: 20, page: 1) {[weak self] (conversations, pagination, error) in
            guard let `self` = self else { return }
            if let conversations = conversations, let _ = pagination {
                if reset == true {
                    self.conversations.removeAll()
                }
                
                self.conversations = conversations
                self.chatsController?.tableView.reloadData()
            }
        }

    }
    
    func updateBadge() {
        var number = 0
        
        self.conversations.forEach { item in
            if item.unSeenCount > 0 {
                number += 1
            }
        }
        
        if number > 0 {
            TabBarController.shared?.messagesItem.badgeValue = number.description
        } else {
            TabBarController.shared?.messagesItem.badgeValue = nil
        }
    }
    
    func appEnterForeground() {
        loadConversations(reset: true)
        self.conversationController?.loadMessages()
    }
    
    func clear() {
        conversations.removeAll()
        self.chatsController?.tableView.reloadData()
    }
}

extension ChatManager: SocketManagerDelegate {
    func socketManager(sender: SocketManager, didStatus status: UserOnlineStatusTypes, of conversation: Conversation) {
        self.conversationController?.didReceiveStatus(status: status, conversation: conversation)
    }

    func socketManager(sender: SocketManager, didReceive message: Message) {
        if let conversation = self.conversations.contains(conversation: message.conversationId) {
            conversation.lastMessage = message
        } else {
            chatsController?.loadResource(reset: true)
        }
        
        self.chatsController?.reorder()
        
        self.conversationController?.didReceiveMessage(message: message)
        
    }
    func socketManager(sender: SocketManager, isConnected connected: Bool) {
        self.conversationController?.didChangeSocketConnectionStatus(connected: connected)
    }
    
    func socketManager(sender: SocketManager, didStartRecording conversation: Conversation) {
        self.conversationController?.didReceiveRecodingStatus(conversation: conversation, isRecording: true)
        
        recordingTimer?.invalidate()
        recordingTimer = nil
        
        let c = conversation
        
        recordingTimer = Timer.after(3, {
            self.conversationController?.didReceiveRecodingStatus(conversation: c, isRecording: false)
            self.recordingTimer = nil
        })
    }
    
    func socketManager(sender: SocketManager, didSeenAllMessages conversation: Conversation) {
        self.conversationController?.didSeenAllMessages(conversation: conversation)
    }
    
    func socketManager(sender: SocketManager, didReceiveTyping conversation: Conversation) {
        TypingsManager.shared.didReceiveTyping(conversation: conversation)
    }
}
