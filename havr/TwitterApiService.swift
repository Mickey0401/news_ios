//
//  TwitterApiService.swift
//  havr
//
//  Created by Alexandr Lobanov on 12/10/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import TwitterKit
import SwiftyJSON

class TwitterApiService: NSObject {
    
   static func userTimeline(lastTweet id: String? = nil,  completion: @escaping ([BroadcastCellModel]?, Error?) -> Void) {
        let userId = UserDefaults.standard.string(forKey: "user_connected_twitter_id")
        let client = TWTRAPIClient(userID: userId)
        let endPoint = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        var clientError: NSError?
        var params: [String: String] = ["count": "\(Constants.TWITTER_FEED_ITEM_PER_PAGE)",
                                        "include_rts": "1"]
        if let lastTwitId = id {
            params.updateValue(lastTwitId, forKey: "max_id")
        }
        var tweets = [TweetBroadcastModel]()
        let request = client.urlRequest(withMethod: "GET", url: endPoint, parameters: params, error: &clientError)
        client.sendTwitterRequest(request) { (response, data, error) in
            if error != nil {                print("Error: \(error)")
                completion(nil, error)
            }
            guard let data = data else { return }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                guard let dictJson = json as? [[AnyHashable: Any]] else { return }
                for item in dictJson {
                    if let tweet = TWTRTweet(jsonDictionary: item) {
                        tweets.append(TweetBroadcastModel(tweet: tweet))
                    }
                }
                completion(tweets, nil)
            } catch let jsonError as NSError {
                completion(nil, jsonError)
                print("json error: \(jsonError.localizedDescription)")
            }
        }
    }
    
    static func search(_ string: String, lastTweed id: String?, completion: @escaping ([BroadcastCellModel]?, Error?) -> Void) {
        let userId = UserDefaults.standard.string(forKey: "user_connected_twitter_id")
        let client = TWTRAPIClient(userID: userId)
        guard let string = string.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else { return }
        var endPoint = "https://api.twitter.com/1.1/search/tweets.json?q=\(string)&result_type=popular&count=\(Constants.TWITTER_FEED_ITEM_PER_PAGE)&include_rts=1"
        if let id = id {
           endPoint = "https://api.twitter.com/1.1/search/tweets.json?q=\(string)&max_id=\(id)&result_type=popular&count=\(Constants.TWITTER_FEED_ITEM_PER_PAGE)&include_rts=1"
        }
        var clientError: NSError?
        var tweets = [TweetBroadcastModel]()
        let request = client.urlRequest(withMethod: "GET", url: endPoint, parameters: nil, error: &clientError)
        client.sendTwitterRequest(request) { (response, data, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            guard let data = data else { return }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                let jsonObject = JSON(json) 
                guard let dicts = jsonObject["statuses"].array else { return }

                for item in dicts {
                    if let object = item.dictionaryObject{
                        if let tweet = TWTRTweet(jsonDictionary: object) {
                            tweets.append(TweetBroadcastModel(tweet: tweet))
                        }
                    }
                }
                completion(tweets, nil)
            } catch let jsonError as NSError {
                completion(nil, jsonError)
                print("json error: \(jsonError.localizedDescription)")
            }
        }
    }
    
    static func search(with keyword: String, completion: @escaping ([BroadcastCellModel]?, Error) -> Void) {
        
    }

}
