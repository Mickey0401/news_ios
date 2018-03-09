//
//  BingImage.swift
//  havr
//
//  Created by Arben Pnishi on 8/6/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class BingImage: NSObject {
    var path: String = ""
    var id: String = ""
    
    var width: Int = 0
    var height: Int = 0
    
    static func create(with path: String, id: String, width: Int, height: Int) -> BingImage{
        let img = BingImage()
        img.path = path
        img.id = id
        img.width = width
        img.height = height
        
        return img
    }
    
    func getImageUrl() -> URL{
        return URL.init(string: self.path)!
    }
    
    static func create(from json: JSON) -> BingImage?{
        if let path = json["thumbnailUrl"].string, let id = json["imageId"].string, let width = json["width"].int, let height = json["height"].int{
            return BingImage.create(with: path, id: id, width: width, height: height)
        }
        return nil
    }
}
