//
//  BroadcastController.swift
//  havr
//
//  Created by Agon Miftari on 4/21/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import AVFoundation
import MBProgressHUD
import SkeletonView
import TwitterKit
import SVWebViewController
import SHGWebViewController

class BroadcastController: UIViewController {
    
    //MARK: - OUTLETS
    @IBOutlet weak var leftBarButton: UIBarButtonItem!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - VARIABLES
    var user = AccountManager.currentUser
    var leftBar : UIBarButtonItem?
    var rightBar : UIBarButtonItem?
    lazy var searchBar : UISearchBar = {
        Helper.exploreStatusBar(placeholder: "Search")
    }()
//    var pagination = Pagination()
    
    let broadcastService = BroascastPostsService()
    
    var selectedPost = Post()
    var postIndex : Int = 0
    var canScrollToTop: Bool = true
    
    lazy var pullRefresh: UIRefreshControl = {
        let r = UIRefreshControl()
        r.addTarget(self, action: #selector(pullRefreshReload), for: .valueChanged)
        return r
    }()
    var broadcasts: [BroadcastCellModel] = []
    fileprivate var returnedFromSearch = false
    
    //Video
    var player = AVPlayer()
    var playerItem: AVPlayerItem?
    var playerTimeObserver: Any?
    var fullSizeVideo: FullSizeController?
    var videoView: VideoView?
    var videoContainer: UIView?
    fileprivate var locationManager = CLLocationManager()
    fileprivate var didRefresh = false
    
    var lastVisibleCell: IndexPath? = IndexPath.init(row: 0, section: 0)
    
    lazy var somethingWrong : EmptyDataView = {
        let sW = EmptyDataView.createForSomethingWrong()
        return sW
    }()
    
    //MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 48.0
        tableInit()
        commonInit()
        setLeftButton()
        getBroadcasts()
        forceIncreaseVolumeInPlayer()
        PushNotificationManager.register(application: UIApplication.shared)
        setupLocationManager()
        view.showAnimatedSkeleton()
        //        let tutorial = TutorialController.create()
        //        self.showModal(tutorial)
    }
    
    deinit {
        deallocObservers(player: playerItem)
        player.pause()
    }
    
