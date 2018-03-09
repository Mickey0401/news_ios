//
//  Message.swift
//  havr
//
//  Created by Personal on 7/6/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON
import Alamofire

enum MessageTypes: Int {
    case text = 0
    case photo = 1
    case video = 2
    case audio = 3
}

enum MessageStatus: Int {
    case created
    case sending
    case sent
    case failed
}

class Message: Object {
    dynamic var id: Int = 0
    dynamic var createdAt: Date = Date()
    dynamic var isSeen: Bool = false
    dynamic var conversationId: Int = 0
    dynamic var senderId: Int = 0
    
    dynamic var text: String = ""
    dynamic var identifier: String = ""
    dynamic var hasMedia: Bool = false
    dynamic var media: Media! = Media()
    
    private dynamic var status: Int = 0
    
    var messageStatus: MessageStatus {
        get {
            return MessageStatus(rawValue: status) ?? MessageStatus.created
        }
        set {
            status = newValue.rawValue
        }
    }
    
    static func create(json: JSON, conversation id: Int) -> Message? {
        
        if  let createdAt = Date.create(from: json["create_date"].string), let senderId = json["sender_id"].int {
            
            let m = Message()
            m.id = 0
            m.createdAt = createdAt
            m.conversationId = id
            m.senderId = senderId
            m.text = json["text"].string ?? ""
            
            if let media = Media.create(from: json) {
                m.media = media
                m.hasMedia = true
            }
            
            m.isSeen = json["is_seen"].bool ?? false
            m.messageStatus = .sent
            m.identifier = json["identifier"].string ?? Helper.generateString(length: 48)
            m.messageStatus = .sent
            return m
        }
        
        return nil
    }
    
    func getImageUrl() -> URL? {
        return media?.getImageUrl()
    }
    
    var isMine: Bool {
        return senderId == AccountManager.currentUser!.id
    }
    
    static func create(content: String, conversation id: Int) -> Message {
        let m = Message()
        m.text = content
        m.senderId = AccountManager.currentUser!.id
        m.createdAt = Date()
        m.conversationId = id
        m.identifier = Helper.generateString(length: 48)
        m.messageStatus = .created
        return m
    }
    
    static func create(image: UIImage, conversation id: Int) -> Message {
        let m = Message()
        m.text = ""
        m.senderId = AccountManager.currentUser!.id
        m.createdAt = Date()
        m.conversationId = id
        m.identifier = Helper.generateString(length: 48)
        m.messageStatus = .created
        
        m.media = Media.create(for: image)
        m.hasMedia = true
        return m
    }
    
    static func create(audioMedia media: Media, conversation id: Int) -> Message {
        let m = Message()
        m.text = ""
        m.senderId = AccountManager.currentUser!.id
        m.createdAt = Date()
        m.conversationId = id
        m.identifier = Helper.generateString(length: 48)
        m.messageStatus = .created
        
        m.media = media
        m.hasMedia = true
        return m
    }
    
    
    func getCellIdentifier() -> ConversationTableCellIdentifier {
        if isMine {
            if hasMedia {
                if media.isAudio() {
                    return .senderVoiceTableCell
                } else {
                    return .senderImageTableCell
                }
            } else {
                return .senderTextTableCell
            }
        } else {
            if hasMedia {
                if media.isAudio() {
                    return .receiverVoiceTableCell
                } else {
                    return .receiverImageTableCell
                }
            } else {
                return .receiverTextTableCell
            }
        }
    }
    
    func getHeight() -> CGFloat {
        if hasMedia {
            if media.isAudio() {
                if isMine {
                    return 70
                }
                return 70
            }
            return 280
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    func getDescription() -> String {
        if hasMedia {
            if media.isVideo() {
                return "sent video"
            } else if media.isAudio() {
                return "sent audio"
            } else if media.isGif() {
                return "sent GIF"
            } else if media.isImage() {
                return "sent image"
            } else {
                return "sent attachment"
            }
        } else {
            return text
        }
    }
    
    func getTime() -> String {
        return createdAt.toHHMM
    }
    
    func getSocketParameters() -> Parameters {
        if hasMedia {
            var parameters: Parameters = [
                "content" : media.getUrl().absoluteString,
                "height" : media.height,
                "width" : media.width,
                "identifier" : identifier,
                "content_type" : messageType.rawValue
            ]
            
            if media.isVideo() || media.isAudio() {
                parameters["length"] = media.videoLength
            }
            
            return parameters
        } else {
            return [
                "text" : text,
                "identifier" : identifier
            ]
        }
    }
    
    var messageType: MessageTypes {
        if hasMedia {
            if media.isAudio() {
                return MessageTypes.audio
            } else if media.isVideo() {
                return MessageTypes.video
            } else if media.isImage() || media.isGif() {
                return MessageTypes.photo
            } else {
                return MessageTypes.text
            }
        } else {
            return MessageTypes.text
        }
    }
    
    
    override static func primaryKey() -> String? {
        return "identifier"
    }
}

extension Message{
    static func == (lhs: Message, rhs: Message) -> Bool{
        return lhs.identifier == rhs.identifier
    }
}

extension Array where Element: Message {
    func indexOf(message: Message) -> Int? {
        for (index,m) in self.enumerated() {
            if m == message {
                return index
            }
        }
        
        return nil
    }
}
