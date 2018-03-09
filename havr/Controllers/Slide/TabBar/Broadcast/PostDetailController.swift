//
//  PostDetailController.swift
//  havr
//
//  Created by Ismajl Marevci on 4/22/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import UIScrollView_InfiniteScroll
import AVFoundation
import MBProgressHUD
import ExpandableLabel

protocol PostDetailsControllerDelegate: class {
    func didDelete(post: Post)
}

protocol PostDetailsCommentDelegate: class {
    func didDelete(post: Post, commentId: Int)
}

class PostDetailController: UITableViewController, UIGestureRecognizerDelegate, ExpandableLabelDelegate {
    func willExpandLabel(_ label: ExpandableLabel) {
        tableView.beginUpdates()
        //tableView.layoutIfNeeded()
    }
    
    func didExpandLabel(_ label: ExpandableLabel) {
        tableView.endUpdates()
        headerHeight()
        PostDetailController.attemptRotationToDeviceOrientation()
        updateViewConstraints()
    }
    
    func willCollapseLabel(_ label: ExpandableLabel) {
        tableView.beginUpdates()
    }
    
    func didCollapseLabel(_ label: ExpandableLabel) {
        tableView.endUpdates()
        headerHeight()
        PostDetailController.attemptRotationToDeviceOrientation()
        updateViewConstraints()
    }
    
    @IBOutlet weak var postCountLabel: UILabel!
    @IBOutlet weak var likesCountLabel: UILabel!
    
    //MARK: - OUTLETS
    @IBOutlet weak var promoteLabel: UILabel!
    @IBOutlet weak var promoteView: UIView!
    //    @IBOutlet weak var userView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var reactionButton: UIButton!
    @IBOutlet weak var postTimeLabel: UILabel!
    //    @IBOutlet weak var postsupportsButton: UIButton!
    @IBOutlet weak var isLikeButton: UIButton!
    @IBOutlet weak var postTitleLabel: ExpandableLabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    //    @IBOutlet weak var postCommentsLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var promoteButton: UIButton!
    @IBOutlet weak var leftBarButton: UIBarButtonItem!
    
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var moreButton: UIBarButtonItem!
    
    @IBOutlet weak var loadMoreView: UIView!
    @IBOutlet weak var loadMoreIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadMoreButton: UIButton!
    @IBOutlet weak var loadMoreHeightConstraint: NSLayoutConstraint!
    
    //Video
    @IBOutlet weak var videoContainer: UIView!
    var videoView: VideoView!
    var isFromBroadcastVC : Bool = false
    var isFromMessageVC : Bool = false
    var isFromSaved = false
    
    //MARK: - VARIABLES
    lazy var detailsBarView : DetailsBarView = {
        let d = DetailsBarView.loadViewFromNib()
        d.autoresizingMask = .flexibleHeight
        d.overlayButton.isHidden = true
        d.canSentMessage = true
        d.delegate = self
        d.attachButton.isHidden = true
        d.attachButtonWidthConstraint.constant = 10
        d.attachButton.layoutIfNeeded()
        return d
    }()
    
    var comments: [Comment] = []
    var post: Post!
    var pagination = Pagination()
    
