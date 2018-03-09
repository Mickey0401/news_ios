//
//  ContactSearchController.swift
//  havr
//
//  Created by CloudStream on 2/19/18.
//  Copyright © 2018 Tenton LLC. All rights reserved.
//

import UIKit
import SwiftyTimer
import UIScrollView_InfiniteScroll

protocol ContactSelectControllerDelegate: class {
    func selectedUsers(users: [User])
}

class ContactSelectController: UIViewController {
    
    //MARK: - OUTLETS
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    //MARK: - VARIABLES
    var users: [User] = []
    var activedUsers: [User] = []
    var selectedUsers: [User] = []
    
    var pagination = Pagination()
    
    var swiftyTimer: SwiftyTimer.Timer?
    weak var delegate: ContactSelectControllerDelegate?
    
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
        
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("ContactSelectController DidAppear")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    func commonInit(){
        
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
        
        tableView.tableFooterView = UIView()
        
        searchBar.delegate = self
        Helper.configureSearchBar(searchBar: self.searchBar)
    }
    
    func pullRefreshReload(sender: UIRefreshControl){
        if searchBar.text!.isEmpty {
            pullRefresh.endRefreshing()
            return
        }
        pagination = Pagination()
        searchUsers(with: searchBar.text!)
    }
    
    @IBAction func onBtnNext(_ sender: Any) {
        self.dismiss(animated: true){
            if let del = self.delegate {
                del.selectedUsers(users: self.activedUsers)
            }
        }
    }
    
    @IBAction func onBtnCancel(_ sender: Any) {
        self.dismiss(animated: true) {
            if let del = self.delegate {
                del.selectedUsers(users: [User]())
            }
        }
    }
}

extension ContactSelectController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueContactSelectCell(index: indexPath)
        
        let user = users[indexPath.item]
        
        cell.user = users[indexPath.item]
        cell.selectionStyle = .none
        
        if activedUsers.contains(user) {
            cell.ivSelection.image = #imageLiteral(resourceName: "M contact select icon")
        }
        else {
            cell.ivSelection.image = #imageLiteral(resourceName: "M contact unselect icon")
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let user = users[indexPath.item]
        if activedUsers.contains(user) {
            activedUsers.remove(at: activedUsers.index(of: user)!)
        }
        else {
            activedUsers.append(user)
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
        tableView.reloadData()
    }
}

extension ContactSelectController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ContactSelectController {
    static func create() -> ContactSelectController {
        return UIStoryboard.messages.instantiateViewController(withIdentifier: "ContactSelectController") as! ContactSelectController
    }
}

extension ContactSelectController: UISearchBarDelegate, UIScrollViewDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        UIView.animate(withDuration: 0.5, animations: {
            searchBar.showsCancelButton = true
        }, completion: { finished in
            searchBar.becomeFirstResponder()
        })
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
        
        UIView.animate(withDuration: 0.5, animations: {
            searchBar.showsCancelButton = true
        }, completion: { finished in
            searchBar.resignFirstResponder()
        })
        
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
