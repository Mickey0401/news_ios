//
//  DeviceREST.swift
//  Marketi
//
//  Created by Personal on 4/16/17.
//  Copyright © 2017 TENTON. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class DeviceAPI: NSObject {
    
    static func register(completion: @escaping ((Bool, HSError?) -> Void)){
        
        let parameters: Parameters = [
            "device_id" : Preferences.deviceId,
            "registration_id": Preferences.firebaseToken ?? "",
            "type": "ios"
        ]
        
        let request = RequestREST(resource: "register-device/", method: .post, parameters: parameters)
        
        ServiceREST.request(with: request) { (response) in
            if response.isHttpSuccess {
                completion(true, nil)
            } else {
                let error = response.hsError(message: "Cannot register this device.")
                completion(false, error)
            }
        }
    }
}