    private func deallocObservers(player: AVPlayerItem?) {
        player?.removeObserver(self, forKeyPath: "status")
        player?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        player?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        player?.removeObserver(self, forKeyPath: "playbackBufferFull")
        player?.removeObserver(self, forKeyPath: "loadedTimeRanges")
        if let pto = playerTimeObserver{
            self.player.removeTimeObserver(pto)
        }
    }

    
    // Called when the view becomes available
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GA.TrackScreen(name: "Broadcast")
//        self.navigationController?.navigationBar.backgroundColor =  .white
        self.navigationController?.navigationItem.rightBarButtonItem?.tintColor = UIColor.lightGray
//        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        DispatchQueue.main.async {
            self.setStatusBarBackgroundColor(color: .clear)
        }
        canScrollToTop = true
    }
    
    // Called when the view becomes unavailable
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //        UIApplication.shared.statusBarStyle = .default
        
        canScrollToTop = false
        if (fullSizeVideo == nil) {
            resetVideoView()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if returnedFromSearch {
            searchBar.becomeFirstResponder()
            returnedFromSearch = false
        }
    }
    
    func resetVideoView(){
        videoView?.reset()
        videoView = nil
    }
    
    func setupLocationManager(){
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    // Scrolls to top nicely
    func scrollToTop() {
        self.tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    func tableInit(){
        tableView.delegate = self
        tableView.dataSource = self
 
        self.tableView.addSubview(pullRefresh)
        leftButton.imageView?.contentMode = .scaleAspectFit
        setupInfiniteScrolling()
    }
    func setupInfiniteScrolling() {
        self.tableView.addInfiniteScroll {[unowned self] (collection) in
            self.getBroadcasts()
        }
        self.tableView.infiniteScrollTriggerOffset = 100
        
//        self.tableView.setShouldShowInfiniteScrollHandler {[unowned self] _ in
//            return self.pagination.hasNext
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setLeftButton()
        //        self.tableView.reloadData()
    }
    
    
    func setLeftButton() {
        leftButton.setImage(Constants.defaultImageUser, for: UIControlState())
        if let image = user?.getUrl() {
            leftButton.kf.setImage(with: image, for: UIControlState())
        }else {
            leftButton.setImage(Constants.defaultImageUser, for: UIControlState())
        }
    }
    
    func commonInit()  {
        leftBar = navigationItem.leftBarButtonItem
        rightBar = navigationItem.rightBarButtonItem
        rightBar?.tintColor = UIColor.lightGray
        delay(delay: 0) {
            self.navigationItem.setLeftBarButton(nil, animated: true)
            if let l = self.leftBar, let r = self.rightBar {
                Helper.hideSearchBar(searchBar: self.searchBar, navigationItem: self.navigationItem, leftBar: l, rightBar: r)
            }
        }
        
        leftButton.frame = CGRect(x: 0, y: 0, width: 37, height: 37)
        leftButton.imageEdgeInsets = UIEdgeInsetsMake(7, 2, 7, 12)
        leftButton.widthAnchor.constraint(equalToConstant: 37).isActive = true
        leftButton.heightAnchor.constraint(equalToConstant: 37).isActive = true
        leftButton.imageView?.cornerRadius = 12
        leftButton.contentMode = .scaleAspectFill
        leftButton.setImage(Constants.defaultImageUser, for: UIControlState())
        
        UISearchBar.appearance().setImage(#imageLiteral(resourceName: "search icon"), for: .search, state: .normal)
        
        Helper.setupNavSearchBar(searchBar: searchBar)
        
        let searchBarContainer = SearchBarContainerView(customSearchBar: searchBar)
        searchBarContainer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 30)
        
        searchBarContainer.backgroundColor = UIColor.clear        
        navigationItem.titleView = searchBarContainer
        searchBar.delegate = self
        
        self.somethingWrong.delegate = self
    }
    
    func pullRefreshReload(sender: UIRefreshControl){
//        pagination = Pagination()
        resetVideoView()
        didRefresh = true
        self.broadcastService.reset()
        getBroadcasts()
    }
    
    func getBroadcasts(){
        broadcastService.broadcat { broadcasts, error in
            self.pullRefresh.endRefreshing()
            self.tableView.finishInfiniteScroll()
            self.somethingWrong.hide()
            if self.didRefresh {
                self.didRefresh = false
                self.broadcasts.removeAll()
            }
            self.broadcasts += broadcasts
            print("broadcasts count = \(self.broadcasts.count)")
            DispatchQueue.main.async {
                self.view.stopSkeletonAnimation()
                self.tableView.stopSkeletonAnimation()
                self.tableView.hideSkeleton()
                self.tableView.reloadData()
            }
            
            if let _ = error {
                self.somethingWrong.show(to: self.tableView)
            }
        }
        if self.broadcasts.count == 0{
            //                    showHud()
        }
        
        //        BroadcastAPI.getBroadcasts(page: pagination.nextPage) { (broadcasts, pagination, error) in
        //            self.pullRefresh.endRefreshing()
        //            self.tableView.finishInfiniteScroll()
        //            //            self.hideHud()
        //            self.somethingWrong.hide()
        //
        //            if self.pagination.currentPage == 0{
        //                self.broadcasts.removeAll()
        //            }
        //            if let broadcasts = broadcasts, let pagination = pagination{
        //                self.pagination = pagination
        //                self.broadcasts += broadcasts as [BroadcastCellModel]
        //
        //                delay(delay: 0, closure: {
        //                    self.view.stopSkeletonAnimation()
        //                    self.tableView.hideSkeleton()
        //                    self.tableView.reloadData()
        //                })
        //            }
        //
        //            if let _ = error {
        //                self.somethingWrong.show(to: self.tableView)
        //            }
        //        }
    }
    
    
    func sharePost(post: Post, sender: UIButton) {
        let alert = UIAlertController(title: "Alert", message: "Are you sure you want to promote this post?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
            self.showHud()
            PostsAPI.share(post: post) { (success, error) in
                self.hideHud()
                
                if success {
                    MBProgressHUD.showWithStatus(view: self.view, text: "Promoted", image: #imageLiteral(resourceName: "SUCCESS"))
                    sender.setImage(post.isPromoted() ? #imageLiteral(resourceName: "save_selected") : #imageLiteral(resourceName: "save") , for: .normal)
                }else {
                    if let error = error  {
                        MBProgressHUD.showWithStatus(view: self.view, text: error.message, image: #imageLiteral(resourceName: "ERROR"))
                    }
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: {(action) in }))
        
        if let wPPC = alert.popoverPresentationController {
            let barButtonItem = self.navigationItem.rightBarButtonItem!
            let buttonItemView = barButtonItem.value(forKey: "view")
            wPPC.sourceView = buttonItemView as? UIView
            wPPC.sourceRect = (buttonItemView as AnyObject).bounds
        }
        alert.view.tintColor = Apperance.appBlueColor
        self.present(alert, animated: true, completion: nil)
        alert.view.tintColor = Apperance.appBlueColor
    }
    func deletePost(post: Post){
        let alert = UIAlertController(title: "Alert", message: "Are you sure you want to delete the post?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
            self.showHud()
            PostsAPI.delete(post: post) { (success, error) in
                self.hideHud()
                if success {
                    MBProgressHUD.showWithStatus(view: self.view, text: "Deleted", image: #imageLiteral(resourceName: "SUCCESS"))
                }else {
                    MBProgressHUD.showWithStatus(view: self.view, text: error!.message, image: #imageLiteral(resourceName: "ERROR"))
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: {(action) in }))
        
        if let wPPC = alert.popoverPresentationController {
            let barButtonItem = self.navigationItem.rightBarButtonItem!
            let buttonItemView = barButtonItem.value(forKey: "view")
            wPPC.sourceView = buttonItemView as? UIView
            wPPC.sourceRect = (buttonItemView as AnyObject).bounds
        }
        alert.view.tintColor = Apperance.appBlueColor
        self.present(alert, animated: true, completion: nil)
        alert.view.tintColor = Apperance.appBlueColor
    }
    
    @IBAction func rightButtonPressed(_ sender: UIBarButtonItem) {
        let notificationVC = NotificationCenterController.create()
        notificationVC.isFromBroadcastVC = true
        self.push(notificationVC)
    }
    
    // Video
    // MARK: Set Volume On, even in mute mode
    func forceIncreaseVolumeInPlayer(){
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: [])
    }
}

//MARK: - EXTENSIONS
extension BroadcastController {
    static func create() -> BroadcastController {
        return UIStoryboard.broadcast.instantiateViewController(withIdentifier: "BroadcastController") as! BroadcastController
    }
}


extension BroadcastController: UITableViewDelegate, SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdenfierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "BroadcastTableCell"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return broadcasts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = broadcasts[safe: indexPath.row] else { return UITableViewCell() }
        switch model {
        case let item where item as? BroadcastPost != nil:
            let delegates: BroadcastCellDelegate = (self as BroadcastControllerDelegate, self as VideoPlayerViewDelegate, self as MentionLabelDelegate, self as URLLabelDelegate)
            let cell = model.tableView(tableView, cellForRowAt: indexPath, with: delegates)
            UIView.animate(withDuration: 0, animations: {
                cell.layoutIfNeeded()
                cell.hideSkeleton()
            })
            cell.selectionStyle = .none
            return cell
        case let item where item as? TweetBroadcastModel != nil:
            let delegate: BroadcastCellDelegate = (nil, nil, nil, self as URLLabelDelegate)
            let cell = model.tableView(tableView, cellForRowAt: indexPath, with: delegate)
            cell.selectionStyle = .none
            return cell
            
        case let item where item as? BroadcastNews != nil:
            let cell = item.tableView(tableView, cellForRowAt: indexPath, with: nil)
            cell.selectionStyle = .none
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == broadcasts.count - 5 {
            getBroadcasts()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let model = broadcasts[safe: indexPath.row] else { return }
        switch model {
        case let item where item as? TweetBroadcastModel != nil:
            let tweet = item as! TweetBroadcastModel
            let url = tweet.url
            let webNav = WebNavigationController()
            webNav.setup(url: url?.absoluteString)
            
            present(webNav, animated: true, completion: nil)
            tableView.deselectRow(at: indexPath, animated: true)
        case let item where item as? BroadcastNews != nil:
            let news = item as! BroadcastNews
            let url = news.url
            let webNav = WebNavigationController()
            webNav.setup(url: url.absoluteString)
            
            present(webNav, animated: true, completion: nil)
            tableView.deselectRow(at: indexPath, animated: true)
        default:
            break
        }
    }
}

extension BroadcastController : BroadcastControllerDelegate {
    //FIX-IT: Dublicated code from extension BroadcastSearchController : BroadcastControllerDelegate
    func broadcastCell(_ sender: BroadcastTableCell, didPressMoreButtonFor post: Post) {
        //let alertController = UIAlertController(title: "Select action", message: "For post: \(post.title)", preferredStyle: .actionSheet)
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//        let reactionAction = UIAlertAction(title: "Create Reaction", style: .default, handler: { action in
//            self.selectedPost = post
//            let videoReactionVC = VideoReactionController.create(for: post)
//            let nav = UINavigationController(rootViewController: videoReactionVC)
//            self.showModal(nav)
//        })
        let reportAction = UIAlertAction(title: "Report", style: .destructive, handler: { action in
            self.showReportOptions(for: post)
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        //alertController.addAction(reactionAction)
        alertController.addAction(reportAction)
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func broadcastCell(sender: BroadcastTableCell, didPressMoreDescriptionButton button: UIButton) {
        let detailsVC = PostDetailController.create()
        let broadcast = broadcasts[sender.index]
        selectedPost = broadcast.posts[broadcast.currentPage!]
        
        detailsVC.post = selectedPost
        detailsVC.commentDelegate = self
        detailsVC.isFromBroadcastVC = true
        
        self.push(detailsVC)
    }
    
    func broadcastCell(sender: BroadcastTableCell, didPressPromoteButton button: UIButton) {
        button.isEnabled = false
        let store = UserStore.shared
        let broadcast = broadcasts[sender.index]
        let selectedPost =  broadcast.posts[broadcast.currentPage!]
        self.selectedPost = selectedPost
        PostsAPI.savePost(with: String(selectedPost.id), completion: { (isChanged, error) in
            guard let error = error else {
                DispatchQueue.main.async {
                    button.isEnabled = true
                    button.setImage(isChanged ? #imageLiteral(resourceName: "save_selected") : #imageLiteral(resourceName: "save") , for: .normal)
                    if isChanged {
                        store.savePost(with: selectedPost.id)
                    } else {
                        store.removeSavedPost(id: selectedPost.id)
                    }
                }
                return
            }
            print(error)
        })
    }
    
    func broadcastCell(sender: BroadcastTableCell, didPressMoreButton button: UIButton) {
        let broadcast = broadcasts[sender.index]
        selectedPost = broadcast.posts[broadcast.currentPage!]
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Promote", style: .default, handler: { (action) in
            self.sharePost(post: self.selectedPost, sender: button)
        }))
        if !selectedPost.isMine() {
            alert.addAction(UIAlertAction(title: "Report", style: .destructive, handler:  {
                (alert: UIAlertAction!) -> Void in
                self.showReportOptions(for: self.selectedPost)
            } ))
        }
        
        
        if selectedPost.isMine() {
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                self.deletePost(post: self.selectedPost)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action) in
            
        }))
        
        if let wPPC = alert.popoverPresentationController {
            let barButtonItem = self.navigationItem.rightBarButtonItem!
            let buttonItemView = barButtonItem.value(forKey: "view")
            wPPC.sourceView = buttonItemView as? UIView
            wPPC.sourceRect = (buttonItemView as AnyObject).bounds
        }
        alert.view.tintColor = Apperance.appBlueColor
        self.present(alert, animated: true, completion: nil)
        alert.view.tintColor = Apperance.appBlueColor
    }
    
    
    func showReportOptions(for post: Post){
        var reportMessage: ReportPostMessage = .accountHacked
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        
        alert.addAction(UIAlertAction(title: ReportPostMessage.accountHacked.description, style: .default, handler: {(action) in
            self.reportPost(post: post, message: reportMessage)
        }))
        
        alert.addAction(UIAlertAction(title: ReportPostMessage.inappropriate.description, style: .default, handler: {(action) in
            reportMessage = .inappropriate
            self.reportPost(post: post, message: reportMessage)
        }))
        
        alert.addAction(UIAlertAction(title: ReportPostMessage.spam.description, style: .default, handler: {(action) in
            reportMessage = .spam
            self.reportPost(post: post, message: reportMessage)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action) in
            
        }))
        
        if let wPPC = alert.popoverPresentationController {
            let barButtonItem = self.navigationItem.rightBarButtonItem!
            let buttonItemView = barButtonItem.value(forKey: "view")
            wPPC.sourceView = buttonItemView as? UIView
            wPPC.sourceRect = (buttonItemView as AnyObject).bounds
        }
        alert.view.tintColor = Apperance.appBlueColor
        self.present(alert, animated: true, completion: nil)
        alert.view.tintColor = Apperance.appBlueColor
    }
    
    func reportPost(post: Post, message: ReportPostMessage){
        self.showHud()
        PostsAPI.report(post: post, reportMessage: message, reportPlace: ReportPostPlace.inInterests) { (success, error) in
            self.hideHud()
            if success {
                MBProgressHUD.showWithStatus(view: self.view, text: "Thank you for reporting this!", image: #imageLiteral(resourceName: "SUCCESS"))
            }else {
                if let error = error  {
                    MBProgressHUD.showWithStatus(view: self.view, text: error.message, image: #imageLiteral(resourceName: "ERROR"))
                }
            }
        }
    }
    
    func broadcastCell(sender: BroadcastTableCell, didPressPostSupoortButton button: UIButton) {
        let connectionsVC = ConnectionsController.create()
        connectionsVC.navTitle = "Supporters"
        self.push(connectionsVC)
    }
    func broadcastCell(sender: BroadcastTableCell, didPressPostCommentsButton button: UIButton) {
        let detailsVC = PostDetailController.create()
        let broadcast = broadcasts[sender.index]
        selectedPost = broadcast.posts[broadcast.currentPage!]
        detailsVC.post = selectedPost
        detailsVC.isFromBroadcastVC = true
        self.push(detailsVC)
    }
    func broadcastCell(sender: BroadcastTableCell, didPressisLikeButton button: UIButton) {
        button.bubble(scale: 1.4, with: 0.15)
        let broadcast = broadcasts[sender.index]
        selectedPost = broadcast.posts[broadcast.currentPage!]
        PostsAPI.likeUnlike(the: selectedPost) { (success, isLiked, error) in
            if success{
                self.selectedPost.isLiked = isLiked!
                if self.selectedPost.isLiked{
                    self.selectedPost.likesCount += 1
                }else{
                    self.selectedPost.likesCount -= 1
                }
                let index = self.tableView.indexPath(for: sender)
                delay(delay: 0, closure: {
                    self.tableView.reloadData()
                })
            }else{
                
            }
        }
    }
    func broadcastCell(sender: BroadcastTableCell, didSelectAt view: UIView) {
        let detailsVC = PostDetailController.create()
        let broadcast = broadcasts[sender.index]
        selectedPost = broadcast.posts[broadcast.currentPage!]
        detailsVC.post = selectedPost
        detailsVC.isFromBroadcastVC = true
        self.push(detailsVC)
    }
    func broadcastCell(sender: BroadcastTableCell, didSelectComment user: User) {
        let detailsVC = PostDetailController.create()
        let broadcast = broadcasts[sender.index]
        selectedPost = broadcast.posts[broadcast.currentPage!]
        detailsVC.post = selectedPost
        detailsVC.isFromBroadcastVC = true
        self.push(detailsVC)
        
        //        if user.id == AccountManager.currentUser!.id {
        //            let profile = ProfileController.create()
        //            profile.openedFromPush = true
        //            self.push(profile)
        //        }else{
        //            let userProfile = UserProfileController.create(for: user)
        //            userProfile.isFromBroadcastVC = true
        //            self.push(userProfile)
        //        }
    }
    
    func broadcastCell(sender: BroadcastTableCell, didPressName user: User) {
        if user.id == AccountManager.currentUser!.id {
            let profile = ProfileController.create()
            profile.openedFromPush = true
            self.push(profile)
        }else{
            let userProfile = UserProfileController.create(for: user)
            userProfile.isFromBroadcastVC = true
            self.push(userProfile)
        }
    }
    func broadcastCell(sender: BroadcastTableCell, didPressReactionButton button: UIButton) {
        
        
        let broadcast = broadcasts[sender.index]
        selectedPost = broadcast.posts[broadcast.currentPage!]
        
        let videoReactionVC = VideoReactionController.create(for: selectedPost)
        
        let nav = UINavigationController(rootViewController: videoReactionVC)
        
        self.showModal(nav)
    }
    
    func broadcastCell(sender: BroadcastTableCell, didChangePageAt index: Int) {
        resetVideoView()
    }
    
    func broadcastCell(sender: BroadcastTableCell, didTapAt image: UIImage) {
        let preview = PreviewImageController.create(image: image)
        self.showModal(preview)
    }
}

extension BroadcastController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension BroadcastController : EmptyDataViewDelegate {
    func emptyDataView(sender: EmptyDataView, didPress action: UIButton) {
        self.somethingWrong.hide()
        getBroadcasts()
    }
}

extension BroadcastController: UISearchBarDelegate, UIScrollViewDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        Helper.showSearchBar(searchBar: searchBar, navigationItem: navigationItem, newFrameWidth: view.frame.size.width)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        hideSearchBar()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        if let text = searchBar.text{
            let broadcastSearchVC = BroadcastSearchController.create()
            broadcastSearchVC.textToSearch = text
            self.push(broadcastSearchVC)
            returnedFromSearch = true
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        hideSearchBar()
        updateMostVisibleCell()
    }
    
    func updateMostVisibleCell(){
        let visibleRect = CGRect(origin: tableView.contentOffset, size: tableView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        if let visibleIndexPath = tableView.indexPathForRow(at: visiblePoint){
            if let lastVisible = lastVisibleCell {
                if visibleIndexPath != lastVisible {
                    resetVideoView()
                }else{
                    
                }
            }
            
            lastVisibleCell = visibleIndexPath
        }
    }
    
    func hideSearchBar() {
        if let l = leftBar, let r = rightBar {
            Helper.hideSearchBar(searchBar: searchBar, navigationItem: navigationItem, leftBar: l, rightBar: r)
        }
        searchBar.text = nil
    }
}

extension BroadcastController: VideoPlayerViewDelegate{
    func videoControl(sender: VideoView, didTapAt view: UIView){
        console("didTapAt")
    }
    
    func videoControl(sender: VideoView, didPressFullScreen button: UIButton){
        console("didPressFullScreen")
        
        delay(delay: 0) {
            if let _ = self.fullSizeVideo{
                self.videoView = sender
                self.videoContainer?.addSubview(sender)
                sender.addEdgeConstraints()
                
                self.fullSizeVideo?.hideModal()
                self.fullSizeVideo = nil
                
                if sender.playPauseButton.isSelected{
                    sender.playPauseButtonPressed(sender.playPauseButton)
                }
            }else{
                self.videoView = nil
                self.videoContainer = sender.superview
                self.fullSizeVideo = FullSizeController.create()
                self.fullSizeVideo!.modalTransitionStyle = .crossDissolve
                self.fullSizeVideo!.post = sender.post
                self.showModal(self.fullSizeVideo!)
                self.fullSizeVideo?.videoView = sender
            }
        }
    }
    
    func videoControl(sender: VideoView, didPressPlayPause button: UIButton){
        console("didPressPlayPause")
        
        videoView = sender
        if button.isSelected {
            sender.play()
            if !sender.isFullScreen{
                sender.fullscreenButtonPressed(sender.fullscreenButton)
            }
        }else{
            sender.pause()
        }
    }
    
    func videoControl(sender: VideoView, didPressVolume button: UIButton){
        console("didPressVolume")
        sender.isMuted = button.isSelected
    }
    
    func videoControl(onPlayBy sender: VideoView) {
        if sender.isFullScreen {
            sender.play()
        }
    }
    
    func videoControl(onPauseBy sender: VideoView) {
        
    }
    
    func videoControl(onTimeChange time: String, sender: VideoView) {
        sender.timeLabel.text = time
    }
}

extension BroadcastController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            manager.stopUpdatingLocation()
            AccountManager.currentLocation = location
            
            UsersAPI.updateLocation(with: location.coordinate.latitude, longitude: location.coordinate.longitude, completion: { (success, error) in
                if !success{
                    manager.startUpdatingLocation()
                }
            })
        }
    }
}

extension BroadcastController: MentionLabelDelegate {
    func didSelect(_ text: String, type: ActiveType) {
        if type == .mention {
            if text == AccountManager.currentUser!.username {
                let profile = ProfileController.create()
                profile.openedFromPush = true
                profile.isFromMessagesVC = false
                self.push(profile)
                return
            }
            self.showHud()
            UsersAPI.getUser(username: text, completion: { (user, error) in
                self.hideHud()
                if let user = user {
                    let userProfile = UserProfileController.create(for: user)
                    userProfile.isFromBroadcastVC = true
                    self.push(userProfile)
                }
            })
        }
    }
}

extension BroadcastController {
    func getSavedPostId(completion: () -> Void) {
        PostsAPI.savedPosts { (posts, pagination, error) in
            guard let posts = posts, let pagination = pagination else {
                guard let error = error else {
                    print("didn't get posts and error \(#file) on line \(#line)")
                    return
                }
                print(error)
                return
            }
            let store = UserStore.shared
            let ids = posts.map({ $0.id })
            ids.forEach({ store.savePost(with: $0) })
        }
    }
}

extension BroadcastController: URLLabelDelegate {
    func twitterCell(_ cell: TwitterTableCell, didPressUrl url: String) {
        guard let url = URL(string: url) else { return }
        guard let webController = SVWebViewController(url: url) else { return }
        webController.view.backgroundColor = .white
        webController.title = "Twitter"
        webController.navigationItem.backBarButtonItem?.title = "aaa"
        push(webController, animated: true, hideBottomBar: true)
    }
    
    func twitterCell(_ cell: TwitterTableCell, didPressHashtag hashtag: String) {
    }
}

extension Collection where Indices.Iterator.Element == Index {
    subscript (safe index: Index) -> Generator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension BroadcastController: PostDetailsCommentDelegate {
    func didDelete(post: Post, commentId: Int) {
        
    }
}
