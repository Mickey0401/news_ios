//
//  BlockedListController.swift
//  havr
//
//  Created by Ismajl Marevci on 4/28/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import FaceAware
import DZNEmptyDataSet

class BlockedListController: UIViewController {

    //MARK: - OUTLETS
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.emptyDataSetSource = self
            tableView.emptyDataSetDelegate = self
        }
    }
    @IBOutlet weak var leftBarButton: UIBarButtonItem!
    
    //MARK: - VARIABLES
    var users: [User] = []
    var user: User = User()
    var pagination = Pagination()
    lazy var pullRefresh: UIRefreshControl = {
        let r = UIRefreshControl()
        r.addTarget(self, action: #selector(pullRefreshReload), for: .valueChanged)
        return r
    }()
    
//    lazy var noBlockedFound: EmptyDataView = {
//        let v = EmptyDataView.createForBlocked()
//        v.frame = self.tableView.frame
//        return v
//    }()
    
    //MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        tableInit()
        tableInit()
        getBlockedList()
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
//        navigationController?.navigationBar.backgroundColor = UIColor(red255: 251, green255: 250, blue255: 250)
//        UINavigationBar.appearance().barTintColor = UIColor.white
//        navigationController?.navigationBar.backgroundColor = UIColor(red255: 251, green255: 250, blue255: 250)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GA.TrackScreen(name: "Blocked List")
    }
    
    func tableInit() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerSearchTableCell()
        tableView.addSubview(pullRefresh)
        
        tableView.addInfiniteScroll { (table) in
            self.getBlockedList()
        }
        
        tableView.setShouldShowInfiniteScrollHandler { (table) -> Bool in
            return self.pagination.hasNext
        }
//        self.noBlockedFound.show(to: self.tableView)
    }
    
    func pullRefreshReload(sender: UIRefreshControl){
        pagination = Pagination()
        getBlockedList()
    }
    
    func getBlockedList(){
        ConnectionsAPI.getBlockedList(page: self.pagination.currentPage + 1) { (blocked, pagination, error) in
            self.pullRefresh.endRefreshing()
            self.tableView.finishInfiniteScroll()
            //self.indicator.stopAnimating()
            
            if let blocked = blocked, let pagination = pagination {
//                self.noBlockedFound.hide()
                if self.pagination.currentPage == 0{
                    self.users = []
                    //                    self.users = Array.init(repeating: User(), count: 10)
                }
                self.users += blocked
                let userStore = UserDefaults.standard
                var array = userStore.value(forKey: "blockked_id_key") as? [Int] ?? [Int]()
                    array = self.users.map({ $0.id })
                userStore.set(array, forKey: "blockked_id_key")
                self.pagination = pagination
                self.tableView.reloadData()
            }
            
            if self.users.count == 0 {
//                self.noBlockedFound.show(to: self.tableView)
            }
            
            if let error = error {
                console(error.message)
            }
        }
    }
    //MARK: - ACTIONS
    @IBAction func leftBarButtonPressed(_ sender: UIBarButtonItem) {
        self.pop()
    }
    
}
//MARK: - EXTENSIONS
extension BlockedListController {
    static func create() -> BlockedListController {
        return UIStoryboard.settings.instantiateViewController(withIdentifier: "BlockedListController") as! BlockedListController
    }
}
extension BlockedListController: UITableViewDelegate, UITableViewDataSource {
    
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
        
        cell.connectButton.setTitleColor(Apperance.textGrayColor, for: .normal)
        cell.connectButton.backgroundColor = UIColor.white

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
        cell.bottomLine.isHidden = !(users.count == indexPath.row + 1)
        cell.delegate = self
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.item]
        
        let userProfile = UserProfileController.create(for: user)
        userProfile.user = user
        self.push(userProfile)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
extension BlockedListController: SearchTableCellDelegate {
    func searchTable(sender: SearchTableCell, didPress actionButton: UIButton, at index: IndexPath) {
        let user = users[index.item]
        actionButton.isEnabled = false
        print("Action button at \(index.item)")
        let type = user.getConnectionActionType()
        
        if user.status == .blocked {
            return
        }
        ConnectionsAPI.blockUser(with: type, userId: user.id) { (success, error) in
            if success {
                user.setStatus(with: type)
                self.tableView.reloadRows(at: [index], with: .none)
            }else {
                
            }
        }
    }
}

extension BlockedListController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes = [NSForegroundColorAttributeName: UIColor.lightGray,
                          NSFontAttributeName: UIFont.helveticaRegualr(14)]

        return NSAttributedString(string: "No blocked users yet", attributes: attributes)
    }
}
