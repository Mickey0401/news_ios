//
//  MessagesController.swift
//  havr
//
//  Created by Arben Pnishi on 4/21/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import UIScrollView_InfiniteScroll

class ChatsController: UIViewController {
    
    //MARK: - OUTLETS
    @IBOutlet weak var rightBarButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    //MARK: - VARIABLES
    var conversations: [Conversation] {
        get {
            return ChatManager.shared.conversations
        }
        set {
            ChatManager.shared.conversations = newValue
            
            if conversations.count == 0 {
                emptyView.show(to: tableView)
            } else {
                emptyView.hide()
            }
        }
    }
    
    var pagination: Pagination = Pagination()
    var leftBar : UIBarButtonItem?
    var rightBar : UIBarButtonItem?
    let emptyView: EmptyDataView = EmptyDataView.createForMessages()
    
    let errorEmptyView: EmptyDataView = EmptyDataView.createForRetryMessages()
    
    lazy var pullRefresh: UIRefreshControl = {
        let r = UIRefreshControl()
        r.addTarget(self, action: #selector(pullRefreshReload), for: .valueChanged)
        return r
    }()
    
    //MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commonInit()

        if conversations.count == 0 {
            activityIndicatorView.show()
        } else {
            activityIndicatorView.hide()
        }
        
        loadResource(reset: true)
        self.tableView.addSubview(pullRefresh)
        
        errorEmptyView.delegate = self
        
        ChatManager.shared.chatsController = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GA.TrackScreen(name: "Chats")
        UIApplication.shared.statusBarStyle = .default
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("MessagesController DidAppear")
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //        leftBarButton.width = 60
        rightBarButton.width = 60
    }
    
    func commonInit(){

        tableView.registerMessageChatTableCell()
        tableView.setShouldShowInfiniteScrollHandler {[weak self] (table) -> Bool in
            guard let `self` = self else { return false }
            
            return self.pagination.hasNext
        }
        
        tableView.addInfiniteScroll {[weak self] (table) in
            guard let `self` = self else { return }
            
            self.loadMore()
        }
        
        let titleView = UILabel()
        titleView.font = UIFont.navigationTitleFont
        titleView.text = "Chats"
        self.navigationItem.titleView = titleView
        
        searchBar.delegate = self
        
        leftBar = navigationItem.leftBarButtonItem
        rightBar = navigationItem.rightBarButtonItem

        Helper.configureSearchBar(searchBar: self.searchBar)
    }
    
    func pullRefreshReload(sender: UIRefreshControl){
        pagination = Pagination()
        loadResource(reset: true)
    }
    
    func loadResource(reset: Bool = false) {
        ConversationAPI.get(limit: 20, page: 1) {[weak self] (conversations, pagination, error) in
            guard let `self` = self else { return }
            
            self.activityIndicatorView.hide()
            
            self.tableView.finishInfiniteScroll()
            if let conversations = conversations, let pagination = pagination {
                
                if reset == true {
                    self.conversations.removeAll()
                    self.tableView.reloadData()
                }
                
                if conversations.count == 0 && self.pagination.nextPage == 1 {
                    self.emptyView.show(to: self.tableView)
                    self.pullRefresh.endRefreshing()
                } else {
                    self.conversations = conversations
                    self.pagination = pagination
                    self.tableView.reloadData()
                    self.emptyView.hide()
                    self.errorEmptyView.hide()
                    self.pullRefresh.endRefreshing()
                }
            }
            
            if let error = error {
                if self.pagination.nextPage == 1 && self.conversations.count == 0 {
                    self.emptyView.hide()
                    self.errorEmptyView.show(to: self.tableView)
                    self.errorEmptyView.messageLabel.text = error.message
                } else {
                    self.emptyView.hide()
                    self.errorEmptyView.hide()
                }
                
                print(error.message)
            }
        }
    }
    
    fileprivate func loadMore() {
        ConversationAPI.get(limit: 20, page: pagination.nextPage) {[weak self] (conversations, pagination, error) in
            guard let `self` = self else { return }
            
            self.tableView.finishInfiniteScroll()
            if let conversations = conversations, let pagination = pagination {
                self.mergeConversations(conversations: conversations)
                self.pagination = pagination
            }
            
            if let _ = error {
                print("Error Fetching Conversations")
            }
        }
    }
    
    
    func reorder() {
        self.conversations = self.conversations.sort()
        self.tableView.reloadData()
    }
    
    func mergeConversations(conversations: [Conversation]) {
        for c in conversations {
            if let index = indexOf(conversation: c.id) {
                self.conversations[index.item] = c
            } else {
                self.conversations.append(c)
            }
        }
        
        reorder()
    }
    
    @IBAction func leftBarButtonPressed(_ sender: UIBarButtonItem) {
        
        
    }
    @IBAction func rightBarButtonPressed(_ sender: UIBarButtonItem) {
        let newMessage = NewMessageController.create()
        newMessage.delegate = self
        let nav = UINavigationController.init(rootViewController: newMessage)
//        nav.setStatusBarBackgroundColor(color: UIColor.green)
//        nav.navigationBar.barTintColor = UIColor.green
        nav.navigationBar.isTranslucent = false;
        self.showModal(nav)
    }
    
