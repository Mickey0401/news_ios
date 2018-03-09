//
//  MessagesModelView.swift
//  havr
//
//  Created by Personal on 7/8/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

enum ConversationTableCellIdentifier: String {
    case senderImageTableCell = "SenderImageTableCell"
    case receiverTextTableCell = "ReceiverTextTableCell"
    
    case senderTextTableCell = "SenderTextTableCell"
    case receiverImageTableCell = "ReceiverImageTableCell"
    
    case senderVoiceTableCell = "SenderVoiceTableCell"
    case receiverVoiceTableCell = "ReceiverVoiceTableCell"
    
    case senderImageWithoutStatusTableCell = "SenderImageWithoutStatusTableCell"
    case senderTextWithoutStatusTableCell = "SenderTextWithoutStatusTableCell"
}

fileprivate class MessageModel {
    var message: Message
    var cellIdentifier: ConversationTableCellIdentifier!
    
    init(message: Message, cellIdentifier: ConversationTableCellIdentifier) {
        self.message = message
        self.cellIdentifier = cellIdentifier
    }
}

fileprivate class MessageModelSection {
    var messages: [MessageModel] = []
    var section: Int = 0
    var title: String {
        return messages.first?.message.createdAt.toChat ?? ""
    }
    
    func contains(message: Message) -> Bool {
        for m in self.messages {
            let v = Calendar.current.isDate(m.message.createdAt, inSameDayAs: message.createdAt)
            if v == true { return true }
        }
        
        return false
    }
    
    @discardableResult
    func addMessage(message: Message) -> IndexPath {
        let lastMessage = self.messages.first
        
        var identifier = message.getCellIdentifier()
//        if let lastMessage = lastMessage, lastMessage.message.isMine, message.isMine  {
//            
//        }
        
        let model = MessageModel(message: message, cellIdentifier: identifier)
        
        self.messages.insert(model, at: 0)
        return IndexPath(item: 0, section: section)
    }
    
    func insertMessage(message: Message) -> IndexPath {
        let identifier = message.getCellIdentifier()
        let model = MessageModel(message: message, cellIdentifier: identifier)
        
        self.messages.insert(model, at: 0)
        return IndexPath(item: 0, section: section)
    }
}

class MessagesModelView: NSObject {
    
    fileprivate var sections: [MessageModelSection] = []
    
    fileprivate var messages: [Message] = []
    
    var lastMessage: Message? {
        if let section = sections.last, let last = section.messages.last {
            return last.message
        }
        return nil
    }
    
    func insertNewMessage(message: Message) -> (index: IndexPath, isNewSection: Bool) {
        
        if let section = sections.filter({ (item) -> Bool in
            return item.contains(message: message)
        }).first {
            return (section.insertMessage(message: message), false)
        } else {
            let newSection = MessageModelSection()
            self.sections.insert(newSection, at: 0)
            newSection.section = 0
            
            return (newSection.insertMessage(message: message), true)
        }
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
        
        generateSections()
    }
    
    fileprivate func generateSections() {
        self.sections.removeAll()
        
        var sections : [MessageModelSection] = []
        
        for m in self.messages {
            if let section = sections.filter({ (item) -> Bool in
                return item.contains(message: m)
            }).first {
                section.addMessage(message: m)
            } else {
                let newSection = MessageModelSection()
                newSection.addMessage(message: m)
                sections.insert(newSection, at: 0)
            }
        }
        
        self.sections = sections
    }
    
    func numberOfSections() -> Int {
        return sections.count
    }
    
    func numberOfItems(in section: Int) -> Int {
        return sections[section].messages.count
    }
    
    func titleAtSection(section: Int) -> String {
        return sections[section].title
    }
    
    func cellForRow(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        
        let messageModel = self.sections[indexPath.section].messages[indexPath.item]
        
        let cell: UITableViewCell!
        
        if messageModel.message.hasMedia && messageModel.message.media.isAudio() {
            cell = tableView.dequeueVoiceTableCell(identifier: messageModel.cellIdentifier.rawValue, indexPath: indexPath)
            
            if let cell = cell as? VoiceTableCell {
                cell.message = messageModel.message
//                cell.setupCorners(cornerType: self.getShapes(indexPath))
            }
            
        } else {
            cell = tableView.dequeueConversationMessageTableCell(identifier: messageModel.cellIdentifier.rawValue, indexPath: indexPath)
            
            if let cell = cell as? ConversationTableCell {
                cell.message = messageModel.message
                cell.setupCorners(cornerType: self.getShapes(indexPath))
            }
        }
        
        return cell
    }
    
    func getShapes(_ indexPath: IndexPath) -> UIRectCorner {
        let messageModel = self.sections[indexPath.section].messages[indexPath.item]
        var nextMsgModel: MessageModel? = nil
        var prevMsgModel: MessageModel? = nil
        
        if (self.sections[indexPath.section].messages.count > indexPath.item + 1) {
            nextMsgModel = self.sections[indexPath.section].messages[indexPath.item + 1]
        }
        
        if (indexPath.item != 0) {
            prevMsgModel = self.sections[indexPath.section].messages[indexPath.item - 1]
        }
        
        var topLeft: Bool = false
        var topRight: Bool = false
        var bottomLeft: Bool = false
        var bottomRight: Bool = false
        
        if (messageModel.message.isMine) {
            topLeft = true
            bottomLeft = true
            topRight = false
            
            if (prevMsgModel == nil) {
                topLeft = false
            }
            
            if (((prevMsgModel != nil) && (prevMsgModel?.message.isMine == false))) {
                bottomRight = true
            }
        }
        else {
            topRight = true
            bottomRight = true
            topLeft = false
            
            if (((prevMsgModel != nil) && (prevMsgModel?.message.isMine == true))) {
                bottomLeft = true
            }
        }
        
        var retCorner = UIRectCorner()
        
        if (topLeft) {
            retCorner.insert(UIRectCorner.topLeft)
        }
        
        if (topRight) {
            retCorner.insert(UIRectCorner.topRight)
        }
        
        if (bottomLeft) {
            retCorner.insert(UIRectCorner.bottomLeft)
        }
        
        if (bottomRight) {
            retCorner.insert(UIRectCorner.bottomRight)
        }
        
        return retCorner
    }
    
    func heightForRow(at indexPath: IndexPath) -> CGFloat {
        return sections[indexPath.section].messages[indexPath.item].message.getHeight()
    }
    
    func update(message: Message, at indexPath: IndexPath) {
        self.sections[indexPath.section].messages[indexPath.row].message = message
    }
    
    func indexOf(message: Message) -> IndexPath? {
        for (section,s) in sections.enumerated() {
            for (index,m) in s.messages.enumerated() {
                if m.message == message {
                    return IndexPath(item: index, section: section)
                }
            }
        }
        
        return nil
    }
    
    func message(at index: IndexPath) -> Message {
        return self.sections[index.section].messages[index.item].message
    }
}

extension Collection where Index : Comparable {
    subscript(back i: IndexDistance) -> Generator.Element {
        let backBy = i + 1
        return self[self.index(self.endIndex, offsetBy: -backBy)]
    }
}
