//
//  ExploreConversationController.swift
//  havr
//
//  Created by Ismajl Marevci on 5/3/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import RealmSwift
import UIScrollView_InfiniteScroll
import MBProgressHUD

class ExploreConversationController: UITableViewController {
    
    //MARK: - OUTLETS
    @IBOutlet weak var rightButton: UIButton!
    
    //MARK: - VARIABLES
    var pagination: Pagination = Pagination()
    let user = AccountManager.currentUser
    var isCreationScreen : Bool = false
    fileprivate var chatRoomConversation: ChatRoomConversation!
    
    fileprivate var chatRoom: ChatRoom {
        return chatRoomConversation.chatRoom
    }
    
    fileprivate var posts: [ChatRoomPost] {
        return chatRoomConversation.posts
    }
    
    fileprivate var chatRoomPostModel: ExploreConversationModelView {
        return chatRoomConversation.chatRoomPostModel
    }
    
    //    var headerView: ChatRoomHeaderView = ChatRoomHeaderView()
    let emptyView: EmptyDataView = EmptyDataView.createForChatRoomPosts()
    
    var isAnonymous: Bool {
        get {
            return Constants.isAnonymous
        }
        set {
            Constants.isAnonymous = !isAnonymous
            delay(delay: 0, closure: {
                self.tableView.reloadData()
            })
        }
    }
    lazy var pullRefresh: UIRefreshControl = {
        let r = UIRefreshControl()
        r.addTarget(self, action: #selector(pullRefreshReload), for: .valueChanged)
        return r
    }()
    
    lazy var detailsBarView : DetailsBarView = {
        let d = DetailsBarView.loadViewFromNib()
        d.autoresizingMask = .flexibleHeight
        d.overlayButton.isHidden = false
        d.canSentMessage = true
        d.delegate = self
        return d
    }()
    
    //MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        tableInit()
        commonInit()
        loadResource()
        if posts.count > 0 {
            tableView.tableHeaderView = nil
            tableView.tableHeaderView?.isHidden = true
        }
        setHeader()
        scrollToBottom(animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setHeader() {
        if let image = chatRoom.getImageUrl() {
            //            headerView = ChatRoomHeaderView.createHeader(title: chatRoom.name, url: image)
        }
    }
    
    func tableInit(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerECSenderTextTableCell()
        tableView.registerECReceiverTextTableCell()
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0)
        tableView.registerConversationFooterView()
        tableView.addSubview(pullRefresh)
        let imgV = UIImageView.init(image: #imageLiteral(resourceName: "M Background"))
        imgV.frame = self.view.frame
        //        imgV.transform = CGAffineTransform(scaleX: 1, y: -1)
        tableView.backgroundView = imgV
        
        tableView.setShouldShowInfiniteScrollHandler {[weak self] (table) -> Bool in
            guard let `self` = self else { return false }
            return self.pagination.hasNext
        }
        
        tableView.addInfiniteScroll {[weak self] (table) in
            guard let `self` = self else { return }
            self.loadResource()
        }
    }
    func pullRefreshReload(sender: UIRefreshControl){
        pagination = Pagination()
        delay(delay: 0, closure: {
            self.tableView.reloadData()
        })
        self.pullRefresh.endRefreshing()
    }
    
    func commonInit(){
        let name : String = chatRoom.name
        let address : String = chatRoom.address
        self.navigationItem.setNavBarWithBlack(title: name, subTitle: address)
        
        if let image = chatRoom.getImageUrl() {
            rightButton.kf.setImage(with: image, for: UIControlState())
            rightButton.imageView?.cornerRadius = 6.5
            rightButton.contentMode = .scaleAspectFill
            
            rightButton.frame = CGRect(x: 0, y: 0, width: 37, height: 37)
            rightButton.widthAnchor.constraint(equalToConstant: 37).isActive = true
            rightButton.heightAnchor.constraint(equalToConstant: 37).isActive = true
        }
    }
    
    func scrollToBottom(animated: Bool = true) {
        DispatchQueue.main.async {
            guard let row = self.chatRoomPostModel.lastRowInLastSection() else {
                return
            }
            let section = self.chatRoomPostModel.numberOfSections() > 0 ? self.chatRoomPostModel.numberOfSections() - 1 : 0
            let index = IndexPath(row: row, section: section)
            self.tableView.scrollToRow(at: index, at: .bottom, animated: animated)
        }
    }
    
    func anonymous() {
        if isAnonymous {
            if let image = user?.getUrl() {
                rightButton.kf.setImage(with: image, for: UIControlState())
                rightButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
                rightButton.imageView?.cornerRadius = (rightButton.imageView?.frame.size.width)! / 2
                rightButton.imageView?.borderWidth = 1.0
                rightButton.imageView?.borderColor = UIColor.white
                rightButton.contentMode = .scaleAspectFill
            }
        }else {
            rightButton.contentMode = .scaleAspectFill
            rightButton.imageView?.cornerRadius = (rightButton.imageView?.frame.size.width)! / 2
            rightButton.imageView?.borderWidth = 1.0
            rightButton.imageView?.borderColor = Apperance.appBlueColor
            rightButton.setImage(#imageLiteral(resourceName: "E avatar icon"), for: UIControlState())
        }
    }
    
    fileprivate func loadResource() {
        if self.posts.count == 0{
            showHud()
        }
        ChatRoomPostAPI.getPosts(by: chatRoom.id, page: pagination.nextPage) {[unowned self]  (posts, pagination, error) in
            self.tableView.finishInfiniteScroll()
            self.hideHud()
            
            
            if let posts = posts, let pagination = pagination{
                self.pagination = pagination
                self.chatRoomConversation.addPosts(posts: posts)
                self.tableView.tableHeaderView = nil
                delay(delay: 0, closure: {
                    self.tableView.reloadData()
                })
                //                    if pagination.currentPage == 1{
                self.scrollToBottom(animated: false)
                //                    }
            }
            
            if let error = error {
                Helper.show(alert: error.message)
                self.emptyView.hide()
            }
        }
    }
    //    fileprivate func scrollToBottom(animated: Bool = false, forceScroll: Bool = true) {
    //        if posts.count > 0 {
    //            DispatchQueue.main.async(execute: {
    //                self.tableView.reloadData()
    //                let indexPath = IndexPath(row: self.posts.count - 1, section: 0)
    //                self.tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: animated)
    //            })
    //        }
    //    }
    
    func addComment(openCamera: Bool = false){
        let addcomment = AddChatRoomPostController.create()
        addcomment.delegate = self
        addcomment.isAnonymous = isAnonymous
        addcomment.chatroom = chatRoom
        addcomment.openCamera = openCamera
        let addNAV = UINavigationController(rootViewController: addcomment)
        self.showModal(addNAV)
    }
    func delete(at index: IndexPath) {
        let post = chatRoomPostModel.post(at: index)
        if post.isMine() == false { return }
        
        ChatRoomPostAPI.deletePost(with: post.id, by: chatRoom.id) { (success, error) in
            if success {
                self.chatRoomConversation.delete(post: post)
                self.chatRoomConversation.reloadPosts()
                delay(delay: 0, closure: {
                    self.tableView.reloadData()
                })
                
            }else if let error = error {
                Helper.show(alert: error.message)
            }
        }
    }
    
    func showReportOptions(for post: ChatRoomPost){
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
    
    func reportPost(post: ChatRoomPost, message: ReportPostMessage){
        self.showHud()
        ChatRoomPostAPI.report(post: post, reportMessage: message, reportPlace: ReportPostPlace.inChatrooms) { (success, error) in
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
    @IBAction func rightButtonPressed(_ sender: UIButton) {
        
    }
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        self.tabBarController?.tabBar.isHidden = false
        self.hideModal()
    }
}
//MARK: - EXTENSIONS
extension ExploreConversationController {
    static func create(chatRoom: ChatRoom) -> ExploreConversationController {
        let controller = UIStoryboard.explore.instantiateViewController(withIdentifier: "ExploreConversationController") as! ExploreConversationController
        
        let chatRoomConversation = ChatRoomConversationsManager.shared.getOrCreateConversation(for: chatRoom)
        controller.chatRoomConversation = chatRoomConversation
        
        return controller
    }
    override var canBecomeFirstResponder: Bool {
        return true
    }
    override var inputAccessoryView: UIView? {
        return detailsBarView
    }
}

extension ExploreConversationController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return chatRoomPostModel.numberOfSections()
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatRoomPostModel.numberOfItems(in: section)
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = chatRoomPostModel.cellForRow(tableView, at: indexPath, isComment: false)
        
        cell.titleLabel.numberOfLines = 15
        cell.selectionStyle = .none
        cell.delegate = self
        
        return cell
    }
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let post = chatRoomPostModel.post(at: indexPath)
        
        if post.isMine() {
            return true
        }
        
        return false
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { (action, indexPath) in
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            
            alert.addAction(UIAlertAction(title: "Delete comment", style: .default, handler: { (handler) in
                tableView.setEditing(false, animated: true)
                self.delete(at: indexPath)
            }))
            
            alert.view.tintColor = Apperance.appBlueColor
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.view.tintColor = Apperance.appBlueColor
            self.navigationController?.present(alert, animated: true, completion: nil)
        }
        
        delete.backgroundColor = Apperance.appBlueColor
        return [delete]
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueConversationFooterView()
        
        cell.dateLabel.text = chatRoomPostModel.titleAtSection(section: section)
        //        cell.transform = CGAffineTransform(scaleX: 1, y: -1)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 24
    }
}

extension ExploreConversationController: DetailsBarViewDelegate{
    func detailsBarView(sender: DetailsBarView, didSelectUser user: User, at index: IndexPath) {
        //
    }
    
    func detailsBarView(sender: DetailsBarView, didPressSend button: UIButton, with message: String){
        addComment()
    }
    func detailsBarView(sender: DetailsBarView, didRecordAt url: URL) {
        
    }
    func detailsBarView(sender: DetailsBarView, didPressMedia button: UIButton){
        addComment(openCamera: true)
    }
    func detailsBarView(sender: DetailsBarView, didChange height: CGFloat){
        addComment()
    }
    func detailsBarView(sender: DetailsBarView, didBecomeFirstResponder textView: UITextView){
        addComment()
    }
    func detailsBarView(sender: DetailsBarView, didOverlay button: UIButton) {
        addComment()
    }
    func detailsBarView(sender: DetailsBarView, didChangeText text: String) {
    }
}

extension ExploreConversationController: AddChatRoomPostControllerDelegate {
    func addChatRoomPostController(sender: AddChatRoomPostController, didCreate post: ChatRoomPost) {
        self.chatRoomConversation.addPosts(posts: posts)
        
        self.chatRoomConversation.posts.append(post)
        //        self.chatRoomConversation.reloadPosts()
        //        let indexPath = IndexPath(row: 0, section: chatRoomPostModel.numberOfSections() - 1)
        //        self.tableView.insertRows(at: [indexPath], with: .top)
        
        let index = self.chatRoomPostModel.insertNewPost(post: post)
        // Insert or delete rows
        if index.isNewSection {
            delay(delay: 0, closure: {
                self.tableView.reloadData()
            })
        } else {
            let sec = chatRoomPostModel.numberOfSections() > 0 ? chatRoomPostModel.numberOfSections() - 1 : 0
            let ind = IndexPath.init(row: index.index.row, section: sec)
            tableView.insertRows(at: [ind], with: .bottom)
        }
        self.emptyView.hide()
        
        scrollToBottom()
        delay(delay: 0.15) {
            sender.hideModal()
        }
    }
}

extension ExploreConversationController: ExploreConversationTableCellDelgate {
    func exploreConversationCell(sender: ExploreConversationTableCell, didPressMoreButton button: UIButton) {
        let post = sender.post!
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Report", style: .default, handler: { (action) in
            self.showReportOptions(for: post)
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
    func exploreConversationCell(sender: ExploreConversationTableCell, didPressLikeButton button: UIButton) {
        ChatRoomPostAPI.likeUnlikePost(with: chatRoom.id, post: sender.post!, liked: !sender.post!.isLiked) { (success, liked, error) in
            
            if success{
                sender.post!.isLiked = liked
                
                if sender.post!.isLiked{
                    sender.post!.likesCount += 1
                }else{
                    sender.post!.likesCount -= 1
                }
                delay(delay: 0, closure: {
                    self.tableView.reloadData()
                })
            }else{
                
            }
        }
    }
    func exploreConversationCell(sender: ExploreConversationTableCell, post: ChatRoomPost, didPressCommentsLabel label: UILabel) {
        let responsesVC = CommentsExploreController.create(chatRoomPost: post, chatRoom: self.chatRoom)
        self.push(responsesVC)
    }
    
    func exploreConversationCell(sender: ExploreConversationTableCell, post: ChatRoomPost, didPressTitleLabel label: UILabel) {
        let details = ExploreChatroomPostDetailController.create(post: post, chatRoom: chatRoom)
        self.push(details)
    }
    func exploreConversationCell(sender: ExploreConversationTableCell, post: ChatRoomPost, didPressDescriptionLabel label: UILabel) {
        let details = ExploreChatroomPostDetailController.create(post: post, chatRoom: chatRoom)
        self.push(details)
    }
    
    func exploreConversationCell(sender: ExploreConversationTableCell, didPressContentImage image: UIImage) {
        let preview = PreviewImageController.create(image: image)
        self.showModal(preview)
    }
}
