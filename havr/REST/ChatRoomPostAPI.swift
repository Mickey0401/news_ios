 //
//  ChatRoomPostAPI.swift
//  havr
//
//  Created by Ismajl Marevci on 7/7/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import RealmSwift

class ChatRoomPostAPI: NSObject {
    static func getPosts(by chatId: Int, page: Int, completion: @escaping (([ChatRoomPost]?,Pagination?,HSError?) -> Void)) {
        let parameters: Parameters = [
            "page": page,
            "page_size": 100
            
        ]
        // GET /api/chatrooms/{chatroom_id}/posts/
        
        let request = RequestREST(resource: "chatrooms/\(chatId)/posts/", method: .get, parameters: parameters)
        
        ServiceREST.request(with: request) { (response) in
            if let results = response.json["results"].array, let pagination = Pagination.create(from: response.json["pagination"]) {
                var posts: [ChatRoomPost] = []
                
                for item in results {
                    if let cp = ChatRoomPost.create(from: item) {
                        posts.append(cp)
                    }
                }
                completion(posts, pagination, nil)
            } else {
                completion(nil, nil, response.hsError(message: "Something went wrong"))
            }
        }
    }
    static func createPost(post: ChatRoomPost, by chatId:Int, completion: @escaping ((ChatRoomPost?, HSError?) -> Void)){
        var parameters: Parameters = [
            "title": post.title,
            "text": post.text,
            "is_anon": post.isAnon
        ]
        if let media = post.media{
            var mediaParameters: Parameters = [
                "url" : media.getUrl().absoluteString,
                "height" : media.height,
                "width" : media.width,
                ]
            if media.isVideo() {
                mediaParameters["length"] = Int(media.videoLength)
            }
            parameters["media"] = mediaParameters
        }
        
        let request = RequestREST(resource: "chatrooms/\(chatId)/posts/", method: .post, parameters: parameters)
        
        ServiceREST.request(with: request) { (response) in
            if let post = ChatRoomPost.create(from: response.json){
                completion(post, nil)
            } else {
                completion(nil, response.hsError(message: "Something went wrong"))
            }
        }
    }
    static func likeUnlikePost(with chatId: Int, post: ChatRoomPost, liked: Bool, completion: @escaping ((Bool, Bool, HSError?) -> Void)){
        
        let suffix = liked ? "like" : "unlike"
        
        let request = RequestREST(resource: "chatrooms/\(chatId)/posts/\(post.id)/?\(suffix)", method: .get, parameters: nil)
        
        ServiceREST.request(with: request) { (response) in
            if response.isHttpSuccess{
                completion(true, liked, nil)
            }else{
                completion(false, false, response.hsError(message: "Something went wrong"))
            }
        }
    }
    static func updatePost(with chatId: Int, post: ChatRoomPost, completion: @escaping ((ChatRoomPost?, HSError?) -> Void)){
        let parameters: Parameters = [
            "title": post.title,
            "text": post.text,
            "is_anon": post.isAnon
        ]
        // PUT /api/chatrooms/{chatroom_id}/posts/{post_id}/
        // for partial update PATCH /api/chatrooms/{chatroom_id}/posts/{post_id}/
        // fields: title, text, is_anon
        
        let request = RequestREST(resource: "chatrooms/\(chatId)/posts/\(post.id)/", method: .put, parameters: parameters)
        
        ServiceREST.request(with: request) { (response) in
            if let post = ChatRoomPost.create(from: response.json){
                completion(post, nil)
            } else {
                completion(nil, response.hsError(message: "Something went wrong"))
            }
        }
    }
    static func deletePost(with id: Int,by chatId: Int, completion: @escaping ((Bool, HSError?) -> Void)){
        
        // DELETE /api/chatrooms/{chatroom_id}/posts/{post_id}/
        
        let request = RequestREST(resource: "chatrooms/\(chatId)/posts/\(id)/", method: .delete, parameters: nil)
        
        ServiceREST.request(with: request) { (response) in
            if response.isHttpSuccess{
                completion(true, nil)
            } else {
                completion(false, response.hsError(message: "Something went wrong"))
            }
        }
    }
    static func getComments(with chatId: Int,by postId: Int, page: Int, completion: @escaping (([ChatRoomPost]?,Pagination?,HSError?) -> Void)) {
        let parameters: Parameters = [
            "page": page,
            "page_size": 100
            ]
        // GET /api/chatrooms/{chatroom_id}/posts/{post_id}/comments/
        
        let request = RequestREST(resource: "chatrooms/\(chatId)/posts/\(postId)/comments/", method: .get, parameters: parameters)
        
        ServiceREST.request(with: request) { (response) in
            if let results = response.json["results"].array, let pagination = Pagination.create(from: response.json["pagination"]) {
                var comments: [ChatRoomPost] = []
                
                for item in results {
                    if let cp = ChatRoomPost.create(comment: item) {
                        comments.append(cp)
                    }
                }
                completion(comments, pagination, nil)
            } else {
                completion(nil, nil, response.hsError(message: "Something went wrong"))
            }
        }
    }
    static func createComment(for post: ChatRoomPost, by chatId:Int, postId: Int, completion: @escaping ((ChatRoomPost?, HSError?) -> Void)){
        var parameters: Parameters = [
            "text" : post.text,
            "is_anon": post.isAnon
        ]
        
        if let media = post.media{
            var mediaParameters: Parameters = [
                "url" : media.getUrl().absoluteString,
                "height" : media.height,
                "width" : media.width,
                ]
            if media.isVideo() {
                mediaParameters["length"] = Int(media.videoLength)
            }
            parameters["media"] = mediaParameters
        }
        // POST /api/chatrooms/{chatroom_id}/posts/{post_id}/comments/
        // fields: text, is_anon
        // is_anon default false
        
        let request = RequestREST(resource: "chatrooms/\(chatId)/posts/\(postId)/comments/", method: .post, parameters: parameters)
        
        ServiceREST.request(with: request) { (response) in
            if let comment = ChatRoomPost.create(comment: response.json) {
                completion(comment, nil)
            }else {
                completion(nil, response.hsError(message: "Something went wrong"))
            }
        }
    }
    static func likeUnlikeComment(with chatId: Int, post: ChatRoomPost, comment: ChatRoomPost, liked: Bool, completion: @escaping ((Bool, Bool, HSError?) -> Void)){
        
        let suffix = liked ? "like" : "unlike"
        
        let request = RequestREST(resource: "chatrooms/\(chatId)/posts/\(post.id)/comments/\(comment.id)/?\(suffix)", method: .get, parameters: nil)
        
        ServiceREST.request(with: request) { (response) in
            if response.isHttpSuccess{
                completion(true, liked, nil)
            }else{
                completion(false, false, response.hsError(message: "Something went wrong"))
            }
        }
    }
    static func updateComment(for commentId: Int, with chatId: Int, post: ChatRoomPost, completion: @escaping ((ChatRoomPost?, HSError?) -> Void)){
        let parameters: Parameters = [
            "title": post.title,
            "text": post.text,
            "is_anon": post.isAnon
        ]
        // PUT /api/chatrooms/{chatroom_id}/posts/{post_id}/comments/{comment_id}/
        // for partial update PATCH /api/chatrooms/{chatroom_id}/posts/{post_id}/comments/{comment_id}/
        // fields: text, is_anon
        
        let request = RequestREST(resource: "chatrooms/\(chatId)/posts/\(post.id)/comments/\(commentId)/", method: .put, parameters: parameters)
        
        ServiceREST.request(with: request) { (response) in
            
            if let comment = ChatRoomPost.create(comment: response.json) {
                completion(comment, nil)
            } else {
                completion(nil, response.hsError(message: "Something went wrong"))
            }
        }
    }
    static func deleteComment(for commentId: Int, with id: Int,by chatId: Int, completion: @escaping ((Bool, HSError?) -> Void)){
        
        // DELETE /api/chatrooms/{chatroom_id}/posts/{post_id}/comments/{comment_id}/
        
        let request = RequestREST(resource: "chatrooms/\(chatId)/posts/\(id)/comments/\(commentId)/", method: .delete, parameters: nil)
        
        ServiceREST.request(with: request) { (response) in
            if response.isHttpSuccess{
                completion(true, nil)
            } else {
                completion(false, response.hsError(message: "Something went wrong"))
            }
        }
    }
    
    static func report(post: ChatRoomPost, reportMessage: ReportPostMessage, reportPlace: ReportPostPlace, completion: @escaping ((Bool, HSError?) -> Void)) {
        
        let parameters: Parameters = [
            "post_id": post.id,
            "message": reportMessage.rawValue,
            "place": reportPlace.rawValue
        ]
        
        let request = RequestREST(resource: "report/", method: .post, parameters: parameters)
        
        ServiceREST.request(with: request) { (response) in
            if response.isHttpSuccess {
                completion(true,nil)
            }else {
                let error = response.hsError(message: "Coult not report post.")
                completion(false, error)
            }
        }
    }
}
