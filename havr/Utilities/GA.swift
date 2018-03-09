//
//  GA.swift
//  AutoShkolla
//
//  Created by Lindi on 1/7/17.
//  Copyright © 2017 Tenton. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class GA: NSObject {
    static func start() {
    
    }
    
    static func TrackScreen(name: String) -> Void{
        #if DEBUG
            return
        #else
            Analytics.logEvent(AnalyticsEventViewItem, parameters: [ "name" : name as NSObject])
        #endif
    }
    
    static func TrackAction(controller: String, action: String, label: String) {
        #if DEBUG
            return
        #else
            Analytics.logEvent("actions", parameters: [
                "controller" : controller as NSObject,
                "action" : action as NSObject,
                "description" : label as NSObject
                ])
        #endif
    }
}

