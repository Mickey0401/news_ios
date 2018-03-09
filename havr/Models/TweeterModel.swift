//
//  TweeterModel.swift
//  havr
//
//  Created by Alexandr Lobanov on 12/10/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import TwitterKit

typealias BroadcastCellDelegate = (delegate: BroadcastControllerDelegate?,  videoPlayerdelegate: VideoPlayerViewDelegate?, mentionDelegate: MentionLabelDelegate?, urlDelegate: URLLabelDelegate?)

protocol BroadcastCellModel {
    var reuseId: String { get }
    var posts: [Post] { get set }
    var createDate: Date { get }
    var currentPage: Int? { get set}
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, with delegates: BroadcastCellDelegate?) -> UITableViewCell
}

struct TweetBroadcastModel: BroadcastCellModel {
    var tweetId: String?
    var reuseId: String  = "twitter_cell"
    
    var posts: [Post]
    var currentPage: Int? = 0
    var url:URL?
    var image: UIImage?
    let username: String
    let fullname: String
    let userId: String
    let userImageUrl: URL?
    let text: String
    var createDate: Date
    var tweetObj: TWTRTweet?
    
    init() {
        url = URL(string: "dd")
        username = "test"
        fullname = "tweet.author.screenName"
        userId = "tweet.author.userID"
        userImageUrl = URL(string: "tweet.author.profileImageURL")
        createDate = Date.init(timeIntervalSince1970: 123)
        text = "test"
        self.posts = [Post()]
        self.tweetId = "tweet.tweetID"
        self.tweetObj = nil
    }
    
    init(tweet: TWTRTweet) {
        url = tweet.permalink
        username = tweet.author.name
        fullname = tweet.author.screenName
        userId = tweet.author.userID
        userImageUrl = URL(string: tweet.author.profileImageURL)
        createDate = tweet.createdAt
        text = tweet.text
        self.posts = [Post()]
        self.tweetId = tweet.tweetID
        self.tweetObj = tweet
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, with delegates: BroadcastCellDelegate?) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TwitterViewCell", for: indexPath) as? TwitterViewCell else { return UITableViewCell() }
        cell.delegate = delegates?.urlDelegate
        cell.configureCell(with: self.tweetObj!)
        return cell
    }
}
