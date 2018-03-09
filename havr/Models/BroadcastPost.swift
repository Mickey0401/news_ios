//
//  BroadcastPost.swift
//  havr
//
//  Created by Arben Pnishi on 6/11/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON
import AVFoundation

class BroadcastPost: NSObject, BroadcastCellModel {
    var tweetId: String? = nil
    var reuseId: String = "BroadcastTableCell"
    var author: User? = User()
    var posts = [Post]()
    var didScrollToMainPost: Bool = false
    var currentPage: Int? = nil
    var url: URL?
    var createDate: Date {
        if let currentPage = currentPage {
            guard let date = posts[safe: currentPage]?.createdDate else { return Date() }
            return date
        } else {
            guard let date = posts[safe: 0]?.createdDate else { return Date() }
            return date
        }
    }
    var selectedPostId: Int {
        if let currentPage = currentPage {
            guard let id = posts[safe: currentPage]?.id else { return 0 }
            return id
        } else {
            guard let id = posts[safe: 0]?.id else { return 0 }
            return id
        }
    }
    
    var selectedPost: Post? {
        if let currentPage = currentPage {
            guard let post = posts[safe: currentPage] else { return nil }
            return post
        } else {
            guard let post = posts[safe: 0] else { return nil }
            return post
        }
    }
    
    //Video
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    var isPlayingVideo: Int?{
        for i in 0..<posts.count{
            let post = posts[i]
            if post.isPlayingVideo{
                return i
            }
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, with delegates: BroadcastCellDelegate?) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseId, for: indexPath) as? BroadcastTableCell, let delegates = delegates else { return UITableViewCell() }
        cell.delegate = delegates.delegate
        cell.index = indexPath.row
        cell.videoPlayerDelegate = delegates.videoPlayerdelegate
        cell.mentionLabelDelegate = delegates.mentionDelegate
        cell.urlLabelDelegate = delegates.urlDelegate
        cell.broadcastPost = self
        return cell
    }
    
    static func create(from json: JSON) -> BroadcastPost?{
        if let author = User.create(from: json["author"]){
            let b = BroadcastPost()
            author.status = .connected
            b.author = author
            
            if let posts = json["older_posts"].array{
                for item in posts{
                    if let post = Post.create(from: item){
                        b.posts.append(post)
                    }
                }
            }
            
            if let post = Post.create(from: json["post"]){
                b.currentPage = b.posts.count
                
                post.isMainBroadCast = true
                b.posts.append(post)
            }

            if let posts = json["newer_posts"].array{
                for item in posts{
                    if let post = Post.create(from: item){
                        b.posts.append(post)
                    }
                }
            }
            
            return b
        }
        
        return nil
    }
}
