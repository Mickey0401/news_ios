//
//  CountryPhone.swift
//  havr
//
//  Created by Alexandr Lobanov on 12/26/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import SwiftyJSON


struct CountryPhone {
    let name: String
    let dialCode: String
    let code: String
    let flag: String
    
    var nameWithFlag: String {
        return flag + " " + name
    }
    
}

extension CountryPhone: JSONDecodable {
    static func decode(_ json: JSON) -> CountryPhone? {
        guard let name = json["name"].string,
            let dialCode = json["dial_code"].string,
            let code = json["code"].string,
            let flag = json["flag"].string else  {
                return nil
        }
        return CountryPhone(name: name, dialCode: dialCode, code: code, flag: flag)
    }
}


struct Country{
    var countries: [CountryPhone] = []
    
    var curentCountry: CountryPhone? {
        let locale = NSLocale.current
        var current: CountryPhone? = nil
        for item in countries {
            guard let region = locale.regionCode else { continue }
            if item.code == region {
                current = item
            }
        }
        return current
    }
    
    init() {
        guard let urlPath = Bundle.main.url(forResource: "CountryCode", withExtension: "json") else {
                return
        }
        
        var array: [CountryPhone] = []
        do {
            let data = try Data(contentsOf: urlPath)
            let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSArray
            for item in json! {
                let json = JSON(item)
                guard let country = CountryPhone.decode(json) else { continue }
                array.append(country)
            }
            self.countries = array
        } catch let error {
            print("Error decode file \(error.localizedDescription)")
        }
    }
}