    lazy var pullRefresh: UIRefreshControl = {
        let r = UIRefreshControl()
        r.addTarget(self, action: #selector(pullRefreshReload), for: .valueChanged)
        return r
    }()
    
    weak var delegate: PostDetailsControllerDelegate!
    weak var commentDelegate: PostDetailsCommentDelegate?
    
    var didLayoutSubviews = false
    fileprivate var headerViewHeight: CGFloat = 0
    //Video
    //    var player = AVPlayer()
    //    var playerItem: AVPlayerItem?
    var fullSizeVideo: FullSizeController?
    
    //MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        tableInit()
        commonInit()
        setValues()
        getComments()
        setupTap()
        forceIncreaseVolumeInPlayer()
        setupTap()
        Helper.setupTransparentNavigationBar(nav: navigationController!)
        
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = false
        }
        self.navigationItem.setNavBarWithBlack(title: "Detail", subTitle: "No location")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        if isFromSaved {
            promoteButton.setImage( #imageLiteral(resourceName: "save_selected")  , for: .normal)
        }else {
            promoteButton.setImage(UserStore.shared.isSavedPost(id: post.id) ? #imageLiteral(resourceName: "save_selected") : #imageLiteral(resourceName: "save") , for: .normal)
        }
        GA.TrackScreen(name: "Post Details")
        headerHeight()
        if isFromBroadcastVC {
            //            UIApplication.shared.statusBarStyle = .lightContent
        }else {
            UIApplication.shared.statusBarStyle = .default
        }//        detailsBarView.messageTextView.becomeFirstResponder()
        //        scrollToBottom(animated: false, forceScroll: true)
        PostDetailController.attemptRotationToDeviceOrientation()
        updateViewConstraints()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !didLayoutSubviews {
            //            delay(delay: 0, closure: { 
            //                self.headerHeight()
            //            })
            didLayoutSubviews = true
            createVideoView()
        }
    }
    
    deinit {
        guard videoView != nil else { return }
        videoView.destroy()
    }
    
    func createVideoView(){
        videoView = VideoView.instanceFromNib()
        videoContainer.addSubview(videoView)
        videoView.videoPlayerDelegate = self
        videoView.post = post
        videoView.addEdgeConstraints()
    }
    
    func tableInit(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerCommentTableCell()
        self.tableView.addSubview(pullRefresh)
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0)
        //tableView.contentInset = UIEdgeInsetsMake(0, tableView.contentInset.left, 10, tableView.contentInset.right)
    }
    
    func commonInit() {
        self.moreButton.tintColor = Apperance.textGrayColor
    }
    
    func pullRefreshReload(sender: UIRefreshControl){
        pagination = Pagination()
        getComments()
        videoView.destroy()
        videoView.setControls(hidden: false)
    }
    @IBAction func loadMoreCommentsPressed(_ sender: Any) {
        loadMoreIndicator.startAnimating()
        loadMoreButton.setTitle("Loading more comments...", for: .normal)
        loadMoreButton.isEnabled = false
        getComments()
    }
    
    //MARK: - FUNCTIONS
    func setValues(){
        videoContainer.isHidden = !post.isVideo()
        
        likesCountLabel.text = "\(post.likesCount)"
        postCountLabel.text = "\(post.postComment)"
        likesCountLabel.textColor = post.isLiked ? UIColor(red255: 253, green255: 92, blue255: 99) : UIColor(red255: 151, green255: 153, blue255: 166)
        
        
        if let image = post.owner.getUrl() {
            userImageView.kf.setImage(with: image, placeholder: Constants.defaultImageUser)
        }else {
            userImageView.image = Constants.defaultImageUser
        }
        //        if post.isVideo() {
        //            reactionButton.isHidden = post.isReaction()
        //        }else{
        //            reactionButton.isHidden = true
        //        }
        postImageView.kf.setImage(with: post.getImageUrl())
        userNameLabel.text = post.owner.username
        //self.postTitleLabel.setLessLinkWith(lessLink: "Close", attributes: [.foregroundColor:UIColor.red], position: NSTextAlignment.right)
        self.postTitleLabel.delegate = self
        self.postTitleLabel.setLessLinkWith(lessLink: "see less", attributes: [NSFontAttributeName: UIFont.sfProTextItalicFont(14)], position: NSTextAlignment.right)
       
        self.postTitleLabel.shouldCollapse = true
        self.postTitleLabel.numberOfLines = 2
        self.postTitleLabel.collapsed = true
        self.postTitleLabel.textReplacementType = .character
        
        
    
        let mutableString = NSMutableAttributedString(string: "see more", attributes: [NSFontAttributeName: UIFont.sfProTextItalicFont(14)])
        
//        mutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.red, range: NSRange(location:0,length:4))
        self.postTitleLabel.collapsedAttributedLink = mutableString
        if post.title != "" {
            postTitleLabel.text = post.title
            postTitleLabel.textColor = UIColor.black.withAlphaComponent(1)
        }else {
            postTitleLabel.text = "No caption"
            postTitleLabel.textColor = UIColor.black.withAlphaComponent(0.4)
        }
        if post.isPromoted() {
            promoteView.isHidden = true
        }else {
            promoteView.isHidden = false
            promoteLabel.text = "@\(post.author.username)"
        }
        postTimeLabel.text = post.createdDate.timeAgoSinceDate()
        setLikeCountAndImage()
        setCommentsCount()
    }
    
