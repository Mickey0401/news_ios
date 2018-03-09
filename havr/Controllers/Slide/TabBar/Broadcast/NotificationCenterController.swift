//
//  NotificationCenterController.swift
//  havr
//
//  Created by Ismajl Marevci on 6/5/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import UIScrollView_InfiniteScroll

class NotificationCenterController: UIViewController {
    
    //MARK: - OUTLETS
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var leftbarButton: UIBarButtonItem!

    //MARK: - VARIABLES
    var notifications: [APNotification] = [] {
        
        didSet {
            if notifications.count == 0 {
                emptyView.show(to: tableView)
            } else {
                emptyView.hide()
            }
        }
        
    }
    
    var isFromBroadcastVC : Bool = false
    
    let emptyView: EmptyDataView = EmptyDataView.createForNotifications()

    var pagination = Pagination()
    
    lazy var pullRefresh: UIRefreshControl = {
        let r = UIRefreshControl()
        r.addTarget(self, action: #selector(pullRefreshReload), for: .valueChanged)
        return r
    }()
    
    lazy var notificationPermission : AllowPermissionView = {
        
        let nP = AllowPermissionView.createForNotification()
        return nP
    }()
    
    //MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        tableInit()
        
    
        if !Preferences.notfirstTimeInNotifications {
            setupNotificationView()
        }
        
        let titleView = UILabel()
        titleView.font = UIFont.navigationTitleFont
        titleView.text = "Notifications"
        self.navigationItem.titleView = titleView
        
        setupInfiniteScrolling()
        getNotifications()
        
        notificationPermission.permissionButtonPressed = permissionButtonPressed
        notificationPermission.laterButtonPressed = laterButtonPressed
        NotificationCenter.default.addObserver(self, selector: #selector(appEnterForeground), name: Constants.AppEnterForegroundNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        navigationController?.navigationBar.barStyle = . default
//        navigationController?.navigationBar.barTintColor =  .white// UIColor(red255: 251, green255: 250, blue255: 250)
//        navigationController?.navigationBar.backgroundColor =  .white //UIColor(red255: 251, green255: 250, blue255: 250)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GA.TrackScreen(name: "Notifications")

//        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    func tableInit() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerNCInvitationTableCell()
        tableView.registerNCCommentTableCell()
        tableView.registerNCAcceptDenyTableCell()
        tableView.registerNCOneLineTableCell()
    }
    
    func pullRefreshReload(sender: UIRefreshControl){
        pagination = Pagination()
        getNotifications()
    }
    
    func setupInfiniteScrolling() {
        
        self.tableView.addSubview(pullRefresh)

        self.tableView.addInfiniteScroll {[unowned self] (collection) in
            self.getNotifications()
        }
        self.tableView.infiniteScrollTriggerOffset = 120
        
        self.tableView.setShouldShowInfiniteScrollHandler {[unowned self] _ in
            return self.pagination.hasNext
        }
    }
    
    func setupNotificationView() {
        
        let notificationType = UIApplication.shared.currentUserNotificationSettings!.types
        
        if notificationType == [] {
            print("notifications are NOT enabled")
            self.notificationPermission.show(to: self.navigationController!.view)
            Preferences.notfirstTimeInNotifications = true
        } else {
            self.notificationPermission.hide()
        }
    }
    
    func permissionButtonPressed() {
        UIApplication.shared.openURL(NSURL(string:UIApplicationOpenSettingsURLString)! as URL)
    }
    
    func laterButtonPressed() {
        self.notificationPermission.hide()
        setupInfiniteScrolling()
        getNotifications()
    }
    
    func appEnterForeground(notification: Notification) {
        setupNotificationView()
    }
    
    func getNotifications(){
        NotificationsAPI.getNotifications(page: pagination.nextPage) { (notifications, pagination, error) in
            
            self.pullRefresh.endRefreshing()
            self.tableView.finishInfiniteScroll()
            if self.pagination.currentPage == 0{
                self.notifications.removeAll()
            }
            
            if let notifications = notifications, let pagination = pagination{
                self.notifications += notifications
                self.pagination = pagination
            }
            self.tableView.reloadData()
        }
    }
    
    func openUserProfile(with user: User){
        let userProfile = UserProfileController.create(for: user)
        userProfile.isFromBroadcastVC = isFromBroadcastVC
        userProfile.user = user
        self.push(userProfile)
    }
    //MARK: - ACTIONS
    @IBAction func leftbarButtonPressed(_ sender: UIBarButtonItem) {
        self.pop()
    }
}
//MARK: - EXTENSIONS
extension NotificationCenterController {
    static func create() -> NotificationCenterController {
        return UIStoryboard.broadcast.instantiateViewController(withIdentifier: "NotificationCenterController") as! NotificationCenterController
    }
}

extension NotificationCenterController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let notification = notifications[indexPath.row]
        let cell = tableView.dequeueNotificationCenterTableCell(identifier: getCellName(from: notification.type), indexPath: indexPath)
        cell.index = indexPath.row
        cell.delegate = self
        cell.notification = notification
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let model = notifications[safe: indexPath.row] else { return 85 }
        switch model.type {
        case .acceptedConnection, .declinedConnection:
            return 100
        default:
            return 85
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let notification = notifications[indexPath.row]
        if notification.type == .acceptedConnection || notification.type == .requestedConnection || notification.type == .declinedConnection{
            let user = notification.userPerformed
            openUserProfile(with: user)
        }else if notification.type == .likedPost || notification.type == .commentedOnPost || notification.type == .mentionedOnPost{
            if let postId = notification.post?.id{
                getPost(with: postId)
            }
        }
    }
    
