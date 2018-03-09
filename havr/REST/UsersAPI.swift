//
//  UsersAPI.swift
//  havr
//
//  Created by Personal on 5/11/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

typealias UserToken = String

class UsersAPI: NSObject {
    static func login(username: String, password: String, completion: @escaping ((UserToken?, HSError?) -> Void)) {
        let parameters: Parameters = [
            "username" : username,
            "password" : password
        ]
        
        let request = RequestREST(resource: "accounts/login/", method: .post, parameters: parameters)
        
        ServiceREST.request(with: request) { (response) in
            if let token = response.json["token"].string {
                completion(token, nil)
            } else {
                
                let errorMessage = response.json["non_field_errors"].array?.first?.string
                
                let error = response.hsError(message: errorMessage ?? "Something went wrong while login in.")
                completion(nil, error)
            }
        }
    }
    
    static func logout(completion: @escaping ((Bool, HSError?) -> Void)) {
        
        let request = RequestREST(resource: "accounts/logout/")
        
        ServiceREST.request(with: request) { (response) in
            if let success = response.json["success"].bool, success == true {
                completion(success, nil)
            } else {
                let error = response.hsError(message: "Something went wrong while login out.")
                completion(false, error)
            }
        }
    }
    
    
    static func changePassword(oldPassword: String, newPassword: String, newPassword2: String, completion: @escaping ((Bool, HSError?) -> Void)) {
    
        let parameters : Parameters = [
            "old_password" : oldPassword,
            "new_password" : newPassword,
            "new_password2" : newPassword2
        ]
        
        let request = RequestREST(resource: "accounts/current/password/", method: .post, parameters: parameters)
        
        ServiceREST.request(with: request) { (response) in
            if let success = response.json["success"].bool, success == true {
                completion(success, nil)
            }else {
                let error = response.hsError(message: "Something went wrong while changing password.")
                completion(false, error)
            }
        }
        
    }
    
    static func getUser(by id: Int, completion: @escaping ((User?, HSError?) -> Void)) {
        let request = RequestREST(resource: "accounts/\(id)/")
        
        ServiceREST.request(with: request) { (response) in
            
            if let user = User.create(from: response.json) {
                completion(user, nil)
            } else {
                let error = response.hsError(message: "Something went wrong while getting user.")
                completion(nil, error)
            }
        }
    }
    
    static func getUser(username: String, completion: @escaping ((User?, HSError?) -> Void)) {
        let request = RequestREST(resource: "accounts/\(username)/")
        
        ServiceREST.request(with: request) { (response) in
            
            if let user = User.create(from: response.json) {
                completion(user, nil)
            } else {
                let error = response.hsError(message: "Something went wrong while getting user.")
                completion(nil, error)
            }
        }
    }
    static func getMyUser(completion: @escaping ((User?, HSError?) -> Void)) {
        let request = RequestREST(resource: "accounts/current/")
        
        ServiceREST.request(with: request) { (response) in
            
            if let user = User.create(from: response.json) {
                completion(user, nil)
            } else {
                let error = response.hsError(message: "Something went wrong while getting user.")
                completion(nil, error)
            }
        }
    }
    
    static func logMe(username: String, password: String, completion: @escaping ((User?, UserToken?, HSError?) -> Void)) {
        
        login(username: username, password: password) { (token, error) in
            if let token = token {
                AccountManager.userToken = token
                getMyUser(completion: { (user, error) in
                    if let user = user {
                        completion(user,token, nil)
                    } else {
                        completion(nil,nil, error)
                    }
                })
            }
            
            if let error = error {
                completion(nil, nil, error)
            }
        }
        
    }
    
    static func checkEmail(email: String, completion: @escaping ((Bool?, HSError?) -> Void)) {
        let request = RequestREST(resource: "accounts/check-email/", method: .post, parameters: ["email" : email] as Parameters)
        
        ServiceREST.request(with: request) { (response) in
            if let isFree = response.json["is_email_free"].bool {
                completion(isFree, nil)
            } else {
                let error = response.hsError(message: "Could not check this email")
                completion(nil, error)
            }
        }
    }
    static func checkUsername(username: String, completion: @escaping ((Bool?, HSError?) -> Void)) {
        let request = RequestREST(resource: "accounts/check-username/", method: .post, parameters: ["username" : username] as Parameters)
        
        ServiceREST.request(with: request) { (response) in
            if let isFree = response.json["is_username_free"].bool {
                completion(isFree, nil)
            } else {
                let error = response.hsError(message: "Could not check this username")
                completion(nil, error)
            }
        }
    }
    static func forgotPassword(email: String, completion: @escaping ((Bool?, HSError?) -> Void)) {
        let request = RequestREST(resource: "accounts/forgot-password/", method: .post, parameters: ["email" : email] as Parameters)
        
        ServiceREST.request(with: request) { (response) in
            if let isSuccess = response.json["success"].bool {
                completion(isSuccess, nil)
            } else {
                let error = response.hsError(message: "Could not send email.")
                completion(nil, error)
            }
        }
    }

