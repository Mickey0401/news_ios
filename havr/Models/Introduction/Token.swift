//
//  Token.swift
//  havr
//
//  Created by Alexandr Lobanov on 1/12/18.
//  Copyright © 2018 Tenton LLC. All rights reserved.
//

import UIKit
import SwiftyJSON


struct TokenConffirmation {
    let token: String
    let isRegistered: Bool
    let profile: User?
}

extension TokenConffirmation: JSONDecodable {
    static func decode(_ json: JSON) -> TokenConffirmation? {
        guard let token = json["token"].string,
        let isRegistred = json["registration"].bool else {
            return nil
        }
        let user = User.create(json["profile"])
        return TokenConffirmation(token: token, isRegistered: isRegistred, profile: user)
    }
}
