//
//  UserStore.swift
//  AFNetworking
//
//  Created by Alexandr Lobanov on 12/19/17.
//

import UIKit

class UserStore: NSObject {
    
    static let shared = UserStore()
    
    fileprivate let userDefaults = UserDefaults.standard
    
    func  isSavedPost(id: Int) -> Bool  {
        let array = userDefaults.value(forKey: "saved_posts_key") as? [Int] ?? [Int]()
        return array.contains(id)
    }
    
    func savePost(with id: Int) {
        var array = userDefaults.value(forKey: "saved_posts_key") as? [Int] ?? [Int]()
        guard !array.contains(id) else  {
            return
        }
        array.append(id)
        userDefaults.set(array, forKey: "saved_posts_key")
    }
    
    func removeSavedPost(id: Int) {
        var array = userDefaults.value(forKey: "saved_posts_key") as? [Int] ?? [Int]()
        if let index = array.index(where: {$0 == id}) {
            array.remove(at: index)
            userDefaults.set(array, forKey: "saved_posts_key")
        }
    }
    
    var phoneNumber: String {
        if let string = userDefaults.string(forKey: "phone_number_user_key") {
            return string.replacingOccurrences(of: "-", with: "")
        }
        return ""
    }
    
    var country: String {
        if let string = userDefaults.string(forKey: "phone_number_country_user_key") {
            return string
        }
        return ""
    }
    
    var code: String {
        if let string = userDefaults.string(forKey: "phone_number_code_user_key") {
            return string
        }
        return ""
    }
    
    func saveContry(_ name: String) {
        userDefaults.set(name, forKey: "phone_number_country_user_key")
    }
    
    func saveCode(_ code: String) {
        userDefaults.set(code, forKey: "phone_number_code_user_key")
    }
    
    func savePhone(_ number: String?) {
        userDefaults.set(number, forKey: "phone_number_user_key")
    }
}