    func getPost(with postId: Int){
        PostsAPI.getPost(with: postId) { (post, error) in
            if let post = post{
                let postDetails = PostDetailController.create()
                postDetails.post = post
                postDetails.isFromBroadcastVC = self.isFromBroadcastVC
                self.push(postDetails)
            }else{
                //show alert
            }
        }
    }
    
    private func getCellName(from type: NotificationType) -> String{
        switch type {
        case .acceptedConnection:
            return "NCAcceptedTableCell"
        case .requestedConnection:
            return "NCRequestedTableCell"
        case .declinedConnection:
            return "NCAcceptedTableCell"
        case .likedPost:
            return "NCCommentTableCell"
        case .commentedOnPost:
            return "NCCommentTableCell"
        case .other:
            return "NCCommentTableCell"
        case .mentionedOnPost:
            return "NCCommentTableCell"
        case .chatDeleted:
            return "NCOneLineTableCell"
        }
    }
}

extension NotificationCenterController: NotificationCenterTableDelegate {
    func notificationCenter(sender: NotificationCenterTableCell, didPressAcceptButton button: UIButton) {
        ConnectionsAPI.makeAction(with: .connect, userId: sender.notification.userPerformed.id) { (success, error) in
            if success{
                let notification = self.notifications[sender.index]
                notification.type = .acceptedConnection
                self.tableView.reloadRows(at: [IndexPath.init(row: sender.index, section: 0)], with: .fade)
            }else{
                
            }
        }
    }
    func notificationCenter(sender: NotificationCenterTableCell, didPressDeclineButton button: UIButton) {
        ConnectionsAPI.makeAction(with: .decline, userId: sender.notification.userPerformed.id) { (success, error) in
            if success{
                let notification = self.notifications[sender.index]
                notification.type = .declinedConnection
                self.tableView.reloadRows(at: [IndexPath.init(row: sender.index, section: 0)], with: .fade)
            }else{
                
            }
        }
    }
    func notificationCenter(sender: NotificationCenterTableCell, didPressViewProfileButton button: UIButton) {
        let user = sender.notification.userPerformed
        openUserProfile(with: user)
    }
}
