//
//  Pagination.swift
//  havr
//
//  Created by Personal on 5/22/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON

class Pagination: Object {
    dynamic var totalItems: Int = 0
    dynamic var currentPage: Int = 0
    dynamic var pageItems: Int = 0
    dynamic var totalPages: Int = 0
    
    static func create(from json: JSON) -> Pagination? {
        if let totalItems = json["total_items"].int, let currentPage = json["current_page"].int, let pageItems = json["items_per_page"].int, let totalPages = json["total_pages"].int {
            
            let p = Pagination()
            p.totalItems = totalItems
            p.currentPage = currentPage
            p.pageItems = pageItems
            p.totalPages = totalPages
            
            return p
        }
        
        return nil
    }
    
    var nextPage: Int {
        return currentPage + 1
    }
    
    var hasNext: Bool {
        return nextPage <= totalPages
    }
}