    //MARK: old implementation of registartion menthod (this is for fallback) )
//    static func register(email: String, full_name: String, username: String, password: String, photo: String? = nil, completion: @escaping ((UserToken?, User?, HSError?) -> Void)) {
//
//        var parameters : Parameters = [
//            "email" : email,
//            "full_name" : full_name,
//            "username" : username,
//            "password" : password,
//        ]
//
//        if let photo = photo {
//            parameters["photo"] = photo
//        }
//
//        let request = RequestREST(resource: "accounts/sign-up/", method: .post, parameters: parameters)
//
//        ServiceREST.request(with: request) { (response) in
//            if let token = response.json["token"].string, let profile = User.create(from: response.json["profile"]) {
//                completion(token, profile, nil)
//            }
//            else {
//
//                let errorMessage = response.json["email"].array?.first?.string
//                let userNameError = response.json["username"].array?.first?.string
//
//                let error = response.hsError(message: errorMessage ?? userNameError ?? "Something went wrong while registering.")
//                completion(nil, nil, error)
//            }
//        }
//    }
    
    static func loginWithFacebook(accessToken: String, completion: @escaping ((UserToken?, User?, HSError?) -> Void)) {
        
        let parameters : Parameters = [
            "access_token" : accessToken,
            ]
        
        let request = RequestREST(resource: "accounts/login/facebook/", method: .post, parameters: parameters)
        
        ServiceREST.request(with: request) { (response) in
            if let token = response.json["token"].string, let profile = User.create(from: response.json["user"]) {
                completion(token, profile, nil)
            }
            else {
                let error = response.hsError(message: "Something went wrong while registering.")
                completion(nil, nil, error)
            }
        }
    }
    
    static func search(name: String, page: Int, completion: @escaping ((String,[User]?,Pagination?,HSError?) -> Void)) {
        let parameters: Parameters = [
            "name" : name,
            "page": page,
            "page_size" : 10
        ]
        
        let request = RequestREST(resource: "accounts/", method: .get, parameters: parameters)
        
        ServiceREST.request(with: request) { (response) in
            if let results = response.json["results"].array, let pagination = Pagination.create(from: response.json["pagination"]) {
                var users: [User] = []
                
                for item in results {
                    if let u = User.create(from: item) {
                        users.append(u)
                    }
                }
                
                completion(name, users, pagination, nil)
            } else {
                completion(name, nil, nil, response.hsError(message: "Something went wrong"))
            }
        }
    }
    
    static func search(gender: String?, minAge: Int? = nil, maxAge: Int? = nil, distance: Int? = nil, page: Int, completion: @escaping (([User]?,Pagination?,HSError?) -> Void)) {
        var parameters: Parameters = [
            "page": page,
            "page_size" : 100
        ]
        if let mnAge = minAge {
            parameters["min_age"] = mnAge
        }
        if let mxAge = maxAge {
            parameters["max_age"] = mxAge
        }
        if let gnd = gender {
            if gender == "Male" || gender == "Female" {
                parameters["gender"] = gnd
            }
        }
        
        if let dist = distance{
            parameters["max_distance"] = dist
        }
        
        let request = RequestREST(resource: "accounts/", method: .get, parameters: parameters)
        
        ServiceREST.request(with: request) { (response) in
            if let results = response.json["results"].array, let pagination = Pagination.create(from: response.json["pagination"]) {
                var users: [User] = []
                
                for item in results {
                    if let u = User.create(from: item) {
                        users.append(u)
                    }
                }
                
                completion(users, pagination, nil)
            } else {
                completion(nil, nil, response.hsError(message: "Something went wrong"))
            }
        }
    }
    
    static func updatePrivacy(isPublic public: Bool, completion: @escaping ((Bool?, HSError?) -> Void)) {
        
        let parameters: Parameters = [
            "is_public" : `public`
        ]
        
        let request = RequestREST(resource: "accounts/current/", method: .patch, parameters: parameters)
        
        ServiceREST.request(with: request) { (response) in
            if let newStatsu = response.json["is_public"].bool, response.isHttpSuccess {
                completion(newStatsu, nil)
            }else {
                let error = response.hsError(message: "Could not update your profile")
                completion(nil, error)
            }
        }
    }
    
    static func updateLocation(with latitude: Double, longitude: Double, completion: @escaping ((Bool, HSError?) -> Void)) {
        
        let parameters: Parameters = [
            "latitude"  : "\(latitude.roundTo(places: 4))",
            "longitude" : "\(longitude.roundTo(places: 4))"
        ]
        
        let request = RequestREST(resource: "accounts/current/location/", method: .patch, parameters: parameters)
        
        ServiceREST.request(with: request) { (response) in
            if response.isHttpSuccess{
                completion(true, nil)
            }else{
                let error = response.hsError()
                completion(false, error)
            }
        }
    }
    
