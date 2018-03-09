//
//  BroadcastService.swift
//  havr
//
//  Created by Alexandr Lobanov on 12/12/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

extension Array {
    mutating func appendNoNil(_ element: Element?) {
        if let element = element {
            append(element)
        }
    }
}

extension Array where Element: BroadcastCellModel {
    func sortedByDate() -> [BroadcastCellModel] {
        return self.sorted(by: { $0.createDate > $1.createDate})
    }
}

class BroascastPostsService {
    
    
    fileprivate var lastTweetId: String?
    fileprivate var lastDateNews: Date? = Date()
    fileprivate var havrPagination = Pagination()
    fileprivate var newsPage = 1
    
    fileprivate var didChangeNewsPage = false
    fileprivate var didChangeHavrPage = false
    fileprivate var didChangeTweetId = false
    
    fileprivate var searchedText: String? = nil
    
    var tweets = [TweetBroadcastModel]() {
        didSet {
            if let text = searchedText {
                if tweets.isEmpty && didChangeTweetId {
                    updateTweets(text) { isSuccess in
                        self.didChangeTweetId = isSuccess
                    }
                }
                return
            }
            if tweets.isEmpty && didChangeTweetId {
                updateTweets(completion: { isSuccess in
                    self.didChangeTweetId = isSuccess
                })
            }
        }
    }
    var havr = [BroadcastPost]() {
        didSet {
            if let text = searchedText {
                if havr.isEmpty && didChangeHavrPage {
                    updateHavr(text) { isSuccess in
                        self.didChangeHavrPage = isSuccess
                    }
                }
                return
            }
            if havr.isEmpty && didChangeHavrPage {
                updateHavr(completion: { isSuccess in
                    self.didChangeHavrPage = isSuccess
                })
            }
        }
    }
    var news = [BroadcastNews]() {
        didSet {
            if let text = searchedText {
                if news.count == 0 && didChangeNewsPage {
                    updateNews(text) { isSucces in self.didChangeNewsPage = isSucces }
                }
                return
            }
            if news.count == 0 && didChangeNewsPage {
                updateNews(completion: { isSucces in self.didChangeNewsPage = isSucces })
            }
        }
    }
    
    func reset() {
        didChangeNewsPage = false
        didChangeHavrPage = false
        didChangeTweetId = false
        news = [BroadcastNews]()
        havr = [BroadcastPost]()
        tweets = [TweetBroadcastModel]()
        lastDateNews = Date()
        lastTweetId = nil
        havrPagination = Pagination()
        newsPage = 1
    }
    
    func broadcat(completion: @escaping ([BroadcastCellModel], HSError?) -> Void) {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        if havr.count <= 30  {
            updateHavr { isSucces in
                self.didChangeHavrPage = isSucces
                dispatchGroup.leave()
            }
        }
        if tweets.count <= 30  {
            dispatchGroup.enter()
            updateTweets { isSucces in
                self.didChangeTweetId = isSucces
                dispatchGroup.leave()
            }
        }
        if news.count <= 30  {
            dispatchGroup.enter()
            updateNews(completion: { isSucces in
                self.didChangeNewsPage = isSucces
                dispatchGroup.leave()
            })
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(self.filteredPostsByDate(), nil)
        }
    }
    
