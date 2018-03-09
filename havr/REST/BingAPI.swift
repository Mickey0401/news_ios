//
//  BingAPI.swift
//  havr
//
//  Created by Arben Pnishi on 8/6/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class BingAPI: NSObject {
    
    static func searchImages(with text: String, completion: @escaping (([BingImage]?, HSError?) -> Void)){
        let bingApiEndpoint = "https://api.cognitive.microsoft.com/bing/v5.0/images/search"
        let apiKey = "3da3a93fa7a14143a7f193711df192f6"
        
        let parameters: Parameters = [
            "q" : text,
            "count": 100
        ]
        
        let headers: HTTPHeaders = [
            "Ocp-Apim-Subscription-Key" : apiKey
        ]
        
        let request = RequestREST(resource: bingApiEndpoint, method: .get, parameters: parameters, headers: headers)
        
        ServiceREST.request(with: request) { (response) in
            if let values = response.json["value"].array{
                var array: [BingImage] = []
                for item in values{
                    if let image = BingImage.create(from: item){
                        array.append(image)
                    }
                }
                completion(array, nil)
            }else{
                let error = response.hsError(message: "Could not get any image.")
                completion(nil, error)
            }
        }
    }
}
