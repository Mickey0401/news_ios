//
//  UserKeywordInterest.swift
//  havr
//
//  Created by Alexandr Lobanov on 1/15/18.
//  Copyright © 2018 Tenton LLC. All rights reserved.
//

import Foundation
import SwiftyJSON

func randomNumber<T : SignedInteger>(inRange range: ClosedRange<T> = 1...6) -> T {
    let length = (range.upperBound - range.lowerBound + 1).toIntMax()
    let value = arc4random().toIntMax() % length + range.lowerBound.toIntMax()
    return T(value)
}

extension Collection {
    func randomItem() -> Self.Iterator.Element {
        let count = distance(from: startIndex, to: endIndex)
        let roll = randomNumber(inRange: 0...count-1)
        return self[index(startIndex, offsetBy: roll)]
    }
}

struct UserKeywordInterest {
    let interestName: String
    let keywords: [String]
    
    func removedSpaces() -> [String] {
        var array = [String]()
        for item in keywords {
            array.append(item.removingWhitespaces().removeSpecialCharsFromString())
        }
        return array
    }
    
    func randomKeywordfromInteres() -> String {
        return keywords.randomItem().removeSpecialCharsFromString()
    }
    
}

extension String {
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
    
    func removeSpecialCharsFromString() -> String {
        let chars = Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890".characters)
        return String(self.characters.filter { chars.contains($0) })
    }
}

extension UserKeywordInterest: JSONDecodable {
    static func decode(_ json: JSON) -> UserKeywordInterest? {
        guard let keywords = json.arrayObject as? [String] else { return nil }
        return UserKeywordInterest(interestName: "d", keywords: keywords)
    }
}

