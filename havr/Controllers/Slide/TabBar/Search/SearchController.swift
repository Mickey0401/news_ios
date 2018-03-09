//
//  SearchController.swift
//  havr
//
//  Created by Ismajl Marevci on 4/20/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import SwiftyTimer
import UIScrollView_InfiniteScroll

class SearchController: UIViewController {
    
    //MARK: - OUTLETS
    @IBOutlet weak var rightBarItem: UIBarButtonItem!
    @IBOutlet weak var rightButton: UIButton!

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
    
    lazy var pullRefresh: UIRefreshControl = {
        let r = UIRefreshControl()
        r.addTarget(self, action: #selector(pullRefreshReload), for: .valueChanged)
        return r
    }()
    lazy var searchInfo: EmptyDataView = {
        let v = EmptyDataView.createForSearch()
        v.frame = self.view.frame
        return v
    }()
    
    lazy var noInternetConnection: EmptyProfileView = {
        let v = EmptyProfileView.createForNoInternet()
        //v.frame = self.view.frame
        v.frame = self.view.frame
        return v
    }()
    
    lazy var noResultsFound : EmptyDataView = {
        let nrf = EmptyDataView.createForNoResults()
        
        return nrf
    }()

    
    //MARK: - ACTIONS
    override func viewDidLoad() {
        super.viewDidLoad()
        tableInit()
        commonInit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GA.TrackScreen(name: "Search")

        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("SearchController DidAppear")
    }

    func tableInit(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerSearchTableCell()
        self.tableView.addSubview(pullRefresh)
        
        tableView.addInfiniteScroll { (table) in
            self.searchMore()
        }
        
        tableView.setShouldShowInfiniteScrollHandler { (table) -> Bool in
            return self.pagination.hasNext
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
        leftBar = navigationItem.leftBarButtonItem
        rightBar = navigationItem.rightBarButtonItem

        Helper.setupNavSearchBar(searchBar: searchBar)
        
        let searchBarContainer = SearchBarContainerView(customSearchBar: searchBar)
        searchBarContainer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 30)
        navigationItem.titleView = searchBarContainer
        
        searchBar.delegate = self

        delay(delay: 0) {
//            self.searchBar.becomeFirstResponder()
            self.searchInfo.show(to: self.tableView)
        }
//        delay(delay: 0.05) {
//            self.searchBar.resignFirstResponder()
//        }
    }
    
    //MARK: - ACTIONS
    @IBAction func rightBarItemClicked(_ sender: UIBarButtonItem) {
        if (AccountManager.currentUser?.age)! < 13 {
            Helper.show(alert: "Please set your age in Profile Settings before searching in Nearby.")
            return
        }
        
        if (AccountManager.currentUser?.gender)! == "" || (AccountManager.currentUser?.gender)! == "Other" {
            Helper.show(alert: "Please set your gender in Profile Settings before searching in Nearby.")
            return
        }
        
        let searchResult = NearbyMatchUserController.create()
        self.push(searchResult)
    }
    
    @IBAction func leftBarItemClicked(_ sender: UIBarButtonItem) {
        let searchFilters = SearchFiltersController.create()
        let searchNav = UINavigationController(rootViewController: searchFilters)
        self.showModal(searchNav)
    }
}

//MARK: - EXTENSIONS
extension SearchController {
    static func create() -> SearchController {
        return UIStoryboard.search.instantiateViewController(withIdentifier: "SearchController") as! SearchController
    }
}

extension SearchController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueSearchTableCell(indexpath: indexPath)
        let user = users[indexPath.item]
        cell.selectionStyle = .none
        
        cell.usernameLabel.text = user.username
        cell.fullnameLabel.text = user.fullName
        
        if let image = user.getUrl() {
            cell.userImageView.kf.setImage(with: image, placeholder: user.getPlaceholder())
        }else {
            cell.userImageView.image = #imageLiteral(resourceName: "defaultImageUser")
        }
        
        cell.indexPath = indexPath
        cell.connectButton.backgroundColor = Apperance.appBlueColor
        cell.connectButton.borderColor = Apperance.appBlueColor
        cell.connectButton.setTitleColor( UIColor.white, for: UIControlState())
        
