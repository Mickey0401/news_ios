//
//  ConnectionsController.swift
//  havr
//
//  Created by Agon Miftari on 4/24/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import SwiftyTimer
import UIScrollView_InfiniteScroll
import MBProgressHUD

class ConnectionsController: UIViewController {

    //MARK: - OUTLETS
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - VARIABLES
    var users: [User] = []
    var user: User = User()
    var pagination = Pagination()
    var navTitle = ""
    lazy var pullRefresh: UIRefreshControl = {
        let r = UIRefreshControl()
        r.addTarget(self, action: #selector(pullRefreshReload), for: .valueChanged)
        return r
    }()
    
    @IBAction func back(_ sender: Any) {
        self.pop(true)
    }
    
    //MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()

        commonInit()
        tableInit()
        getConnections()
        getFollowers()
        Helper.setupTransparentNavigationBar(nav: navigationController!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GA.TrackScreen(name: "Connections")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func commonInit() {
        self.navigationItem.title = navTitle
    }
    
    func tableInit() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerSearchTableCell()
        tableView.addSubview(pullRefresh)
        
        tableView.addInfiniteScroll { (table) in
            self.getConnections()
        }
        
        tableView.setShouldShowInfiniteScrollHandler { (table) -> Bool in
            return self.pagination.hasNext
        }
    }
    
    func pullRefreshReload(sender: UIRefreshControl){
        pagination = Pagination()
        getConnections()
    }
    
    func getConnections(){
        if self.users.count == 0{
            self.showHud()
        }
        ConnectionsAPI.getConnections(for: user.id, page: self.pagination.currentPage + 1) {
            (connections, pagination, error) in
            
            self.pullRefresh.endRefreshing()
            self.tableView.finishInfiniteScroll()
            self.hideHud()
            
            if let connections = connections, let pagination = pagination {
                if self.pagination.currentPage == 0{
                    self.users = []
//                    self.users = Array.init(repeating: User(), count: 10)
                }
                self.users += connections
                self.pagination = pagination
                self.tableView.reloadData()
            }
            if let error = error {
                console(error.message)
            }
        }
    }
}

//MARK: - EXTENSIONS
extension ConnectionsController {
    static func create() -> ConnectionsController {
        return UIStoryboard.profile.instantiateViewController(withIdentifier: "ConnectionsController") as! ConnectionsController
    }
}

extension ConnectionsController : UITableViewDelegate, UITableViewDataSource {
    
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
        let user = users[indexPath.item]
        
        let userProfile = UserProfileController.create(for: user)
        userProfile.user = user
        self.push(userProfile)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ConnectionsController {
    func getFollowers() {
        ConnectionsAPI.searchConnection(username: user.username, page: self.pagination.currentPage + 1, userId: user.id) { (string, users, pagination, error) in
            print(string, users, pagination, error)
        }
    }
}

extension ConnectionsController: SearchTableCellDelegate {
    func searchTable(sender: SearchTableCell, didPress actionButton: UIButton, at index: IndexPath) {
        let user = users[index.item]
        actionButton.isEnabled = false
        print("Action button at \(index.item)")
        let type = user.getConnectionActionType()
        
        switch type {
        case .remove:
            let alert = UIAlertController(title: "Alert", message: "Are you sure you want to disconnect this user?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
                ConnectionsAPI.makeAction(with: type, userId: self.user.id) { (success, error) in
                    if success{
                        self.user.setStatus(with: type)
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
                    self.user.setStatus(with: type)
                    self.tableView.reloadData()
                }else{
                    
                }
            }
        }
    }
}
