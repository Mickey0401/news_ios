//
//  Preferences.swift
//  havr
//
//  Created by Agon Miftari on 7/15/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import Foundation

struct Preferences {
    static var notfirstTimeInNotifications: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "FirstTimeInNotifications")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "FirstTimeInNotifications")
        }
    }
    
    static var isFacebook: Bool {
        
        get {
            return UserDefaults.standard.bool(forKey: "isFb")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isFb")
        }
        
    }
    
    static var isEnabledRemoteNotification: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "is_enable_remote_notification_key")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "is_enable_remote_notification_key")
        }
    }
    
    static var firebaseToken: String? = nil
    
    static var deviceId: String {
        return UIDevice.current.identifierForVendor!.uuidString
    }
}
