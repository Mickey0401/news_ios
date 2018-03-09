//
//  ExploreConversationModelView.swift
//  havr
//
//  Created by Personal on 8/16/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

fileprivate class ExploreConversationModelSection {
    var posts: [ChatRoomPost] = []
    var section: Int = 0
    var title: String {
        return posts.first?.date.toShort ?? ""
    }
    
    func contains(post: ChatRoomPost) -> Bool {
        for m in self.posts {
            let v = Calendar.current.isDate(m.date, inSameDayAs: post.date)
            if v == true { return true }
        }
        
        return false
    }
    
    @discardableResult
    func addMessage(post: ChatRoomPost) -> IndexPath {
        return insertPost(post: post)
//        let index = self.posts.count > 0 ? self.posts.count - 1 : 0
//        self.posts.append(post)
//        return IndexPath(item: index, section: section)
    }
    
    func insertPost(post: ChatRoomPost) -> IndexPath {
//        let position = posts.count > 0 ? posts.count - 1 : 0
        posts.append(post)
        return IndexPath(row: posts.count - 1, section: section)
    }
}

class ExploreConversationModelView: NSObject {
    
    fileprivate var sections: [ExploreConversationModelSection] = []
    
    fileprivate var posts: [ChatRoomPost] = []
    
    func mergePosts(posts: [ChatRoomPost]) {
        for post in posts {
            if let index = self.posts.indexOf(post: post) {
                self.posts[index] = post
            } else {
                self.posts.append(post)
            }
        }
        
        self.posts = self.posts.sorted(by: {$0.date.timeIntervalSince1970 < $1.date.timeIntervalSince1970})
        generateSections()
    }
    
    fileprivate func generateSections() {
        self.sections.removeAll()
        
        var sections : [ExploreConversationModelSection] = []
        
        for p in self.posts {
            if let section = sections.filter({ (item) -> Bool in
                return item.contains(post: p)
            }).first {
                section.addMessage(post: p)
            } else {
                let newSection = ExploreConversationModelSection()
                newSection.addMessage(post: p)
                let sec = sections.count > 0 ? sections.count - 1 : 0
                newSection.section = sec
                sections.append(newSection)
            }
        }
        
        self.sections = sections
    }    
    
    func insertNewPost(post: ChatRoomPost) -> (index: IndexPath, isNewSection: Bool) {
        if let section = sections.filter({ (item) -> Bool in
            return item.contains(post: post)
        }).first {
            return (section.insertPost(post: post), false)
        } else {
            let newSection = ExploreConversationModelSection()
            let sec = sections.count > 0 ? sections.count - 1 : 0
            self.sections.append(newSection)
            newSection.section = sec
            
            return (newSection.insertPost(post: post), true)
        }
    }
    
    func lastRowInLastSection() -> Int?{
        if sections.count > 0 {
            let rows = numberOfItems(in: sections.count - 1)
            if rows > 0 {
                return rows - 1
            }
        }
        return nil
    }
    
    func numberOfSections() -> Int {
        return sections.count
    }
    
    func numberOfItems(in section: Int) -> Int {
        return sections[section].posts.count
    }
    
    func titleAtSection(section: Int) -> String {
        return sections[section].title
    }
    
    func post(at indexPath: IndexPath) -> ChatRoomPost {
        return sections[indexPath.section].posts[indexPath.item]
    }
    
    func cellForRow(_ tableView: UITableView, at indexPath: IndexPath, isComment: Bool) -> ExploreConversationTableCell {
        if isComment {
            let post = self.sections[indexPath.section].posts[indexPath.item]
            if post.hasMedia {
                let cell = tableView.dequeueExploreConversationTableCell(identifier: post.getCommentCellIdentifier(), indexPath: indexPath)
                cell.post = post
                return cell
            }else {
                let cell = tableView.dequeueExploreConversationTableCell(identifier: post.getCommentCellIdentifier(), indexPath: indexPath)
                cell.post = post
                return cell
            }
            let cell = tableView.dequeueExploreConversationTableCell(identifier: post.getCellIdentifier(), indexPath: indexPath)
            cell.post = post
            return cell
            
        }else {
            let post = self.sections[indexPath.section].posts[indexPath.item]
            let cell = tableView.dequeueExploreConversationTableCell(identifier: post.getCellIdentifier(), indexPath: indexPath)
            cell.post = post
            return cell
        }
    }
}

