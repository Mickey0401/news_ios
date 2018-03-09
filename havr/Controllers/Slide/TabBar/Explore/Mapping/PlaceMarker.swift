//
//  PlaceMarker.swift
//  havr
//
//  Created by Ismajl Marevci on 5/3/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import GooglePlacePicker

class PlaceMarker: GMSMarker {
    let place: GooglePlace
    
    init(place: GooglePlace) {
        self.place = place
        super.init()
        
        position = place.coordinate
        icon = UIImage(named: place.placeType+"_pin")
        groundAnchor = CGPoint(x: 0.5, y: 1)
        appearAnimation = GMSMarkerAnimation.pop
    }
}
