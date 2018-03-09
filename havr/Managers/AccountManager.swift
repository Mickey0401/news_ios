//
//  AccountManager.swift
//  havr
//
//  Created by Personal on 5/11/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import RealmSwift
import Kingfisher
import MapKit
import TwitterKit

class AccountManager: NSObject {
    
    static var currentUser: User?
    static var currentLocation: CLLocation?
    
    static var userId: Int {
        get {
            if let id = KeychainWrapper.standard.integer(forKey: "UserId"){
                return id
            }else{
                return 0
            }
        }
        set {
            KeychainWrapper.standard.set(newValue, forKey: "UserId")
        }
    }
    
    static var userToken: String? {
        get {
            return KeychainWrapper.standard.string(forKey: "UserToken")
        }
        set {
            KeychainWrapper.standard.set(newValue ?? "", forKey: "UserToken")
        }
    }
    
    
    static var isLogged: Bool {
        
        guard let token = userToken else {
            return false
        }
       
        if token.isEmpty {
            return false
        }
        
        if currentUser == nil {
            return false
        }
        
        if userId == 0 {
            return false
        }
       
        
        return true
    }
    
    static func start() {
        
        let uid = self.userId
        if let user = CacheManager.shared.object(ofType: User.self, forPrimaryKey: uid){
            let usr = User(value: user)
            AccountManager.currentUser = usr
            AccountManager.currentUser?.store()
        }
    }
    
    static func start(user: User, token: UserToken) {
        currentUser = user
        userToken = token
        userId = user.id
        
        user.store()
    }
    
    static func delete() {
        userId = 0
        currentUser = nil
        userToken = nil
        
        OfflineFileManager.deleteAll()
        ImageCache.default.clearDiskCache()
        ImageCache.default.clearMemoryCache()
        Preferences.isFacebook = false
        if let userID = UserDefaults.standard.value(forKey: "user_connected_twitter_id") as? String {
            Twitter.sharedInstance().sessionStore.logOutUserID(userID)
        }
        UserDefaults.standard.set(nil, forKey: "user_connected_twitter_username")
        UserDefaults.standard.set(nil, forKey: "user_connected_twitter_id")
        UserDefaults.standard.set(nil, forKey: "user_connected_twitter_profile_image_url")
        ResourcesManager.clear()
        ChatRoomConversationsManager.shared.clear()
        ChatRoomPostsManager.shared.clear()
        ChatManager.shared.clear()
        ConversationManager.shared.clear()
        EventPostsManager.shared.clear()
    }
    
    static func updateProfile(completion: ((Bool) -> Void)? = nil) {
        UsersAPI.getMyUser { (user, error) in
            if let user = user {
                AccountManager.currentUser = user
                AccountManager.currentUser?.store()
                completion?(true)
            }
            
            if let error = error {
                print(error.message)
                completion?(false)
            }
        }
    }
}
