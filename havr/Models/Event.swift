//
//  Event.swift
//  havr
//
//  Created by Ismajl Marevci on 6/22/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON
import CoreLocation
import GoogleMaps

enum EventStatus: String {
    case soon = "soon"
    case live = "live"
    case ended = "ended"
}

class Event: Object, MapObject {
    dynamic var id: Int = 0
    dynamic var name: String = ""
    dynamic var eventDescription: String = ""
    dynamic var address: String = ""
    dynamic fileprivate var eventStatus: String = ""
    var status: EventStatus {
        get {
            return EventStatus.init(rawValue: eventStatus) ?? EventStatus.soon
        }
        set {
            eventStatus = newValue.rawValue
        }
    }
    
    var media: Media! = Media()
    dynamic var latitude: Double = 0.0
    dynamic var longitude: Double = 0.0
    dynamic var dateTimeStart: Date = Date()
    dynamic var dateTimeEnd: Date = Date()
    dynamic var photo : String = ""
    var isMember: Bool = true
    var isOwner: Bool = true
    
    var location: CLLocation? {
        if latitude != 0 && longitude != 0 {
            return CLLocation(latitude: latitude, longitude: longitude)
        }
        
        return nil
    }
    
    var position: CLLocationCoordinate2D? {
        return location?.coordinate
    }
    
    
    lazy var imageView : RoundedImageView = {
        let v = RoundedImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        return v
    }()
    
    lazy var marker: GMSMarker? = { [weak self] in
        guard let me = self else { return nil }
        guard let location = me.location else { return nil }
        
        let marker = GMSMarker(position: location.coordinate)
        marker.title = me.name
        me.imageView.image = #imageLiteral(resourceName: "E Event PIN")
        me.imageView.contentMode = .scaleAspectFit


        marker.iconView = me.imageView
        marker.appearAnimation = .pop
        return marker
    }()
    
    static func create(from json: JSON) -> Event? {
        
        if let id = json["id"].int, let name = json["name"].string, let description = json["description"].string, let dateTimeStart = Date.create(from: json["datetime_start"].string), let dateTimeEnd = Date.create(from: json["datetime_end"].string), let address = json["address"].string,
            let media = Media.create(fromEvent: json), let latitude = json["latitude"].string, let longitude = json["longitude"].string, let status = EventStatus.init(rawValue: json["status"].string ?? "") {
            
            let e = Event()
            
            e.id = id
            e.name = name
            e.eventDescription = description
            e.address = address
            e.media = media

            e.latitude = latitude.toDouble()!
            e.longitude = longitude.toDouble()!
            
            e.isMember = json["is_member"].bool ?? false
            e.isOwner = json["is_owner"].bool ?? false
            e.status = status
            
            e.dateTimeStart = dateTimeStart
            e.dateTimeEnd = dateTimeEnd
            e.photo = json["photo"].string ?? ""
            
            return e
        }
        return nil
    }
    
    func getImageUrl() -> URL? {
        return URL(string: photo)
    }
    
    func getSourceUrl() -> URL? {
        return media.getUrl()
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
    
    func  getTime() -> String {
        return "\(dateTimeStart.timeLeft(from: Date.now()))"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["imageView","marker"]
    }
    
    var isEnded: Bool {
        return Date().timeIntervalSince1970 > dateTimeEnd.timeIntervalSince1970
    }
    
    var isLive: Bool {
        return Date().timeIntervalSince1970 < dateTimeEnd.timeIntervalSince1970 && Date().timeIntervalSince1970 > dateTimeStart.timeIntervalSince1970
    }
    
    var isSoon: Bool {
        return Date().timeIntervalSince1970 < dateTimeStart.timeIntervalSince1970
    }
}

extension GMSMarker{
    static func == (lhs: GMSMarker, rhs: GMSMarker) -> Bool{
        return lhs.position.latitude == rhs.position.latitude && lhs.position.longitude == rhs.position.longitude && lhs.title == rhs.title
    }
}
