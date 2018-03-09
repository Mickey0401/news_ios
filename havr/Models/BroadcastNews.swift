//
//  BroadcastNews.swift
//  havr
//
//  Created by Alexandr Lobanov on 12/14/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol JSONDecodable {
    static func decode(_ json: JSON) -> Self?
}

struct NewsSource {
    let id: String?
    let name: String?
}

extension NewsSource: JSONDecodable {
    static func decode(_ json: JSON) -> NewsSource? {
        let name = json["name"].string
        let id = json["id"].string
        return NewsSource(id: id, name: name)
    }
}

struct BroadcastNews {
    let source: NewsSource
    let author: String?
    let title: String
    let descripton: String
    let url: URL
    let imageUrl: URL?
    var createDate: Date
}

extension BroadcastNews: Equatable {
    static func ==(lhs: BroadcastNews, rhs: BroadcastNews) -> Bool {
        return lhs.descripton == rhs.descripton && lhs.author == rhs.author && lhs.title == rhs.title && lhs.url == rhs.url
    }
}

extension BroadcastNews: JSONDecodable {
    static func decode(_ json: JSON) -> BroadcastNews? {
        guard let title = json["title"].string,
            let description = json["description"].string,
            let urlString = json["url"].string,
            let url = URL(string: urlString),
            let dateString = json["publishedAt"].string,
            let date = Date.create(from: dateString),
            let source = NewsSource.decode(json["source"]) else { return nil }
        let author = json["author"].string
        guard let imageUrlString = json["urlToImage"].string else {
            return BroadcastNews(source: source, author: author, title: title, descripton: description, url: url, imageUrl: nil, createDate: date)
        }
        let imageUrl = URL(string: imageUrlString)
        return BroadcastNews(source: source, author: author, title: title, descripton: description, url: url, imageUrl: imageUrl, createDate: date)
    }
}

extension BroadcastNews: BroadcastCellModel {
    var posts: [Post] {
        get {
            return [Post]()
        }
        set {
            posts = newValue
        }
    }
    
    var reuseId: String {
        return "news_broadcast_cell"
    }
    
    var currentPage: Int? {
        get {
            return nil
        }
        set {
            currentPage = newValue
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, with delegates: BroadcastCellDelegate?) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseId, for: indexPath) as? BroadcastNewsTableCell else { return UITableViewCell() }
        cell.update(with: self)
        return cell
    }
}
