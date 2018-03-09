//
//  NewMessageController.swift
//  havr
//
//  Created by Ismajl Marevci on 7/20/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import SwiftyTimer
import UIScrollView_InfiniteScroll

protocol NewMessageControllerDelegate: class {
    func searchController(sender: NewMessageController, didSelect conversation: Conversation)
}

class NewMessageController: UIViewController {
    
    //MARK: - OUTLETS
    @IBOutlet weak var rightBarButton: UIBarButtonItem!
    @IBOutlet weak var leftBarButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - VARIABLES
    lazy var searchBar : UISearchBar = {
        Helper.exploreStatusBar(placeholder: "Search")
    }()
    
    var leftBar : UIBarButtonItem?
    var rightBar : UIBarButtonItem?
    
    var swiftyTimer: SwiftyTimer.Timer?
    
    var users: [User] = []
    var pagination = Pagination()
    
    
    weak var delegate: NewMessageControllerDelegate?
    
    lazy var pullRefresh: UIRefreshControl = {
        let r = UIRefreshControl()
        r.addTarget(self, action: #selector(pullRefreshReload), for: .valueChanged)
        return r
    }()
    lazy var noConnectionFound: EmptyDataView = {
        let v = EmptyDataView.createForNewMessage()
        v.frame = self.view.frame
        return v
    }()
    
    lazy var noInternetConnection: EmptyProfileView = {
        let v = EmptyProfileView.createForNoInternet()
        //v.frame = self.view.frame
        v.frame = self.view.frame
        return v
    }()
    
    //MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableInit()
        commonInit()
        
        searchUsers(with: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        UIApplication.shared.statusBarStyle = .default
//        navigationController?.navigationBar.barTintColor = UIColor.green
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func tableInit(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerSearchTableCell()
        self.tableView.addSubview(pullRefresh)
        
        tableView.addInfiniteScroll {[weak self] (table) in
            self?.searchMore()
        }
        
        tableView.setShouldShowInfiniteScrollHandler {[weak self] (table) -> Bool in
            return self?.pagination.hasNext ?? false
        }
        
    }
    func pullRefreshReload(sender: UIRefreshControl){
        if searchBar.text!.isEmpty {
            pullRefresh.endRefreshing()
            return
        }
        pagination = Pagination()
        searchUsers(with: searchBar.text!)
    }
    
    func commonInit(){
        
        searchBar.subviews.last?.subviews[1].backgroundColor = UIColor.HexToColor("#EFEFF4")
        searchBar.subviews.last?.subviews[1].layer.cornerRadius = 4.0
        searchBar.subviews.last?.subviews[1].layer.masksToBounds = true
        
        let searchBarContainer = SearchBarContainerView(customSearchBar: searchBar)
        searchBarContainer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 30)
        navigationItem.titleView = searchBarContainer
        searchBar.delegate = self
        leftBar = navigationItem.leftBarButtonItem
        navigationItem.rightBarButtonItem = nil
        //rightBar = navigationItem.rightBarButtonItem
    }
    
    //MARK: - ACTIONS

    @IBAction func rightBarButtonPressed(_ sender: UIBarButtonItem) {
    }
    @IBAction func leftBarButtonPressed(_ sender: UIBarButtonItem) {
        self.hideModal()
    }
    
}

extension NewMessageController {
    static func create() -> NewMessageController {
        return UIStoryboard.messages.instantiateViewController(withIdentifier: "NewMessageController") as! NewMessageController
    }
}
extension NewMessageController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueSearchTableCell(indexpath: indexPath)
        let user = users[indexPath.item]
        cell.selectionStyle = .none
        
        cell.usernameLabel.text = user.username
        cell.fullnameLabel.text = user.fullName
        cell.connectButton.isHidden = true
        
        if let image = user.getUrl() {
            cell.userImageView.kf.setImage(with: image, placeholder: user.getPlaceholder())
        }else {
            cell.userImageView.image = #imageLiteral(resourceName: "defaultImageUser")
        }
        
        cell.indexPath = indexPath
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let user = users[indexPath.item]
        
        if let conversation = ConversationManager.shared.conversation(with: user.id) {
            self.view.endEditing(true)
            self.delegate?.searchController(sender: self, didSelect: conversation)
        } else {
            ChatManager.shared.getConversation(user: user.id) {[weak self] (conversation, error) in
                guard let `self` = self else { return }
                self.view.endEditing(true)
                self.tableView.deselectRow(at: indexPath, animated: true)
                
                if let conversation = conversation {
                    conversation.user = user
                    self.delegate?.searchController(sender: self, didSelect: conversation)
                }
                
                if let error = error {
                    Helper.show(alert: error.message)
                }
            }
        }
    }
}

extension NewMessageController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension NewMessageController: UISearchBarDelegate, UIScrollViewDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        Helper.showSearchBar(searchBar: searchBar, navigationItem: navigationItem, newFrameWidth: view.frame.size.width)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        search(with: searchText)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if searchBar.text == nil{
            searchBarCancelButtonClicked(searchBar)
        }
        if let text = searchBar.text, text.isEmpty{
            searchBarCancelButtonClicked(searchBar)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        if let l = leftBar {
            Helper.hideSearchBar(searchBar: searchBar, navigationItem: navigationItem, leftBar: l, rightBar: nil)
        }

        self.noInternetConnection.hide()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func search(with text: String) {
        
        if text.isEmpty {
            swiftyTimer?.invalidate()
            return
        }
        
        swiftyTimer?.invalidate()
        swiftyTimer = SwiftyTimer.Timer.after(0.35, {
            self.searchUsers(with: text)
        })
    }
    
    fileprivate func searchUsers(with username: String) {
        
        ConnectionsAPI.searchForCurrent(username: username, page: 1) {[weak self] (query, users, pagination, error) in
            guard let `self` = self else { return }
            self.noConnectionFound.hide()
            
            guard let text = self.searchBar.text else { return }
            
            if text == query {
                if let users = users, let pagination = pagination {
                    
                    self.users = users
                    self.pagination = pagination
                    self.tableView.reloadData()
                    
                    if users.count == 0 {
                        self.noConnectionFound.show(to: self.tableView)
                    } else {
                        self.noConnectionFound.hide()
                    }
                }
            }
            self.pullRefresh.endRefreshing()
            self.tableView.finishInfiniteScroll()
            
            if let error = error {
                self.noInternetConnection.show(to: self.tableView)
                
                print(error.message)
            }else {
                self.noInternetConnection.hide()
                
            }
        }
        
        if users.count < 1 {
            noConnectionFound.show(to: self.tableView)
        }else {
            noConnectionFound.hide()
        }
        
    }
    
    fileprivate func searchMore() {
        guard let username = searchBar.text, !username.isEmpty else {
            self.tableView.finishInfiniteScroll()
            return
        }
        ConnectionsAPI.searchForCurrent(username: username, page: 1) {[weak self] (query, users, pagination, error) in
            guard let `self` = self else { return }
            
            self.noConnectionFound.hide()
            //guard let `self` = self else { return }
            guard let text = self.searchBar.text else { return }
            
            if text == query {
                if let users = users, let pagination = pagination {
                    self.users.append(contentsOf: users)
                    self.pagination = pagination
                    self.tableView.reloadData()
                }
            }
            self.tableView.finishInfiniteScroll()
            
            if let error = error {
                self.noInternetConnection.show(to: self.tableView)
                
                print(error.message)
            }else {
                self.noInternetConnection.hide()
                
            }
        }
    }
}

