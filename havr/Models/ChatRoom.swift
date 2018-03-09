//
//  ChatRoom.swift
//  havr
//
//  Created by Arben Pnishi on 6/13/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON
import CoreLocation
import GoogleMaps

protocol MapObject {
    var position: CLLocationCoordinate2D? { get }
    var name: String { get set }
    var distance: Double? { get }
}

class ChatRoom: Object, MapObject {
    
    dynamic var id: Int = 0
    dynamic var photo: String = ""
    dynamic var name: String = ""
    dynamic var address: String = ""
    dynamic var latitude: Double = 0.0
    dynamic var longitude: Double = 0.0
    dynamic var proximity: Double = 0.0
    dynamic var isOwner: Bool = false
    dynamic var isMember: Bool = false
    
    lazy var imageView : RoundedImageView = {
        let v = RoundedImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        return v
    }()
    
    lazy var marker: GMSMarker? = { [weak self] in
        guard let me = self else { return nil }
        guard let location = me.location else { return nil }
        
        let marker = GMSMarker(position: location.coordinate)
        marker.title = me.name
        
        me.imageView.image = #imageLiteral(resourceName: "E Chatroom PIN")
        me.imageView.contentMode = .scaleAspectFit
        
        marker.iconView = me.imageView
        marker.appearAnimation = .pop
        return marker
    }()

    static func create(from json: JSON) -> ChatRoom? {
        if let id = json["id"].int, let name = json["name"].string, let address = json["address"].string{
            
            let room = ChatRoom()
            
            room.id = id
            room.name = name
            room.address = address
            room.isOwner = json["is_owner"].bool ?? false
            room.isMember = json["is_member"].bool ?? false
            
            if let lat = json["latitude"].string{
                room.latitude = lat.toDouble()!
            }
            if let lng = json["longitude"].string{
                room.longitude = lng.toDouble()!
            }
            if let proximity = json["proximity"].string{
                room.proximity = proximity.toDouble()!
            }
            
            room.isOwner = json["is_owner"].bool ?? false
            room.isMember = json["is_member"].bool ?? false
            
            room.photo = json["photo"].string ?? ""

            return room
        }
        
        return nil
    }
    
    var location: CLLocation? {
        if latitude != 0 && longitude != 0 {
            return CLLocation(latitude: latitude, longitude: longitude)
        }
        
        return nil
    }
    
    var position: CLLocationCoordinate2D? {
        return location?.coordinate
    }
    
    func getImageUrl() -> URL? {
        return URL(string: photo)
    }
    
    func getProximity() -> String {
        if proximity == 0 {
            return ""
        }
        
        return "<\(proximity.roundTo(places: 1))km"
    }
    
    var distance: Double? {
        if let location = location, let userLocation = LocationManager.shared.lastLocation {
            return userLocation.distance(from: location)
        }
        
        return nil
    }
    
    func getDistance() -> String? {
        if let distance = distance {
            if distance > 1000 {
                return "\((distance / 1000).roundTo(places: 1))km"
            }
            
            return "\(distance.roundTo(places: 1))m"
        }
        
        return nil
    }
    
    override static func ignoredProperties() -> [String] {
        return ["imageView","marker"]
    }
    
}