    func delete(at index: IndexPath) {
        let id = conversations[index.item].id
        
        ConversationAPI.delete(conversation: id, deleteAll: false) { (success, error) in
            if success {
                if let index = self.indexOf(conversation: id) {
                    self.conversations.remove(at: index.item)
                    self.tableView.deleteRows(at: [index], with: .left)
                } else {
                    self.tableView.reloadData()
                }
                
                ConversationManager.shared.delete(conversationId: id)
                
            } else if let error = error {
                if self.view.window != nil {
                    Helper.show(alert: error.message)
                }
            }
        }
    }
    
    func block(at index: IndexPath) {
        
    }
    
    func deleteAll(at index: IndexPath) {
        let id = conversations[index.item].id
        
        ConversationAPI.delete(conversation: id, deleteAll: true) { (success, error) in
            if success {
                if let index = self.indexOf(conversation: id) {
                    self.conversations.remove(at: index.item)
                    self.tableView.deleteRows(at: [index], with: .left)
                } else {
                    self.tableView.reloadData()
                }
                
                ConversationManager.shared.delete(conversationId: id)
            } else if let error = error {
                if self.view.window != nil {
                    Helper.show(alert: error.message)
                }
            }
        }
        
        
    }
    
    func indexOf(conversation id: Int) -> IndexPath? {
        for (index, conversation) in self.conversations.enumerated() {
            if conversation.id == id {
                return IndexPath(row: index, section: 0)
            }
        }
        
        return nil
    }
    
    @IBAction func onBtnPrivate(_ sender: Any) {
        self.present(PrivateChatRoomController.create(), animated: true, completion: nil)
    }
    
    @IBAction func onBtnPublic(_ sender: Any) {
        self.present(PublicChatRoomController.create(), animated: true, completion: nil)
    }
}

extension ChatsController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueMessageChatTableCell(index: indexPath)
        cell.conversation = conversations[indexPath.item]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let conversation = conversations[indexPath.item]
        
        let conversationVC = ConversationController.create(conversation: conversation)
        
        conversationVC.isFromMessagesVC = true
        
        self.push(conversationVC)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .normal, title: "         ") { (action, indexPath) in
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

            alert.addAction(UIAlertAction(title: "Delete for myself", style: .default, handler: { (handler) in
                tableView.setEditing(false, animated: true)
                self.delete(at: indexPath)
            }))

            alert.addAction(UIAlertAction(title: "Delete for both", style: .default, handler: { (handler) in
                tableView.setEditing(false, animated: true)
                self.deleteAll(at: indexPath)
            }))

            alert.view.tintColor = Apperance.appBlueColor

            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.view.tintColor = Apperance.appBlueColor
            self.navigationController?.present(alert, animated: true, completion: nil)
        }
        delete.backgroundColor = UIColor(patternImage: UIImage(named: "M editActionDelete")!)
        
        let call = UITableViewRowAction(style: .normal, title: "         ") { (action, indexPath) in
            guard let number = URL(string: "telprompt://" + "AccountManager.currentUser.username") else { return }
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(number, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(number)
            }
        }
        call.backgroundColor = UIColor(patternImage: UIImage(named: "M editActionCall")!)
        
        let mute = UITableViewRowAction(style: .normal, title: "         ") { (action, indexPath) in
            tableView.setEditing(false, animated: true)
            self.block(at: indexPath)
        }
        mute.backgroundColor = UIColor(patternImage: UIImage(named: "M editActionMute")!)
        
        return [delete, call, mute]
    }
}

extension ChatsController {
    static func create() -> ChatsController {
        return UIStoryboard.messages.instantiateViewController(withIdentifier: "ChatsController") as! ChatsController
    }
}
extension ChatsController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
extension ChatsController: UISearchBarDelegate, UIScrollViewDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        UIView.animate(withDuration: 0.5, animations: {
            searchBar.showsCancelButton = true
        }, completion: { finished in
            searchBar.becomeFirstResponder()
        })
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        
        UIView.animate(withDuration: 0.5, animations: {
            searchBar.showsCancelButton = false
        }, completion: { finished in
            searchBar.resignFirstResponder()
        })
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        UIView.animate(withDuration: 0.5, animations: {
            self.searchBar.showsCancelButton = false
        }, completion: { finished in
            self.searchBar.resignFirstResponder()
        })
    }
}

//MARK: - Empty Data View Delegate
extension ChatsController: EmptyDataViewDelegate {
    func emptyDataView(sender: EmptyDataView, didPress action: UIButton) {
        
        sender.hide()
        
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
        
        pagination = Pagination()
        
        loadResource()
    }
}

//MARK - New Message Delegate
extension ChatsController: NewMessageControllerDelegate {
    func searchController(sender: NewMessageController, didSelect conversation: Conversation) {
        sender.hideModal(true) { 
            let conversationVC = ConversationController.create(conversation: conversation)
            self.push(conversationVC)
        }
    }
}
