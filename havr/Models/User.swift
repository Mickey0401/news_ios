//
//  User.swift
//  havr
//
//  Created by Personal on 5/11/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift
import Alamofire

enum ConnectionStatus: String {
    case connect = "connect"
    case connected = "connected"
    case requested = "requested"
    case requesting = "requesting"
    case declined = "declined"
    case blocked = "blocked"
    case blocking = "blocking"
}

class User: Object {
    dynamic var id: Int = 0
    dynamic var fullName: String = ""
    dynamic var username: String = ""
    
    dynamic var age: Int = 0
    dynamic var gender: String = "Other"
    dynamic var photo: String = ""
    dynamic private var isPrivate = false
    dynamic var isPublic : Bool{
        get{
            if self.status == .connected {
                return true
            }else{
                return !isPrivate
            }
        }
        set{
            isPrivate = !newValue
        }
    }
    
    dynamic var isFacebook : Bool = false
    
    dynamic fileprivate var connectionStatus: String = ""
    dynamic var stats: UserStats? = UserStats()
    
    var status: ConnectionStatus {
        get {
            return ConnectionStatus.init(rawValue: connectionStatus) ?? ConnectionStatus.connect
        }
        set {
            connectionStatus = newValue.rawValue
        }
    }
    
    static func create(_ json: JSON) -> User? {
        guard let id = json["id"].int,
            let fullname = json["full_name"].string,
            let username = json["username"].string else { return nil }
        let user = User()
        user.id = id
        user.fullName = fullname
        user.username = username
        user.photo = json["photo"].string ?? ""
        return user
    }
    
    static func create(from json: JSON) -> User? {
        if let id = json["pk"].int, let fullname = json["full_name"].string, let username = json["username"].string {
            
            let user = User()
            
            user.id = id
            user.fullName = fullname
            user.username = username
            
            if let age = json["age"].int, age > 0 {
                user.age = age
            }
            
            user.gender = json["gender"].string ?? "Other"
            user.photo = json["photo"].string ?? ""
            let isPublicUser = json["is_public"].bool ?? false
            user.isPrivate = !isPublicUser
            
            user.status = ConnectionStatus.init(rawValue: json["connection_status"].string ?? "connect") ?? ConnectionStatus.connect
            
            if let us = UserStats.create(from: json) {
                user.stats = us
            }
            
            return user
        }
        
        return nil
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
//    func getUsername() -> String {
//        return "@\(username)"
//    }
    
    func getUrl() -> URL? {
        return URL(string: photo)
    }
    
    func getPlaceholder() -> UIImage? {
        return #imageLiteral(resourceName: "defaultImageUser")
    }
    
    func store() {
        CacheManager.store(object: self)
    }
    func getFirstName() -> String{
        let firstName = fullName.components(separatedBy: " ")
        return firstName[0]
    }
    
    func getConnectionActionType() -> ConnectionActionType{
        switch self.status {
        case .connect, .declined:
            return .connect
        case .connected, .requested:
            return .remove
        case .requesting:
            return .accept
        case .blocked:
            return .connect
        case .blocking:
            return .unblock
        }
    }
    
    func setStatus(with type: ConnectionActionType){
        switch type {
        case .connect:
            status = .requested
            break
        case .accept:
            status = .connected
            break
        case .decline, .remove:
            status = .connect
            break
        case .requested:
            status = .requesting
            break
        case .block:
            status = .blocking
            break
        case .unblock:
            status = .connect
            break
        }
    }
    func toDictionary() -> Parameters {
        let gender = self.gender == "Not specified" ? "Other" : self.gender
        let parameters: Parameters = [
            "id" : self.id,
            "age" : self.age,
            "gender" : gender,
            "username": self.username,
            "full_name" : self.fullName,
//            "is_public" : self.isPublic,
            "photo" : self.photo
        ]
        return parameters
    }
}

extension User{
    static func == (lhs: User, rhs: User) -> Bool{
        return lhs.id == rhs.id
    }
}