        switch user.status {

        case .connected:
            cell.connectButton.backgroundColor = UIColor.white
            cell.connectButton.borderColor = Apperance.E5E5E5Color
            cell.connectButton.setTitleColor(Apperance.textGrayColor, for: UIControlState())
            cell.connectButton.setTitle("Connected", for: .normal)
            break
        case .connect:
            cell.connectButton.setTitle("Connect", for: .normal)
            break
        case .declined:
            cell.connectButton.setTitle("Connect", for: .normal)
            break
        case .requested:
            cell.connectButton.setTitle("Requested", for: .normal)
            break
            
        case .requesting:
            cell.connectButton.setTitle("Accept", for: .normal)
            break
        case .blocked:
            cell.connectButton.setTitle("", for: .normal)
            break
            
        case .blocking:
            cell.connectButton.setTitle("Unblock", for: .normal)
            break
        }
        
        cell.delegate = self
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.resignFirstResponder()
        searchBar.text = nil
        let user = users[indexPath.item]
        
        let userProfile = UserProfileController.create(for: user)
        userProfile.user = user
        self.push(userProfile)
        
        if let r = rightBar {
            Helper.hideSearchBar(searchBar: searchBar, navigationItem: navigationItem, leftBar: nil, rightBar: r)
        }
        users.removeAll()
        tableView.reloadData()
        self.searchInfo.show(to: self.tableView)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SearchController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
extension SearchController: UISearchBarDelegate, UIScrollViewDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        Helper.showSearchBar(searchBar: searchBar, navigationItem: navigationItem)
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
        
        Helper.hideSearchBar(searchBar: searchBar, navigationItem: navigationItem, leftBar: nil, rightBar: rightBar)
        
        searchBar.text = nil
        users.removeAll()
        tableView.reloadData()
        self.searchInfo.show(to: self.tableView)
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
    
    fileprivate func searchUsers(with name: String) {
        
        UsersAPI.search(name: name, page: 1) {[weak self] (query, users, pagination, error) in
            self?.searchInfo.hide()
            guard let `self` = self else { return }
            guard let text = self.searchBar.text else { return }

            if text == query {
                if let users = users, let pagination = pagination {
                    self.users = users
                    self.pagination = pagination
                    self.tableView.reloadData()
                }
            }
            self.pullRefresh.endRefreshing()
            self.tableView.finishInfiniteScroll()
            
            if let error = error {
//                self.noInternetConnection.show(to: self.tableView)
                Helper.show(alert: error.message)
                print(error.message)
            }else {
                self.noInternetConnection.hide()

            }
            
            if self.users.count == 0 {
                self.noResultsFound.show(to: self.tableView)
            }else {
                self.noResultsFound.hide()
            }
        }
    }
    
    fileprivate func searchMore() {
        guard let name = searchBar.text, !name.isEmpty else {
            self.tableView.finishInfiniteScroll()
            return
        }
        
        UsersAPI.search(name: name, page: pagination.nextPage) {[weak self] (query, users, pagination, error) in
            self?.searchInfo.hide()
            guard let `self` = self else { return }
            guard let text = self.searchBar.text else { return }

            if text == query {
                if let users = users, let pagination = pagination {
                    self.users.append(contentsOf: users)
                    self.pagination = pagination
                    self.tableView.reloadData()
                }
            }
            self.tableView.finishInfiniteScroll()
        }
    }
}

extension SearchController: SearchTableCellDelegate {
    func searchTable(sender: SearchTableCell, didPress actionButton: UIButton, at index: IndexPath) {
        let user = users[index.item]
        actionButton.isEnabled = false
        print("Action button at \(index.item)")
        let type = user.getConnectionActionType()
        switch type {
        case .remove:
            let alert = UIAlertController(title: "Alert", message: "Are you sure you want to disconnect this user?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
                ConnectionsAPI.makeAction(with: type, userId: user.id) { (success, error) in
                    if success{
                        user.setStatus(with: type)
                        self.tableView.reloadData()
                    }else{
                        
                    }
                }
            }))
            
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: {(action) in }))
            
            alert.view.tintColor = Apperance.appBlueColor
            self.present(alert, animated: true, completion: nil)
            alert.view.tintColor = Apperance.appBlueColor
            
            break
        default:
            ConnectionsAPI.makeAction(with: type, userId: user.id) { (success, error) in
                if success{
                    user.setStatus(with: type)
                    self.tableView.reloadData()
                }else{
                    
                }
            }
        }
    }
}
class SearchBarContainerView: UIView {
    
    let searchBar: UISearchBar
    
    init(customSearchBar: UISearchBar) {
        searchBar = customSearchBar
        super.init(frame: CGRect.zero)
        
        addSubview(searchBar)
    }
    
    override convenience init(frame: CGRect) {
        self.init(customSearchBar: UISearchBar())
        self.frame = frame
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        searchBar.frame = bounds
    }
}

