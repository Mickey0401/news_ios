//
//  PostsAPI.swift
//  havr
//
//  Created by Personal on 5/23/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

enum ReportPostMessage: Int{
    case accountHacked = 1
    case inappropriate = 2
    case spam = 3
    
    var description: String {
        switch self {
        case .accountHacked: return "Account hacked"
        case .inappropriate: return "It's inappropriate"
        case .spam: return "It's Spam"
        }
    }
}

enum ReportPostPlace: Int{
    case inInterests = 1
    case inEvents = 2
    case inChatrooms = 3
}

class PostsAPI: NSObject {
    static func get(page: Int, for userId: Int, in interest: Interest?, completion: @escaping (([Post]?, Pagination?, HSError?) -> Void)) {
        
        let parameters: Parameters = [
            "page" : page,
            "page_size" : 9
        ]
        
        let request = RequestREST(resource: ["accounts",userId,"interests","posts"], method: .get, parameters: parameters)
        
        ServiceREST.request(with: request) { (response) in
            
            if let jsonPosts = response.json["results"].array, let pagination = Pagination.create(from: response.json["pagination"]) {
                var posts = [Post]()
                
                jsonPosts.forEach({ (item) in
                    if let p = Post.create(from: item) {
                        posts.append(p)
                    }
                })
                
                completion(posts, pagination, nil)
            } else {
                let error = response.hsError(message: "Could not load posts.")
                completion(nil, nil, error)
            }
        }
    }
    static func getPostsBy(interest: Int, page: Int, for userId: Int, completion: @escaping (([Post]?, Pagination?, HSError?) -> Void)) {
        
        let parameters: Parameters = [
            "page" : page,
            "interest": interest,
            "page_size" : 9
        ]
        
        let request = RequestREST(resource: ["accounts",userId,"interests","posts"], method: .get, parameters: parameters)
        
        ServiceREST.request(with: request) { (response) in
            
            if let jsonPosts = response.json["results"].array, let pagination = Pagination.create(from: response.json["pagination"]) {
                var posts = [Post]()
                
                jsonPosts.forEach({ (item) in
                    if let p = Post.create(from: item) {
                        posts.append(p)
                    }
                })
                
                completion(posts, pagination, nil)
            } else {
                let error = response.hsError(message: "Could not load posts.")
                completion(nil, nil, error)
            }
        }
    }
    
    static func getMine(page: Int, in interest: Interest?, completion: @escaping (([Post]?, Pagination?, HSError?) -> Void)) {
        get(page: page, for: AccountManager.currentUser!.id, in: interest, completion: completion)
    }
    
    static func create(new post: Post, completion: @escaping ((Post?, HSError?) -> Void)) {
        var parameters: Parameters = [
            "title" : post.title,
            "interest" : post.interest!.id,
            "content" : post.media.getUrl().absoluteString,
            "height" : post.media.height,
            "width" : post.media.width,
            ]
        
        if post.isVideo() {
            parameters["length"] = Int(post.media.videoLength)
        }
        
        let request = RequestREST(resource: "interests/posts/", method: .post, parameters: parameters)
        
        ServiceREST.request(with: request) { (response) in
            let data = response.json
            if let p = Post.create(from: data){
                completion(p, nil)
            }else{
                let error = response.hsError(message: "Could not create post")
                completion(nil, error)
            }
        }
    }
    
    static func deleteComment(postId: Int, commentID: Int, completion: @escaping ((Bool) -> Void)) {
        
        let request = RequestREST(resource: "interests/posts/\(postId)/comments/\(commentID)/", method: .delete, parameters: nil)

        ServiceREST.request(with: request) { (response) in
            let data = response.json
            print("Delete comment response: \(data)")
            completion(true)
//            if let p = Post.create(from: data){
//                completion(true)
//            }else{
//                completion(false)
//            }
        }
    }
    
    static func getComments(for post: Post, page: Int, completion: @escaping (([Comment]?, Pagination?, HSError?) -> Void)) {
        
        let parameters: Parameters = [
            "page" : page
        ]
        
        let request = RequestREST(resource: "interests/posts/\(post.id)/comments/", method: .get, parameters: parameters)
        
        ServiceREST.request(with: request) { (response) in
            let data = response.json
            
            if response.isHttpSuccess{
                if let results = data["results"].array, let pagination = Pagination.create(from: data["pagination"]) {
                    var comments: [Comment] = []
                    
                    for item in results {
                        if let c = Comment.create(from: item) {
                            comments.append(c)
                        }
                    }
                    completion(comments, pagination, nil)
                }else{
                    let error = response.hsError(message: "Could not get comments")
                    completion(nil, nil, error)
                }
            }else{
                let error = response.hsError(message: "Could not get comments")
                completion(nil, nil, error)
            }
        }
    }
    
    static func createComment(with text: String, media: Media?, to post: Post, completion: @escaping ((Comment?, HSError?) -> Void)) {
        var parameters: Parameters = [
            "text" : text
        ]
        
        if let media = media{
            let mediaParameters: Parameters = [
                "url" : media.getUrl().absoluteString,
                "height" : media.height,
                "width" : media.width,
                "length" : 1,
                "content_type" : 2
                ]
            
            parameters["media"] = mediaParameters
        }

        let request = RequestREST(resource: "interests/posts/\(post.id)/comments/", method: .post, parameters: parameters)
        
        ServiceREST.request(with: request) { (response) in
            if let comment = Comment.create(from: response.json){
                completion(comment, nil)
            }else{
                let error = response.hsError(message: "Could not create comment")
                completion(nil, error)
            }
        }
    }
    
