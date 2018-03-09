//
//  BroadcastSearchController.swift
//  havr
//
//  Created by Arben Pnishi on 8/2/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import AVFoundation
import MBProgressHUD
import SVWebViewController
import DZNEmptyDataSet

class BroadcastSearchController: UIViewController {
    
    //MARK: - OUTLETS
    @IBOutlet weak var leftBarButton: UIBarButtonItem!
//    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.emptyDataSetSource = self
            tableView.emptyDataSetDelegate = self
        }
    }
    
    //MARK: - VARIABLES
    let user = AccountManager.currentUser
    var leftBar : UIBarButtonItem?
    var rightBar : UIBarButtonItem?
    var pagination = Pagination()
    var textToSearch: String = ""
    
    fileprivate let broadcastPosrService = BroascastPostsService()
    
    var selectedPost = Post()
    var postIndex : Int = 0
    var canScrollToTop: Bool = true
    
    lazy var pullRefresh: UIRefreshControl = {
        let r = UIRefreshControl()
        r.addTarget(self, action: #selector(pullRefreshReload), for: .valueChanged)
        return r
    }()
    var broadcasts: [BroadcastCellModel] = []
    
    //Video
    var player = AVPlayer()
    var playerItem: AVPlayerItem?
    var playerTimeObserver: Any?
    var fullSizeVideo: FullSizeController?
    var videoView: VideoView?
    var videoContainer: UIView?
    
    var lastVisibleCell: IndexPath? = IndexPath.init(row: 0, section: 0)
    
    lazy var somethingWrong : EmptyDataView = {
        let sW = EmptyDataView.createForSomethingWrong()
        return sW
    }()
    
//    lazy var noResultsFound : EmptyDataView = {
//        let nrf = EmptyDataView.createForNoResults()
//        return nrf
//    }()
    
    //MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 48.0
        tableInit()
        commonInit()
        getBroadcasts()
        forceIncreaseVolumeInPlayer()
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont.navigationTitleFont]
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
        GA.TrackScreen(name: "Broadcast Search")
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
//        UIApplication.shared.statusBarStyle = .lightContent
        //        UIApplication.shared.isStatusBarHidden = false
        
