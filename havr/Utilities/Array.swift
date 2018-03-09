//
//  Array.swift
//  havr
//
//  Created by Personal on 7/18/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit


extension Array where Element: Conversation {
    func sort() -> [Element] {
        return sorted(by: { (item1, item2) -> Bool in
            return item1.getLastUpdatedDate().timeIntervalSince1970 > item2.getLastUpdatedDate().timeIntervalSince1970
        })
    }
    
    func contains(conversation id: Int) -> Conversation? {
        for c in self {
            if c.id == id {
                return c
            }
        }
        
        return nil
    }
}
