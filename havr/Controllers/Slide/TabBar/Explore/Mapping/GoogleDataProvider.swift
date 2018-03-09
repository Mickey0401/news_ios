//
//  GoogleDataProvider.swift
//  havr
//
//  Created by Ismajl Marevci on 5/3/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import SwiftyJSON

class GoogleDataProvider {
    var photoCache = [String:UIImage]()
    var placesTask: URLSessionDataTask?
    var session: URLSession {
        return URLSession.shared
    }
    
    func fetchPlacesNearCoordinate(coordinate: CLLocationCoordinate2D, radius: Double, types:[String], completion: @escaping (([GooglePlace]) -> Void)) -> ()
    {
        var urlString = "http://localhost:10000/maps/api/place/nearbysearch/json?location=\(coordinate.latitude),\(coordinate.longitude)&radius=\(radius)&rankby=prominence&sensor=true"
        let typesString = types.count > 0 ? types.joined(separator: "|") : "food"
        urlString += "&types=\(typesString)"
        urlString = urlString.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)!
        
        if let task = placesTask, task.taskIdentifier > 0 && task.state == .running {
            task.cancel()
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        placesTask = session.dataTask(with: NSURL(string: urlString)! as URL) {data, response, error in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            var placesArray = [GooglePlace]()
            if let aData = data {
                let json = JSON(data:aData, options:JSONSerialization.ReadingOptions.mutableContainers, error:nil)
                if let results = json["results"].arrayObject as? [[String : AnyObject]] {
                    for rawPlace in results {
                        let place = GooglePlace(dictionary: rawPlace, acceptedTypes: types)
                        placesArray.append(place)
                        if let reference = place.photoReference {
                            self.fetchPhotoFromReference(reference: reference) { image in
                                place.photo = image
                            }
                        }
                    }
                }
            }
            DispatchQueue.main.async() {
                completion(placesArray)
            }
        }
        placesTask?.resume()
    }
    
    
    func fetchPhotoFromReference(reference: String, completion: @escaping ((UIImage?) -> Void)) -> () {
        if let photo = photoCache[reference] as UIImage? {
            completion(photo)
        } else {
            let urlString = "http://localhost:10000/maps/api/place/photo?maxwidth=200&photoreference=\(reference)"
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            session.downloadTask(with: NSURL(string: urlString)! as URL) {url, response, error in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let url = url {
                    do {
                        let data = try Data(contentsOf: url)
                        let downloadedPhoto = UIImage(data: data)
                        self.photoCache[reference] = downloadedPhoto
                        DispatchQueue.main.async() {
                            completion(downloadedPhoto)
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                else {
                    DispatchQueue.main.async() {
                        completion(nil)
                    }
                }
                }.resume()
        }
    }
}
