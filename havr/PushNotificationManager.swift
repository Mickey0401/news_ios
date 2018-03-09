//
//  PushNotificaitonManager.swift
//  Marketi
//
//  Created by Lindi on 3/31/17.
//  Copyright © 2017 TENTON. All rights reserved.
//

import UIKit
import UserNotifications
import FirebaseInstanceID
import Firebase
import SwiftyJSON

enum PushNotificationMessage {
    case post(Post)
    case message(Int)
    case user(User)
    
    init?(json: JSON) {
        if let postString = json["post"].string {
            if let post = Post.create(from: JSON.init(parseJSON: postString)) {
                self = .post(post)
                return
            }
        }
        
        if let channelString = json["channel_id"].string, let channelId = Int(channelString) {
            self = .message(channelId)
            return
        }
        
        if let userString = json["user_performed"].string {
            if let user = User.create(from: JSON.init(parseJSON: userString)){
                self = .user(user)
                return
            }
        }
        
        return nil
    }
}

class PushNotificationManager: NSObject, MessagingDelegate {
    static var shared = PushNotificationManager()
    
    static func didRegisterForRemoteNotification() -> Bool {
        guard Preferences.isEnabledRemoteNotification else {
            UIApplication.shared.unregisterForRemoteNotifications()
            return UIApplication.shared.isRegisteredForRemoteNotifications
        }
        return UIApplication.shared.isRegisteredForRemoteNotifications
    }
    
    static func register(application: UIApplication) {
        if #available(iOS 10, *) {
            UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in
                if granted {
                    DispatchQueue.main.async {
                        application.registerForRemoteNotifications()
                    }
                } else {
                    self.didNotRegister()
                }
            }
        }else {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    static func unregisterFromNotifications() {
        UIApplication.shared.unregisterForRemoteNotifications()
    }
    
    static func didRegister(with deviceToken: Data) {
        
        Messaging.messaging().delegate = PushNotificationManager.shared
        Messaging.messaging().apnsToken = deviceToken
        
        if let token = Messaging.messaging().fcmToken {
            console("Token: \(token)")
            Preferences.firebaseToken = token
            DeviceAPI.register(completion: { (success, error) in
                if success {
                    print("Device is registred for push notifications.")
                } else {
                    print("Device failed to register for push notifications.")
                }
            })
        }
    }
    
    static func tokenRefreshNotification(notifcation: NSNotification) {
        if let token = InstanceID.instanceID().token() {
            console("Token: \(token)")
            Preferences.firebaseToken = token
            
            DeviceAPI.register(completion: { (success, error) in
                if success {
                    print("Device is registred for push notifications.")
                } else {
                    print("Device failed to register for push notifications.")
                }
            })
            
        }
    }
    
    static func didFailToRegister(with error: Error) {
        console("Did fail \(error.localizedDescription)")
    }
    
    static func didNotRegister() {
        console("Did not register")
        
        //        DeviceREST.register(completion: { (success, error) in
        //            if success {
        //                console("Device is registred, but not for push notifications.")
        //            } else if let error = error {
        //                console("Device failed to register: \(error.message)")
        //            }
        //        })
    }
    
    static func updateDeviceSettings() {
        //        DeviceREST.register(completion: { (success, error) in
        //            if success {
        //                console("Device is updated for push notifications.")
        //            } else if let error = error {
        //                console("Device failed to update for push notifications: \(error.message)")
        //            }
        //        })
    }
    
    static func handleNotification(userInfo: [AnyHashable: Any], for state: UIApplicationState) {
        guard AccountManager.isLogged else { return }
        
        let json = JSON(userInfo)
        
        guard let message = PushNotificationMessage(json: json) else { return  }
        
        switch state {
        case .active:
            handleActiveMessage(message: message)
            break
        case .background:
            handleBackgroundMessage(message: message)
            break
        case .inactive:
            handleInActiveMessage(message: message)
            break
        }
    }
    
    fileprivate static func handleBackgroundMessage(message: PushNotificationMessage) {
        switch message {
        case .message(_):
            ChatManager.shared.appEnterForeground()
        default: return
        }
    }
    
    fileprivate static func handleActiveMessage(message: PushNotificationMessage) {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        
        switch message {
        case .message(_):
            ChatManager.shared.appEnterForeground()
            break
        case .post(_):
            print("Liked commented or posted.")
            break
            
        case.user(_):
            print("User connection.")
            break
        }
    }
    
    fileprivate static func handleInActiveMessage(message: PushNotificationMessage) {
        switch message {
        case .message(let channelId):
            ChatManager.shared.appEnterForeground()
            
            if let conversation = ConversationManager.shared.conversation(withChannelId: channelId) {
                if let openConversation = ChatManager.shared.conversationController, let navigationController = openConversation.navigationController {
                    if openConversation.conversation != conversation {
                        navigationController.popViewController(animated: false)
                        let controller = ConversationController.create(conversation: conversation)
                        navigationController.pushViewController(controller, animated: true)
                    }
                } else {
                    TabBarController.shared?.selectedIndex = 4
                }
            } else {
                TabBarController.shared?.selectedIndex = 4
            }
            break
            
        case .post(let post):
            TabBarController.shared?.selectedIndex = 0

            let detailsVC = PostDetailController.create()
            detailsVC.post = post
            detailsVC.isFromBroadcastVC = true
            
            TabBarController.shared?.broadcast.push(detailsVC)
            break
            
        case.user(let user):
            TabBarController.shared?.selectedIndex = 0
            
            let userProfile = UserProfileController.create(for: user)
            userProfile.isFromBroadcastVC = true
            
            TabBarController.shared?.broadcast.push(userProfile)
            break
        }
    }
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        if let token = InstanceID.instanceID().token() {
            console("Token: \(token)")
            Preferences.firebaseToken = token
            
            DeviceAPI.register(completion: { (success, error) in
                if success {
                    print("Device is registred for push notifications.")
                } else {
                    print("Device failed to register for push notifications.")
                }
            })
            
        }
    }
}


