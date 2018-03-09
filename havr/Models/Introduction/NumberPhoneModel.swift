//
//  CodeConfirmationPhone.swift
//  havr
//
//  Created by Alexandr Lobanov on 1/12/18.
//  Copyright © 2018 Tenton LLC. All rights reserved.
//

import Foundation
import SwiftyJSON

struct NumberPhoneModel {
    let phone: String
}

extension NumberPhoneModel: JSONDecodable {
    static func decode(_ json: JSON) -> NumberPhoneModel? {
        guard let phone = json["phone_number"].string else { return nil }
        return NumberPhoneModel(phone: phone)
    }
}