    func setLikeCountAndImage(){
        likesCountLabel.text = "\(post.likesCount)"
        likesCountLabel.textColor = post.isLiked ? UIColor(red255: 253, green255: 92, blue255: 99) : UIColor(red255: 151, green255: 153, blue255: 166)
        //        postsupportsButton.setTitle("\(post.likesCount.abbreviated)", for: UIControlState())
        isLikeButton.setImage(post.isLiked ? #imageLiteral(resourceName: "likeFill") : #imageLiteral(resourceName: "like"), for: UIControlState())
        //        postsupportsButton.setTitleColor(post.isLiked ? Apperance.redColor : Apperance.F8F8F8Color, for: UIControlState())
    }
    
    func setupTap() {
        let tapUser = UITapGestureRecognizer(target: self, action: #selector(userTapFunction))
        tapUser.delegate = self as UIGestureRecognizerDelegate
        tapUser.numberOfTapsRequired = 1
        self.userImageView.isUserInteractionEnabled = true
        self.userImageView.addGestureRecognizer(tapUser)
        
        let tapUser1 = UITapGestureRecognizer(target: self, action: #selector(userTapFunction))
        tapUser1.delegate = self as UIGestureRecognizerDelegate
        tapUser1.numberOfTapsRequired = 1
        self.userNameLabel.isUserInteractionEnabled = true
        self.userNameLabel.addGestureRecognizer(tapUser1)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(mediaPressed))
        tap.delegate = self
        tap.numberOfTapsRequired = 1
        postImageView?.isUserInteractionEnabled = true
        postImageView?.addGestureRecognizer(tap)
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(profileTaped))
        tap2.delegate = self
        tap2.numberOfTapsRequired = 1
        self.promoteLabel.isUserInteractionEnabled = true
        self.promoteLabel.addGestureRecognizer(tap2)
    }
    func profileTaped() {
        if post.author.id != 0 {
            let user = post.author
            if user?.id == AccountManager.currentUser!.id {
                let profile = ProfileController.create()
                profile.openedFromPush = true
                self.push(profile)
            }else{
                let userProfile = UserProfileController.create(for: user!)
                userProfile.isFromBroadcastVC = true
                self.push(userProfile)
            }
        }
    }
    
    override var shouldAutorotate: Bool{
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return .portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
        return .portrait
    }
    
    func userTapFunction(){
        let user = post.owner
        if user?.id == AccountManager.currentUser!.id {
            let profile = ProfileController.create()
            profile.openedFromPush = true
            self.push(profile)
        }else{
            let userProfile = UserProfileController.create(for: user!)
            userProfile.isFromBroadcastVC = true
            self.push(userProfile)
        }
    }
    
    func mediaPressed() {
        if let image = postImageView.image {
            let preview = PreviewImageController.create(image: image)
            self.showModal(preview)
        }
    }
    
    func sharePost(post: Post) {
        let store = UserStore.shared
        PostsAPI.savePost(with: String(post.id), completion: { (isChanged, error) in
            guard let error = error else {
                DispatchQueue.main.async {
                    self.promoteButton.setImage(isChanged ? #imageLiteral(resourceName: "save_selected") : #imageLiteral(resourceName: "save") , for: .normal)
                    if isChanged {
                        store.savePost(with: post.id)
                    } else {
                        store.removeSavedPost(id: post.id)
                    }
                }
                return
            }
            print(error)
        })
//        let alert = UIAlertController(title: "Are you sure you want to promote this post?", message: nil, preferredStyle: .alert)
//
//        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
//            let m = MBProgressHUD.showAdded(to: self.view, animated: true)
//            m.contentColor = Apperance.appBlueColor
//            PostsAPI.share(post: post) { (success, error) in
//                if success {
//                    m.hide(animated: true)
//                    MBProgressHUD.showWithStatus(view: self.view, text: "Promoted", image: #imageLiteral(resourceName: "SUCCESS"))
//                }else {
//                    if let error = error  {
//                        MBProgressHUD.showWithStatus(view: self.view, text: error.message, image: #imageLiteral(resourceName: "ERROR"))
//                    }
//                }
//            }
//        }))
//
//        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: {(action) in }))
//
//        if let wPPC = alert.popoverPresentationController {
//            let barButtonItem = self.navigationItem.rightBarButtonItem!
//            let buttonItemView = barButtonItem.value(forKey: "view")
//            wPPC.sourceView = buttonItemView as? UIView
//            wPPC.sourceRect = (buttonItemView as AnyObject).bounds
//        }
//        alert.view.tintColor = Apperance.appBlueColor
//        self.present(alert, animated: true, completion: nil)
//        alert.view.tintColor = Apperance.appBlueColor
    }
    
    func setCommentsCount(){
        if self.pagination.totalItems == 1 {
            postCountLabel.text = "1"
        }else{
            postCountLabel.text = "\(self.pagination.totalItems.abbreviated)"
        }
    }
    
    func getComments(){
        PostsAPI.getComments(for: post, page: pagination.currentPage + 1) { (comments, pagination, error) in
            self.pullRefresh.endRefreshing()
            self.loadMoreIndicator.stopAnimating()
            self.loadMoreButton.isEnabled = true
            if self.loadMoreButton.titleLabel!.text != "View more comments"{
                self.loadMoreButton.setTitle("View more comments", for: .normal)
            }
            
            if self.pagination.currentPage == 0{
                self.comments.removeAll()
            }
            
            if let comments = comments, let pagination = pagination{
                self.pagination = pagination
                let array = comments.reversed() + self.comments
                self.comments = array
                //                self.scrollToBottom(animated: true)
            }
            
            if self.pagination.hasNext{
                self.loadMoreView.isHidden = false
                self.loadMoreHeightConstraint.constant = 35
                self.headerView.frame.size.height = self.headerViewHeight + 35
            }else{
                self.loadMoreView.isHidden = true
                self.loadMoreHeightConstraint.constant = 0
                self.headerView.frame.size.height = self.headerViewHeight
            }
            self.tableView.reloadData()
            self.loadMoreView.layoutIfNeeded()
            self.tableView.layoutIfNeeded()
            self.setCommentsCount()
        }
    }
    func deletePost(){
        let alert = UIAlertController(title: "Alert", message: "Are you sure you want to delete the post?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
            let m = MBProgressHUD.showAdded(to: self.view, animated: true)
            m.contentColor = Apperance.appBlueColor
            PostsAPI.delete(post: self.post) { (success, error) in
                if success {
                    m.hide(animated: true)
                    MBProgressHUD.showWithStatus(view: self.view, text: "Deleted", image: #imageLiteral(resourceName: "SUCCESS"))
                    self.delegate.didDelete(post: self.post)
                    self.pop()
                }else {
                    m.hide(animated: true)
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
    
    fileprivate func scrollToBottom(animated: Bool = false, forceScroll: Bool = true) {
        if comments.count > 0 {
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
                let indexPath = IndexPath(row: self.comments.count - 1, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: animated)
            })
        }
    }
    
    func headerHeight() {
        guard let labelText = postTitleLabel.text else { return }
        let labelHeight = estimatedHeightOfLabel(text: labelText)
        let screenWidth = UIScreen.main.bounds.width
        let staticHeight = (CGFloat(90) + labelHeight)
        
        if post.isVideo() {
            imageHeightConstraint.constant = CGFloat(postImageView.frame.width)
        }else{
            let ratio: CGFloat = postImageView.frame.width / screenWidth
            imageHeightConstraint.constant = screenWidth //CGFloat(post.media.height) * ratio
        }
        
        headerViewHeight = (staticHeight + imageHeightConstraint.constant)
        
        // let maxHeight = CGFloat(view.frame.height + 44)
        let minHeight = CGFloat(80)
        if headerViewHeight < minHeight {
            headerViewHeight = minHeight
        }
        headerView.frame.size.height = headerViewHeight
        postImageView.layoutIfNeeded()
    }
    
    func estimatedHeightOfLabel(text: String) -> CGFloat {
        let size = CGSize(width: view.frame.width - 68, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let attributes = [NSFontAttributeName: UIFont.robotoRegularFont(12.0)]
        let rectangleHeight = String(text).boundingRect(with: size, options: options, attributes: attributes, context: nil).height
        
        return rectangleHeight
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
    
    //MARK: - ACTIONS
    
    @IBAction func leftBarButtonPressed(_ sender: UIBarButtonItem) {
        guard isFromSaved else {
            self.pop()
            return
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func promoteButtonPressed(_ sender: UIButton) {
        self.sharePost(post: self.post)
        
    }
    
    @IBAction func reactionButtonPressed(_ sender: UIButton) {
        let videoReactionVC = VideoReactionController.create(for: post)
        videoReactionVC.post = post
        let navigation = UINavigationController(rootViewController: videoReactionVC)
        navigation.isNavigationBarHidden = true
        self.showModal(navigation)
    }
    @IBAction func moreButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        if !post.isMine() {

//            if post.isVideo() {
//                alert.addAction(UIAlertAction(title: "Make Reaction", style: .default, handler: { (action) in
//
//                    let videoReactionVC = VideoReactionController.create(for: self.post)
//
//                    let nav = UINavigationController(rootViewController: videoReactionVC)
//
//                    self.showModal(nav)
//
//                }))
//            }

            alert.addAction(UIAlertAction(title: "Report", style: .destructive, handler:  {
                (alert: UIAlertAction!) -> Void in
                self.showReportOptions(for: self.post)
            } ))
        }

        if post.isMine() {
            alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: { (action) in
                let editVC = EditPostController.create()
                editVC.post = self.post
                editVC.delegate = self
                self.showModal(editVC)
            }))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                self.deletePost()
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
//
    }
    
    @IBAction func supportersButtonPressed(_ sender: UIButton) {
        let connectionsVC = ConnectionsController.create()
        connectionsVC.navTitle = "Supporters"
        self.push(connectionsVC)
    }
    
    @IBAction func isLikeButtonPressed(_ sender: UIButton) {
        sender.bubble()
        PostsAPI.likeUnlike(the: post) { (success, isLiked, error) in
            if success{
                self.post.isLiked = isLiked!
                if self.post.isLiked{
                    self.post.likesCount += 1
                }else{
                    self.post.likesCount -= 1
                }
                self.setLikeCountAndImage()
            }else{
                
            }
        }
    }
    
    // Video
    // MARK: Set Volume On, even in mute mode
    func forceIncreaseVolumeInPlayer(){
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: [])
    }
}

//MARK: - EXTENSIONS
extension PostDetailController {
    static func create() -> PostDetailController {
        return UIStoryboard.broadcast.instantiateViewController(withIdentifier: "PostDetailController") as! PostDetailController
    }
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var inputAccessoryView: UIView? {
        return detailsBarView
    }
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        detailsBarView.messageTextView.resignFirstResponder()
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
}

extension PostDetailController  {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCommentTableCell(index: indexPath)
        let comment = comments[indexPath.row]
        cell.comment = comment
        cell.commentLabel.delegate = self
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (comments[indexPath.row].user.id == AccountManager.currentUser?.id) {
            return true
        }
        else {
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if (comments[indexPath.row].user.id == AccountManager.currentUser?.id) {
            let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
                PostsAPI.deleteComment(postId: self.comments[indexPath.row].postId, commentID: self.comments[indexPath.row].id, completion: { (bSuccess) in
                    
                    self.pagination.totalItems -= 1
                    self.comments.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                    self.setCommentsCount()
                    
                    if let delegate = self.commentDelegate {
                        delegate.didDelete(post: self.post, commentId: self.comments[indexPath.row].id)
                    }
                })
                
                
                print("Delete Pressed")
            }
            
            return [delete]
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 15
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //        let comment = comments[indexPath.row]
        //        let user = comment.user
        //        
        //        if user!.id == AccountManager.currentUser!.id {
        //            let profile = ProfileController.create()
        //            profile.openedFromPush = true
        //            profile.isFromMessagesVC = isFromMessageVC
        //            self.push(profile)
        //        }else{
        //            let userProfile = UserProfileController.create(for: user!)
        //            userProfile.isFromBroadcastVC = isFromBroadcastVC
        //            self.push(userProfile)
        //        }
    }
}

extension PostDetailController: VideoPlayerViewDelegate{
    func videoControl(sender: VideoView, didTapAt view: UIView){
        console("didTapAt")
    }
    
    func videoControl(sender: VideoView, didPressFullScreen button: UIButton){
        console("didPressFullScreen")
        
        delay(delay: 0) {
            if let _ = self.fullSizeVideo{
                self.videoContainer?.addSubview(sender)
                sender.addEdgeConstraints()
                
                self.fullSizeVideo?.hideModal()
                self.fullSizeVideo = nil
                
                if sender.playPauseButton.isSelected{
                    sender.playPauseButtonPressed(sender.playPauseButton)
                }
            }else{
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

extension PostDetailController: DetailsBarViewDelegate{
    func detailsBarView(sender: DetailsBarView, didSelectUser user: User, at index: IndexPath) {
        //
    }
    
    func detailsBarView(sender: DetailsBarView, didPressSend button: UIButton, with message: String){
        if message.isEmpty{ return }
        PostsAPI.createComment(with: message, media: nil, to: self.post) { (comment, error) in
            if let comment = comment{
                self.comments.append(comment)
                self.pagination.totalItems += 1
                self.setCommentsCount()
                self.tableView.insertRows(at: [IndexPath.init(row: self.comments.count - 1, section: 0)], with: .fade)
                self.scrollToBottom(animated: true)
            }
        }
    }
    
    func detailsBarView(sender: DetailsBarView, didRecordAt url: URL) {
        print(url)
        
        if let media = Media.create(audioUrl: url) {
            media.upload(completion: { (media, success, error) in
                if success {
                    media.uploadStatus = .uploaded
                    OfflineFileManager.remove(with: url) //remove temporary file
                    
                    PostsAPI.createComment(with: "", media: media, to: self.post, completion: { (comment, error) in
                        if let comment = comment {
                            self.comments.append(comment)
                            self.pagination.totalItems += 1
                            self.setCommentsCount()
                            self.tableView.insertRows(at: [IndexPath.init(row: self.comments.count - 1, section: 0)], with: .fade)
                            self.scrollToBottom(animated: true)
                        }
                    })
                } else {
                    media.uploadStatus = .failed
                }
            })
        }
    }
    
    func detailsBarView(sender: DetailsBarView, didPressMedia button: UIButton){
        scrollToBottom()
    }
    
    func detailsBarView(sender: DetailsBarView, didChange height: CGFloat){
        
    }
    
    func detailsBarView(sender: DetailsBarView, didBecomeFirstResponder textView: UITextView){
        scrollToBottom(animated: true, forceScroll: false)
    }
    func detailsBarView(sender: DetailsBarView, didOverlay button: UIButton) {
        //
    }
    func detailsBarView(sender: DetailsBarView, didChangeText text: String) {
    }
}

extension PostDetailController: EditPostControllerDelegate {
    func didUpdate(post: Post) {
        
        if post.title != "" {
            postTitleLabel.text = post.title
            postTitleLabel.textColor = Apperance.textGrayColor.withAlphaComponent(1)
            //postTitleLabel.collapsedAttributedLink = NSAttributedString(string: "Read More")
        }else {
            postTitleLabel.text = "No caption"
            postTitleLabel.textColor = Apperance.textGrayColor.withAlphaComponent(0.4)
//            postTitleLabel.collapsedAttributedLink = NSAttributedString(string: "Read More")
        }
        
        tableView.reloadData()
    }
}

extension PostDetailController: MentionLabelDelegate {
    func didSelect(_ text: String, type: ActiveType) {
        if type == .mention {
            
            if text == AccountManager.currentUser!.username {
                let profile = ProfileController.create()
                profile.openedFromPush = true
                profile.isFromMessagesVC = isFromMessageVC
                self.push(profile)
                return
            }
            self.showHud()
            UsersAPI.getUser(username: text, completion: { (user, error) in
                self.hideHud()
                if let user = user {
                    let userProfile = UserProfileController.create(for: user)
                    userProfile.isFromBroadcastVC = self.isFromBroadcastVC
                    self.push(userProfile)
                }
            })
        }
    }
}