//        if let nav = self.navigationController?.navigationBar {
//            Helper.setupBlueNavigationBar(navBar: nav)
//        }
        canScrollToTop = true
    }
    
    // Called when the view becomes unavailable
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.shared.statusBarStyle = .default
        
        canScrollToTop = false
        if (fullSizeVideo == nil) {
            resetVideoView()
        }
    }
    
    func resetVideoView(){
        videoView?.reset()
        videoView = nil
    }
    
    // Scrolls to top nicely
    func scrollToTop() {
        self.tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    func tableInit(){
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.addSubview(pullRefresh)
//        leftButton.imageView?.contentMode = .scaleAspectFit
        setupInfiniteScrolling()
    }
    func setupInfiniteScrolling() {
        self.tableView.addInfiniteScroll {[unowned self] (collection) in
            self.getBroadcasts()
        }
        self.tableView.infiniteScrollTriggerOffset = 100
        
        self.tableView.setShouldShowInfiniteScrollHandler {[unowned self] _ in
            return true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
    
    func commonInit()  {
        UISearchBar.appearance().setImage(#imageLiteral(resourceName: "TAB search icon"), for: .search, state: .normal)
        self.navigationItem.title = textToSearch
        self.somethingWrong.delegate = self
//        navigationItem.setLeftBarButton(nil, animated: true)
        navigationItem.setRightBarButton(nil, animated: true)
    }
    
    func pullRefreshReload(sender: UIRefreshControl){
        pagination = Pagination()
        broadcastPosrService.reset()
        getBroadcasts()
        resetVideoView()
    }
    
    func getBroadcasts(){
        if self.broadcasts.count == 0{
            showHud()
        }
        
        self.somethingWrong.hide()
        
        broadcastPosrService.broadcast(text: textToSearch) { (newPosts, error) in
            self.pullRefresh.endRefreshing()
            self.tableView.finishInfiniteScroll()
            self.hideHud()
            self.somethingWrong.hide()
            self.broadcasts += newPosts
            delay(delay: 0, closure: {
                self.tableView.reloadData()
            })
            if let _ = error {
                self.somethingWrong.show(to: self.tableView)
            }
            
//            if self.broadcasts.count == 0 {
//                self.noResultsFound.show(to: self.tableView)
//            }else {
//                self.noResultsFound.hide()
//            }
        }

        
//        BroadcastAPI.getBroadcasts(page: pagination.nextPage, textToSearch: textToSearch) { (broadcasts, pagination, error) in
//            self.pullRefresh.endRefreshing()
//            self.tableView.finishInfiniteScroll()
//            self.hideHud()
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
//                    self.tableView.reloadData()
//                })
//            }
//
//            if let _ = error {
//                self.somethingWrong.show(to: self.tableView)
//            }
//
//            if self.broadcasts.count == 0 {
//                self.noResultsFound.show(to: self.tableView)
//            }else {
//                self.noResultsFound.hide()
//            }
//        }
    }
    func sharePost(post: Post) {
        let alert = UIAlertController(title: "Alert", message: "Are you sure you want to promote this post?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
            self.showHud()
            PostsAPI.share(post: post) { (success, error) in
                self.hideHud()
                
                if success {
                    MBProgressHUD.showWithStatus(view: self.view, text: "Promoted", image: #imageLiteral(resourceName: "SUCCESS"))
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
    
    @IBAction func backFromSearch(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
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
extension BroadcastSearchController {
    static func create() -> BroadcastSearchController {
        return UIStoryboard.broadcast.instantiateViewController(withIdentifier: "BroadcastSearchController") as! BroadcastSearchController
    }
}

extension BroadcastSearchController: URLLabelDelegate {
    func twitterCell(_ cell: TwitterTableCell, didPressUrl url: String) {
        guard let url = URL(string: url) else { return }
        let webNav = WebNavigationController()
        webNav.setup(url: url.absoluteString)
        
        present(webNav, animated: true, completion: nil)
    }
    
    func twitterCell(_ cell: TwitterTableCell, didPressHashtag hashtag: String) {
    }
}

extension BroadcastSearchController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return broadcasts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = broadcasts[safe: indexPath.row] else { return UITableViewCell() }
        switch model {
        case let item where item as? BroadcastPost != nil:
            let delegates: BroadcastCellDelegate = (self as BroadcastControllerDelegate, self as VideoPlayerViewDelegate, self as MentionLabelDelegate, self as URLLabelDelegate)
            let cell = model.tableView(tableView, cellForRowAt: indexPath, with: delegates)
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
//        return 500
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //        for post in (cell as! BroadcastTableCell).broadcastPost.posts {
        //            post.player.pause()
        //        }
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
//
//class CustomWebViewController: SVWebViewController {
//    var nav: UINavigationController?
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        //        nav?.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: " ", style: .plain, target: nil, action: nil)
//        self.nav?.navigationBar.backIndicatorImage = #imageLiteral(resourceName: "back_icon_upd")
//        self.nav?.navigationBar.backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "back_icon_upd")
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//    }
//}

extension BroadcastSearchController : BroadcastControllerDelegate {
    //FIX-IT: Dublicated code from extension BroadcastController : BroadcastControllerDelegate
    func broadcastCell(_ sender: BroadcastTableCell, didPressMoreButtonFor post: Post) {
        //let alertController = UIAlertController(title: "Select action", message: "For post: \(post.title)", preferredStyle: .actionSheet)
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        //let reactionAction = UIAlertAction(title: "Create Reaction", style: .default, handler: nil)
        let reportAction = UIAlertAction(title: "Report", style: .destructive, handler: nil)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(reportAction)
        //alertController.addAction(reactionAction)
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func broadcastCell(sender: BroadcastTableCell, didPressMoreDescriptionButton button: UIButton) {
        let detailsVC = PostDetailController.create()
        let broadcast = broadcasts[sender.index]
        selectedPost = broadcast.posts[broadcast.currentPage!]
        detailsVC.post = selectedPost
        detailsVC.isFromBroadcastVC = true
        self.push(detailsVC)
    }
    
    func broadcastCell(sender: BroadcastTableCell, didPressPromoteButton button: UIButton) {
        let broadcast = broadcasts[sender.index]
        selectedPost = broadcast.posts[broadcast.currentPage!]
        
        self.sharePost(post: self.selectedPost)
    }
    
    func broadcastCell(sender: BroadcastTableCell, didPressMoreButton button: UIButton) {
        let broadcast = broadcasts[sender.index]
        selectedPost = broadcast.posts[broadcast.currentPage!]
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Promote", style: .default, handler: { (action) in
            self.sharePost(post: self.selectedPost)
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

extension BroadcastSearchController : EmptyDataViewDelegate {
    func emptyDataView(sender: EmptyDataView, didPress action: UIButton) {
        self.somethingWrong.hide()
        getBroadcasts()
    }
}

extension BroadcastSearchController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
}

extension BroadcastSearchController: VideoPlayerViewDelegate{
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

extension BroadcastSearchController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes = [NSForegroundColorAttributeName: UIColor.black,
                          NSFontAttributeName: UIFont.helveticaRegualr(15)]
       return NSAttributedString(string: "", attributes: attributes)
    }
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes = [NSForegroundColorAttributeName: UIColor.lightGray,
                          NSFontAttributeName: UIFont.helveticaRegualr(14)]
        return NSAttributedString(string: "", attributes: attributes)
    }
}

extension BroadcastSearchController: MentionLabelDelegate {
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

