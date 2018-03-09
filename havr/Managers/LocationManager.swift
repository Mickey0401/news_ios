//
//  LocationManager.swift
//  havr
//
//  Created by Personal on 6/27/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import CoreLocation

class LocationManager: NSObject {
    static var shared = LocationManager()
    
    var lastLocation: CLLocation?
}
