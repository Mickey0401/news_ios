//
//  SocketManager.swift
//  
//
//  Created by Personal on 7/7/17.
//
//

import UIKit
import Starscream
import SwiftyJSON
import AudioToolbox
import Alamofire

protocol SocketManagerDelegate: class {
    func socketManager(sender: SocketManager, isConnected connected: Bool)
    func socketManager(sender: SocketManager, didReceive message: Message)
    func socketManager(sender: SocketManager, didStatus status: UserOnlineStatusTypes, of conversation: Conversation)
    func socketManager(sender: SocketManager, didSeenAllMessages conversation: Conversation)
    func socketManager(sender: SocketManager, didStartRecording conversation: Conversation)
    func socketManager(sender: SocketManager, didReceiveTyping conversation: Conversation)
}

class SocketManager: NSObject {
    static var shared = SocketManager()
    
    var socket: WebSocket!
    
    weak var delegate: SocketManagerDelegate?
    
    fileprivate var conversation: Conversation!
    
    var conversationId: Int {
        return conversation.id
    }
    
    fileprivate let socketErrorMessage = "Your not connected on internet."
    
    fileprivate var connectedUsers: [String] = []
    
    fileprivate var completion: ((Success) -> Void)? = nil
    
    override init() {
        super.init()
    }
    
    deinit {
        socket.disconnect(forceTimeout: 0)
        socket.delegate = nil
    }
    
    func connect(conversation: Conversation, completion: ((Success) -> Void)? = nil) {
        
//        self.disconnect()
        
        self.conversation = conversation
        let url = URL(string: Constants.socketUrl + "chat/\(conversation.id)/\(AccountManager.userToken!)//")!
        
        socket = WebSocket(url: url, protocols: ["chat"])
        
        socket.delegate = self
        socket.connect()
    }
    
    func reconnect() {
        
        if socket == nil { return }
        if conversation == nil { return }
        
        if !self.socket.isConnected {
            
            print("Reconnecting socket")
            self.socket.connect()
        }
    }
    
    func disconnect() {
        self.socket?.disconnect()
    }
    
    func close() {
        self.disconnect()
        self.conversation = nil
    }
    
    func sendSeenEvent(completion: ((Success) -> Void)? = nil) {
        if !self.socket.isConnected {
            completion?(false)
            return
        }
        
        let parameters: Parameters = [
            "status" : 22,
            "identifier" : Helper.generateString(),
            "sender_id" : AccountManager.userId
        ]
        
        guard let stringJson = JSON(parameters).rawString() else {
            completion?(false)
            return
        }
        
        self.socket.write(string: stringJson) {
            completion?(true)
        }
    }
    
    func sendRecording(completion: ((Success) -> Void?)? = nil) {
        if !self.socket.isConnected {
            completion?(false)
            return
        }
        
        
        let parameters: Parameters = [
            "status" : 33,
            "identifier" : Helper.generateString(),
            "sender_id" : AccountManager.userId
        ]
        
        guard let stringJson = JSON(parameters).rawString() else {
            completion?(false)
            return
        }
        
        self.socket.write(string: stringJson) { 
            completion?(true)
        }
    }
    
    func sendTyping(completion: ((Success) -> Void)? = nil) {
        if !self.socket.isConnected {
            completion?(false)
            return
        }
        
        let parameters: Parameters = [
            "status" : 11,
            "identifier" : Helper.generateString(),
            "sender_id" : AccountManager.userId
        ]
        
        let json = parameters.json
        guard let stringJson = json.rawString() else { return }
        
        self.socket.write(string: stringJson) { 
            completion?(true)
        }
        
    }
    
    func sendMessage(message: Message, completion: ((Message,Success,ErrorMessage) -> Void)? = nil) {
        if !self.socket.isConnected {
            message.messageStatus = .failed
            completion?(message, true, self.socketErrorMessage)
            return
        }
        
        let parameters = message.getSocketParameters()
        
        let json = JSON(parameters)
        guard let stringJson = json.rawString() else { return }
        
        self.socket.write(string: stringJson) {
            completion?(message, true, "")
        }
    }
    
    
    fileprivate func handleMessage(json: JSON) {
        print("Received JSON")
        print(json)
        
        guard let conversation = self.conversation else { return  }
        
        //seen all messages
        if let status = json["status"].int, status == 22 {
            if let userId = json["sender_id"].int, AccountManager.userId != userId {
                delegate?.socketManager(sender: self, didSeenAllMessages: conversation)
            }
            return
        }
        
        if let status = json["status"].int, status == 33 {
            if let userId = json["sender_id"].int, AccountManager.userId != userId {
                delegate?.socketManager(sender: self, didStartRecording: conversation)
            }
            return
        }
        
        if let message = Message.create(json: json, conversation: conversation.id) {
            
            if !message.isMine {
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            }
            delegate?.socketManager(sender: self, didReceive: message)
            return
        }
        
        if let status = json["status"].int, status == 11 {
            if let userId = json["sender_id"].int, AccountManager.userId != userId {
                delegate?.socketManager(sender: self, didReceiveTyping: conversation)
            }
            return
        }
        
        if let status = UserOnlineStatusTypes(json: json) {
            delegate?.socketManager(sender: self, didStatus: status, of: conversation)
            return
        }
    }
}

// MARK: - WebSocketDelegate
extension SocketManager : WebSocketDelegate {
    func websocketDidConnect(socket: WebSocketClient) {
        console("Socket Connected: Conversation: \(conversation?.id ?? 0): Owner: \(conversation?.getTitle() ?? "No Title")")
        delegate?.socketManager(sender: self, isConnected: true)
        completion?(true)
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        console("Socket Disconnected: Conversation: \(conversation?.id ?? 0): Owner: \(conversation?.getTitle() ?? "No Title")")
        delegate?.socketManager(sender: self, isConnected: false)
        completion?(false)
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        let jsonMessage = JSON(parseString: text)
        handleMessage(json: JSON(parseJSON: jsonMessage.string ?? ""))
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
    }
}