    func broadcast(text: String, completion: @escaping ([BroadcastCellModel], HSError?) -> Void) {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        
        updateHavr(text.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlFragmentAllowed)) { isSucces in
//        updateHavr(text) { isSucces in
            self.didChangeHavrPage = isSucces
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        updateTweets(text.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlFragmentAllowed)) { isSucces in
            self.didChangeTweetId = isSucces
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        updateNews(text.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlFragmentAllowed)) { isSucces in
            self.didChangeNewsPage = isSucces
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(self.filteredPostsByDate(), nil)
        }
    }
    
    func getBroadcast() -> [BroadcastCellModel] {
        return filteredPostsByDate()
    }
    
    func getSearched(text: String)  -> [BroadcastCellModel] {
        return filteredPostsByDate()
    }
    
    func filteredPostsByDate() -> [BroadcastCellModel] {
        var result =  [BroadcastCellModel]()
        var posts = removeEmpty(array: [tweets, havr, news] as [[Any]])
        var isRunedLoop = true
        
        while isRunedLoop {
            var models = [BroadcastCellModel]()
            posts = [news.sortedByDate(), havr.sortedByDate(), tweets.sortedByDate()]
            //            posts.forEach({($0 as! [BroadcastCellModel]).forEach({models.appendNoNil($0)})})
            
            for items in posts {
                if let items = items as? [BroadcastCellModel] {
                    models.appendNoNil(items.first)
                }
            }
            
            let sortedModels: [BroadcastCellModel] = models.sorted(by: {$0.createDate > $1.createDate})
            
            guard let model = sortedModels[safe: 0] else {
                break
            }
            
            result.append(model)
            isRunedLoop = removeAndCheckForEmpty(model) || result.count <= 30
        }
        
        
        //        return result
        return insertAnyModel(result: result)
    }
    
    func insertAnyModel(result: [BroadcastCellModel])  -> [BroadcastCellModel] {
        guard let firstCreateDate = result.first?.createDate, let lastCreateDate = result.last?.createDate else { return [BroadcastCellModel]() }
        let range = (lastCreateDate...firstCreateDate)
        var resultArray = result
        let posts = removeEmpty(array: [tweets, havr, news] as [[Any]])
        posts.forEach({ ($0 as! [BroadcastCellModel]).forEach({
            if range.contains($0.createDate) {
                resultArray.append($0)
                _ = removeAndCheckForEmpty($0)
            }
        })})
        return resultArray.sorted(by: { $0.createDate > $1.createDate })
    }
    
    
    func removeAndCheckForEmpty(_ element: BroadcastCellModel) -> Bool {
        switch element {
        case let item where item as? TweetBroadcastModel != nil:
            let index = self.tweets.index(where: { tweet in
                if let model = item as? TweetBroadcastModel {
                    return model.tweetId == tweet.tweetId
                } else {
                    return false
                }
            })
            if let index = index {
                self.tweets.remove(at: index)
            }
            
            return self.tweets.isEmpty
        case let item where item as? BroadcastPost != nil:
            if let index = self.havr.index(where: { havrPost in
                if let post = item as? BroadcastPost {
                    return post.selectedPostId == havrPost.selectedPostId
                } else {
                    return false
                }
            }) {
                self.havr.remove(at: index)
            }
            return self.havr.isEmpty
        case let item where item as? BroadcastNews != nil:
            if let index = self.news.index(where: { newsPost in
                if let post = item as? BroadcastNews {
                    return newsPost == post
                } else {
                    return false
                }
            }) {
                self.news.remove(at: index)
            }
            
            return self.news.isEmpty
        default:
            print("Error")
            return true
        }
    }
    
    func removeEmpty(array: [[Any]]) -> [[Any]] {
        var temp = [[Any]]()
        for item in array {
            if !item.isEmpty {
                temp.append(item)
            }
        }
        return temp
    }
    
    func isAnyListEmpty(_ lists: [[Any]]) -> Bool {
        var result = false
        
        for list in lists {
            if list.isEmpty {
                result = true
                break
            }
        }
        
        return result
    }
    
    //update with API
    //sorten in place
    //get new object, sort and tweets += newValue
    // remove dublicated models
    func updateTweets(_ text: String? = nil, completion:  @escaping (Bool) -> Void) {
        if let text = text {
            TwitterApiService.search(text, lastTweed: lastTweetId) {[weak self] (tweetPosts, error) in
                guard let `self` = self else {
                    return
                }
                var resultSuccess = false
                if let posts = tweetPosts as? [TweetBroadcastModel] {
                    self.tweets  += posts
                    self.lastTweetId = posts.last?.tweetId
                    resultSuccess = posts.isEmpty
                } else if let error = error {
                    print("\(#line) File:\(#file) \n \(error)")
                }
                completion(resultSuccess)
            }
        } else {
            TwitterApiService.userTimeline(lastTweet: lastTweetId) {[weak self]  (tweetPosts, error) in
                guard let `self` = self else {
                    return
                }
                var resultSuccess = false
                if let posts = tweetPosts as? [TweetBroadcastModel] {
                    self.tweets  += posts
                    self.lastTweetId = posts.last?.tweetId
                    resultSuccess = posts.isEmpty
                } else if let error = error {
                    print("\(#line) File:\(#file) \n \(error)")
                }
                completion(resultSuccess)
            }
        }
    }
    
    func updateHavr(_ text: String? = nil, completion:  @escaping (Bool) -> Void) {
        if let text = text {
            BroadcastAPI.getBroadcasts(page: havrPagination.nextPage, textToSearch: text, completion: {[weak self] (broadcast, pagination, error) in
                guard let `self` = self else {
                    return
                }
                var resultSuccess = false
                if let broadcast = broadcast, let pagination = pagination  {
                    self.havr += broadcast
                    self.havrPagination = pagination
                    resultSuccess = broadcast.isEmpty
                } else if let error = error {
                    print("\(#line) File:\(#file) \n \(error)")
                }
                completion(resultSuccess)
            })
        } else {
            BroadcastAPI.getBroadcasts(page: havrPagination.nextPage) {[weak self] (broadcast, pagination, error) in
                guard let `self` = self else {
                    return
                }
                var resultSuccess = false
                if let broadcast = broadcast, let pagination = pagination  {
                    self.havr += broadcast
                    self.havrPagination = pagination
                    resultSuccess = broadcast.isEmpty
                } else if let error = error {
                    print("\(#line) File:\(#file) \n \(error)")
                }
                completion(resultSuccess)
            }
        }
    }
    
    func updateNews(_ text: String? = nil, completion:  @escaping (Bool) -> Void) {
        if let text = text {
            NewsApi.news(searchedText: text, page: newsPage) {[weak self] responseNews, error in
                guard let `self` = self else {
                    return
                }
                
                var resultSuccess = false
                
                if let news = responseNews {
                    self.news += news.sorted(by: { $0.createDate > $1.createDate })
                    self.newsPage += 1
                    self.lastDateNews = news.last?.createDate
                    resultSuccess = !news.isEmpty
                } else if let error = error  {
                    print("\(#line) File:\(#file) \n \(error.localizedDescription)")
                }
                
                completion(resultSuccess)
            }
        } else {
            NewsApi.search(page: self.newsPage,lastDate: lastDateNews, completion: { [weak self] (responseNews, error) in
                guard let `self` = self else {
                    return
                }
                
                var resultSuccess = false
                
                if let news = responseNews {
                    self.news += news.sorted(by: { $0.createDate > $1.createDate })
                    self.lastDateNews = news.last?.createDate
                    self.newsPage += 1
                    resultSuccess = !news.isEmpty
                } else if let error = error  {
                    print("\(#line) File:\(#file) \n \(error.localizedDescription)")
                }
                
                completion(resultSuccess)
            })
        }
    }
}