    static func updateProfileImage(image url: String, completion: @escaping ((Bool, HSError?) -> Void)) {
        let parameters: Parameters = [
            "photo" : url
        ]
        
        let request = RequestREST(resource: "accounts/current/", method: .patch, parameters: parameters)
        
        ServiceREST.request(with: request) { (response) in
            if response.isSuccess {
                completion(true, nil)
            } else {
                let error = response.hsError(message: "Could not update your profile picture.")
                completion(false, error)
            }
        }
    }
    
    static func updateProfile(user: User, completion: @escaping ((User?, HSError?) -> Void)) {
        let request = RequestREST(resource: "accounts/current/", method: .patch, parameters: user.toDictionary())
        
        ServiceREST.request(with: request) { (response) in
            if let user = User.create(from: response.json) {
                completion(user, nil)
            } else {
                let error = response.hsError(message: "Something went wrong while updating user.")
                completion(nil, error)
            }
        }
    }
}

//MARK: - Register with phone number
extension UsersAPI {
    static func requestCode(with phoneNumber: String, completion: @escaping (NumberPhoneModel?, HSError?) -> Void ) {
        let parameters: Parameters = [
            "phone_number": phoneNumber
        ]
        let request = RequestREST(resource: "accounts/sign-in/sms/", method: .post, parameters: parameters, headers: nil)
        ServiceREST.request(with: request) { (response) in
            switch response.statusCode {
            case 404:
                completion(nil, HSError(message: "Service Unavailable", code: 404) )
                return
            case 200...300:
                guard let code = NumberPhoneModel.decode(response.json) else {
                    completion(nil, HSError(message: "Can't serialize response", code: 299))
                    return
                }
                completion(code, nil)
            default:
                completion(nil, HSError(message: "Connection Error" , code: 504))
            }

        }
    }
    
    static func confirmPhone(withCode code: String, completion: @escaping (TokenConffirmation?, HSError?) -> Void) {
        let request = RequestREST(resource:  "/accounts/sign-in/sms/\(code)/", method: .get, parameters: nil, headers: nil)
        ServiceREST.request(with: request) { (response) in
            switch response.statusCode {
            case 200:
                guard let token = TokenConffirmation.decode(response.json) else {
                    completion(TokenConffirmation(token: "nil", isRegistered: false, profile: nil), HSError(message: "Fail to register", code: 33))
                    return
                }
                completion(token, nil)
            case 400:
                completion(nil, HSError(message: "Wrong Code", code: 400))
            case 404:
                completion(nil, HSError(message: "Wrong format", code: 404))
            default:
                print("Error: In File: \(#file) on: \(#line)")
            }
        }
    }
    
    static func register(token: String, full_name: String, username: String, photo: String? = nil, completion: @escaping ((UserToken?, User?, HSError?) -> Void)) {
        var parameters : Parameters = [
            "full_name" : full_name,
            "username" : username,
            ]
        
        if let photo = photo {
            parameters["photo"] = photo
        }
        
        let request = RequestREST(resource: "accounts/sign-in/\(token)/", method: .post, parameters: parameters)
        ServiceREST.request(with: request) { (response) in
            guard let profile = User.create(from: response.json["profile"]), let realToken = response.json["token"].string else {
                let errorMessage = response.json["email"].array?.first?.string
                let userNameError = response.json["username"].array?.first?.string
                let error = response.hsError(message: errorMessage ?? userNameError ?? "Something went wrong while registering.")
                
                completion(nil, nil, error)
                return
            }
            completion(realToken, profile, nil)
        }
    }
}
//MARK: User Phone Number
extension UsersAPI {
    static func currentPhoneNumber(completion: @escaping (String, HSError?) -> Void) {
        let request = RequestREST(resource: "accounts/current/phone/", method: .get, parameters: nil)
        ServiceREST.request(with: request) { response in
            if response.isSuccess {
                if let phone = response.json["phone_number"].string {
                    if !phone.isEmpty {
                        completion(phone, nil)
                    }
                } else {
                    completion("", nil)
                }
            } else {
                completion("", response.hsError())
            }
        }
    }
    
    static func updatePhone(_ number: String, completion: @escaping(String, HSError?) -> Void) {
        let params: Parameters = ["phone_number": number]
        let request = RequestREST(resource: "accounts/current/phone/", method: .post, parameters: params, headers: nil)
        
        ServiceREST.request(with: request) { response in
            if response.isSuccess {
                if let phone = response.json["phone_number"].string {
                completion(phone, nil)
                } else {
                    if let errorMSg = response.json["msg"].string {
                        completion("", HSError(message: errorMSg, code: 43))
                    }
                }
            } else {
                completion("", HSError(message: "Server connection Error", code: 0))
            }
        }
    }
}
