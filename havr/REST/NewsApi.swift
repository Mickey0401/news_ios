//
//  NewsApi.swift
//  havr
//
//  Created by Alexandr Lobanov on 12/14/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class NewsApi {

    static func news(searchedText: String, page: Int, completion: @escaping ([BroadcastNews]?, Error?) -> Void) {
        guard let url = URL(string: "https://newsapi.org/v2/everything?q=\(searchedText)&page=\(page)&sortBy=publishedAt&language=en&pageSize=\(Constants.NEWS_FEED_ITEM_PER_PAGE)") else { return }
        Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: ["Authorization":"d9656f7891f04a9aa4ece46bee35aa8e"]).validate().responseJSON { (response) in
            switch response.result {
            case .success:
                var itemsArray = [BroadcastNews]()
                guard let value = response.result.value else { return }
                let values = JSON(value)["articles"].arrayValue
                for item in values {
                    guard let news = BroadcastNews.decode(item) else { continue }
                    itemsArray.append(news)
                }
                completion(itemsArray, nil)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    static func search(page: Int, lastDate: Date? = nil, completion: @escaping ([BroadcastNews]?, Error?) -> Void) {
        if let keywords = ResourcesManager.keywordAsParam  {
            if keywords.isEmpty {
                BroadcastAPI.getKeywords { (keywords, error) in
                    guard error == nil else { return }
                    ResourcesManager.userKeywords = keywords
                    var allKeywords = [String]()
                    for item in keywords {
                        allKeywords += item.removedSpaces()
                    }
                    let formatedKeywords = allKeywords.map({$0.capitalized}).joined(separator: " OR ")
                    ResourcesManager.keywordAsParam = formatedKeywords
                    guard let encoded = formatedKeywords.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed), var url = URL(string: "https://newsapi.org/v2/everything?q=\(encoded)&page=\(page)&sortBy=publishedAt&pageSize=\(Constants.NEWS_FEED_ITEM_PER_PAGE)&language=en") else { return }
                    if let date = lastDate {
                        url = URL(string: "https://newsapi.org/v2/everything?q=\(encoded)&page=\(page)&sortBy=publishedAt&pageSize=\(Constants.NEWS_FEED_ITEM_PER_PAGE)&to=\(date.toServerFormatted)&language=en")!
                    }
                    perform(requestWith: url, completion: completion)
                }
                return
            }
            guard let encoded = keywords.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed), var url = URL(string: "https://newsapi.org/v2/everything?q=\(encoded)&page=\(page)&sortBy=publishedAt&pageSize=\(Constants.NEWS_FEED_ITEM_PER_PAGE)&language=en") else { return }
            if let date = lastDate {
                url = URL(string: "https://newsapi.org/v2/everything?q=\(encoded)&page=\(page)&sortBy=publishedAt&pageSize=\(Constants.NEWS_FEED_ITEM_PER_PAGE)&to=\(date.toServerFormatted)&language=en")!
            }
            perform(requestWith: url, completion: completion)

        } else {
            BroadcastAPI.getKeywords { (keywords, error) in
                guard error == nil else { return }
                ResourcesManager.userKeywords = keywords
                var allKeywords = [String]()
                for item in keywords {
                    allKeywords += item.removedSpaces()
                }
                let formatedKeywords = allKeywords.map({$0.capitalized}).joined(separator: " OR ")
                ResourcesManager.keywordAsParam = formatedKeywords
                guard let encoded = formatedKeywords.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed), var url = URL(string: "https://newsapi.org/v2/everything?q=\(encoded)&page=\(page)&sortBy=publishedAt&pageSize=\(Constants.NEWS_FEED_ITEM_PER_PAGE)&language=en") else { return }
                if let date = lastDate {
                    url = URL(string: "https://newsapi.org/v2/everything?q=\(encoded)&page=\(page)&sortBy=publishedAt&pageSize=\(Constants.NEWS_FEED_ITEM_PER_PAGE)&to=\(date.toServerFormatted)&language=en")!
                }
                perform(requestWith: url, completion: completion)
            }
        }
    }
    
    static func perform(requestWith url: URL, completion: @escaping ([BroadcastNews]?, Error?) -> Void) {
        Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: ["Authorization":"d9656f7891f04a9aa4ece46bee35aa8e"]).validate().responseJSON { (response) in
            switch response.result {
            case .success:
                var itemsArray = [BroadcastNews]()
                guard let value = response.result.value else { return }
                let values = JSON(value)["articles"].arrayValue
                for item in values {
                    guard let news = BroadcastNews.decode(item) else { continue }
                    itemsArray.append(news)
                }
                completion(itemsArray, nil)
            case .failure(let error):
                print(error)
                completion(nil, error)
            }
        }
    }
}