    static func likeUnlike(the post: Post, completion: @escaping ((Bool, Bool?, HSError?) -> Void)) {
        
        let request = RequestREST(resource: "interests/posts/\(post.id)/like/", method: .get, parameters: nil)
        
        ServiceREST.request(with: request) { (response) in
            if response.isHttpSuccess{
                completion(true, !post.isLiked, nil)
            }else{
                let error = response.hsError(message: "Could not like/unlike post")
                completion(false, nil, error)
            }
        }
    }
    
    static func delete(post: Post, completion: @escaping ((Bool, HSError?) -> Void)) {
        
        //DELETE /api/interests/posts/{post_id}/
        
        let request = RequestREST(resource: "interests/posts/\(post.id)/", method: .delete, parameters: nil)
        
        ServiceREST.request(with: request) { (response) in
            if response.isHttpSuccess {
                completion(true,nil)
            }else {
                let error = response.hsError(message: "Coult not delete post.")
                completion(false, error)
            }
        }
    }
    static func update(post: Post, title: String, completion: @escaping ((Bool, HSError?) -> Void)) {
        
        let parameters : Parameters = ["title": title]
        
        // PATCH /api/interests/posts/{post_id}/
        
        let request = RequestREST(resource: "interests/posts/\(post.id)/", method: .patch, parameters: parameters)
        
        ServiceREST.request(with: request) { (response) in
            if response.isHttpSuccess {
                completion(true, nil)
            }else {
                let error = response.hsError(message: "Coult not update post.")
                completion(false, error)
            }
        }
    }
    
    static func randomPost(interest: Int, for userId: Int, completion: @escaping ((Post?, HSError?) -> Void)) {
        
        let parameters: Parameters = [
            "user_id" : userId,
            "interest_id": interest
        ]
        // GET /api/interests/posts/?user_id={user_id}&interest_id={interest_id}
        
        let request = RequestREST(resource: "interests/posts/", method: .get, parameters: parameters)
        
        ServiceREST.request(with: request) { (response) in
            
            if let randomPost = Post.create(from: response.json) {
                completion(randomPost, nil)
            } else {
                let error = response.hsError(message: "Could not load posts.")
                completion(nil, error)
            }
        }
    }
    
    static func getPost(with postId: Int, completion: @escaping ((Post?, HSError?) -> Void)) {
        
        //        let parameters: Parameters = [
        //            "user_id" : userId,
        //            "interest_id": postId
        //        ]
        // GET /api/interests/posts/?user_id={user_id}&interest_id={interest_id}
        
        let request = RequestREST(resource: "/interests/posts/\(postId)/", method: .get, parameters: nil)
        
        ServiceREST.request(with: request) { (response) in
            
            if let post = Post.create(from: response.json) {
                completion(post, nil)
            } else {
                let error = response.hsError(message: "Could not load posts.")
                completion(nil, error)
            }
        }
    }
    
    
    static func share(post: Post, completion: @escaping ((Bool, HSError?) -> Void)) {
        
        //GET /api/interests/posts/{post_id}/share/
        let request = RequestREST(resource: "interests/posts/\(post.id)/share/", method: .get, parameters: nil)
        
        ServiceREST.request(with: request) { (response) in
            if response.isHttpSuccess {
                completion(true,nil)
            }else {
                let error = response.hsError(message: "Coult not share post.")
                completion(false, error)
            }
        }
    }
    
    static func report(post: Post, reportMessage: ReportPostMessage, reportPlace: ReportPostPlace, completion: @escaping ((Bool, HSError?) -> Void)) {
        
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

extension PostsAPI {
    static func savedPosts(completion: @escaping (([Post]?, Pagination?, HSError?) -> Void)) {
        let request = RequestREST(resource: "interests/posts/saved/", method: .get, parameters: nil, headers: nil)
        ServiceREST.request(with: request) { (response) in
            let data = response.json
            
            if response.isHttpSuccess{
                if let results = data["results"].array, let pagination = Pagination.create(from: data["pagination"]) {
                    var savedPost: [Post] = []
                    
                    for item in results {
                        if let c = Post.create(from: item) {
                            savedPost.append(c)
                        }
                    }
                    completion(savedPost, pagination, nil)
                }else{
                    let error = response.hsError(message: "Could not get comments")
                    completion(nil, nil, error)
                }
            }else{
                let error = response.hsError(message: "Could not get comments")
                completion(nil, nil, error)
            }
        }
    }
    
    static func savedPosts(for userId: Int, interestId: Int, completion: @escaping ([Post]?, Pagination?, HSError?) -> Void) {
        let request = RequestREST(resource: "/accounts/\(userId)/interests/posts/?interest=\(interestId)", method: .get, parameters: nil, headers: nil)
        ServiceREST.request(with: request) { (response) in
            let data = response.json
            
            if response.isHttpSuccess{
                if let results = data["results"].array, let pagination = Pagination.create(from: data["pagination"]) {
                    var savedPost: [Post] = []
                    
                    for item in results {
                        if let c = Post.create(from: item) {
                            savedPost.append(c)
                        }
                    }
                    completion(savedPost, pagination, nil)
                }else{
                    let error = response.hsError(message: "Could not get comments")
                    completion(nil, nil, error)
                }
            }else{
                let error = response.hsError(message: "Could not get comments")
                completion(nil, nil, error)
            }
        }
    }
    
    static func savePost(with id: String, completion: @escaping ((Bool, Error?) -> Void)) {
        let request = RequestREST(resource: "interests/posts/saved/\(id)/", method: .get, parameters: nil, headers: nil)
        ServiceREST.request(with: request) { (response) in
            let data = response.json
            print(data)
            if response.isHttpSuccess{
                completion(data["ret"].boolValue, nil)
            } else {
                completion(false, nil)
            }
        }
    }
}
