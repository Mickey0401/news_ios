//
//  TypingsManager.swift
//  havr
//
//  Created by Personal on 8/22/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import Foundation
import SwiftyTimer

class TypingsManager {
    static var shared = TypingsManager()
   
    var timer: Timer?
    
    func didReceiveTyping(conversation: Conversation) {

        ChatManager.shared.conversationController?.didReceiveTyping(conversation: conversation, isTyping: true)
        
        timer?.invalidate()
        timer = nil
        timer = Timer.after(5, { [weak self] in
            guard let `self` = self else { return }

            self.timer = nil
            ChatManager.shared.conversationController?.didReceiveTyping(conversation: conversation, isTyping: false)
        })
    }
    
    func sendTypper() {
        SocketManager.shared.sendTyping()
    }
}
