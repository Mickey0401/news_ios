//
//  ResponsesExploreController.swift
//  havr
//
//  Created by Ismajl Marevci on 5/16/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import RealmSwift
import UIScrollView_InfiniteScroll
import MBProgressHUD

class CommentsExploreController: UITableViewController {

    //MARK: - OUTLETS
    @IBOutlet weak var rightButton: UIButton!
    
    //MARK: - VARIABLES
    lazy var detailsBarView : DetailsBarView = {
        let d = DetailsBarView.loadViewFromNib()
        d.autoresizingMask = .flexibleHeight
        d.overlayButton.isHidden = true
        d.canSentMessage = true
        return d
    }()
    
    fileprivate var chatRoomPost: ChatRoomPostComments!
    fileprivate var chatRoom: ChatRoom!
    var media: Media? = nil

    fileprivate var post: ChatRoomPost {
        return chatRoomPost.post
    }
    fileprivate var comments: [ChatRoomPost] {
        return chatRoomPost.comments
    }
    let user = AccountManager.currentUser
    var pagination: Pagination = Pagination()
    var newPost : ChatRoomPost?
    
    fileprivate var chatRoomPostModel: ExploreConversationModelView {
        return chatRoomPost.chatRoomPostModel
    }
    
    var isAnonymous: Bool = false {
        didSet {
            Constants.isAnonymous = isAnonymous
            anonymous()
        }
    }
    
    let emptyView: EmptyDataView = EmptyDataView.createForChatRoomComments()

    //MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
        tableInit()
        loadResource()
        detailsBarView.delegate = self
        isAnonymous = Constants.isAnonymous
//        anonymous()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameWillChange), name: .UIKeyboardWillChangeFrame, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        UIApplication.shared.isStatusBarHidden = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func commonInit(){
        rightButton.imageView?.cornerRadius = 6.5
        rightButton.contentMode = .scaleAspectFill
            
        rightButton.frame = CGRect(x: 0, y: 0, width: 37, height: 37)
        rightButton.widthAnchor.constraint(equalToConstant: 37).isActive = true
        rightButton.heightAnchor.constraint(equalToConstant: 37).isActive = true
    }
    
    func tableInit(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerECSenderTextTableCell()
        tableView.registerECReceiverTextTableCell()
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0)
        
        tableView.registerECSenderCommentTableCell()
        tableView.registerECReceiverCommentTableCell()
        
//        tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        tableView.registerConversationFooterView()

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
    
    fileprivate func loadResource() {
        if self.comments.count == 0{
            showHud()
        }
        ChatRoomPostAPI.getComments(with: chatRoom!.id, by: post.id, page: pagination.nextPage) {[unowned self] (comments, pagination, error) in
            
            self.tableView.finishInfiniteScroll()
            self.hideHud()
            
            if self.pagination.currentPage == 0{
//                self.comments.removeAll()
            }
                if let comments = comments, let pagination = pagination {
                    self.pagination = pagination
                    self.chatRoomPost.addComments(comments: comments)
                    self.chatRoomPost.reloadPosts()
                    if pagination.currentPage == 1{
                        self.scrollToBottom(animated: false)
                    }
                    delay(delay: 0.0, closure: { 
                        self.tableView.reloadData()

                    })
                }
            if let error = error {
                self.emptyView.hide()
                Helper.show(alert: error.message)
            }
        }
    }
    
    fileprivate func scrollToBottom(animated: Bool = false, forceScroll: Bool = true) {
        if comments.count > 0 {
            DispatchQueue.main.async {
                guard let row = self.chatRoomPostModel.lastRowInLastSection() else {
                    return
                }
                let index = IndexPath(row: row, section: self.chatRoomPostModel.numberOfSections() - 1)
//                self.tableView.scrollRectToVisible(self.tableView.rectForRow(at: index), animated: animated)
                self.tableView.scrollToRow(at: index, at: .bottom, animated: animated)
            }
        }
    }
    
    func keyboardFrameWillChange(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            self.tableView.contentInset = UIEdgeInsetsMake(keyboardHeight, self.tableView.contentInset.left,self.tableView.contentInset.bottom, self.tableView.contentInset.right)
            self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(keyboardHeight, self.tableView.scrollIndicatorInsets.left, self.tableView.scrollIndicatorInsets.left, self.tableView.scrollIndicatorInsets.right)
        }
    }
    
    
    func createComment(sender: UIButton) {
        delay(delay: 0) { 
            self.detailsBarView.messageTextView.resignFirstResponder()
            self.showHud()
        }
        
        let p = ChatRoomPost()
        p.text = detailsBarView.messageTextView.text ?? " "
        p.media = media
        p.hasMedia = media != nil
        self.newPost = p
        
        if newPost!.hasMedia {
            if newPost?.media?.uploadStatus == .uploaded {
                addComment(sender: sender)
            } else {
                newPost?.media?.upload(completion: { (media, success, error) in
                    if success {
                        self.addComment(sender: sender)
                    }
                    if let error = error {
                        self.hideHud()
                        MBProgressHUD.showWithStatus(view: self.view, text: error , image: #imageLiteral(resourceName: "ERROR"))
                    }
                })
            }
        }else {
            addComment(sender: sender)
        }
    }
    
    func addComment(sender: UIButton) {
        
        guard let post = newPost else {
            return
        }
        
        post.isAnon = !self.isAnonymous
        ChatRoomPostAPI.createComment(for: post, by: chatRoom.id, postId: self.post.id) { (comment, error) in
            self.hideHud()
            
            if let comment = comment {
                    self.emptyView.hide()
                    self.chatRoomPost.addComments(comments: [comment])
                    self.chatRoomPost.reloadPosts()
                    self.scrollToBottom()
                    self.detailsBarView.messageTextView.text = nil
                    self.detailsBarView.attachButton.setImage(#imageLiteral(resourceName: "M attach icon"), for: .normal)
                    self.newPost = nil
                    self.media = nil
                    UIView.animate(withDuration: 0.2, animations: {
                        self.detailsBarView.layoutIfNeeded()
                    })
                delay(delay: 0.0, closure: { 
                    self.tableView.reloadData()
                })
            }
            if let error = error {
                Helper.show(alert: error.message)
            }
        }
    }
    
    func anonymous() {
        if isAnonymous {
            if let image = user?.getUrl() {
                rightButton.kf.setImage(with: image, for: UIControlState())
                rightButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
                rightButton.imageView?.cornerRadius = (rightButton.imageView?.frame.width)! / 2
                rightButton.imageView?.backgroundColor = Apperance.appBlueColor
                let username : String = "as \(String(describing: user!.fullName))"
                self.navigationItem.setNavBarWithBlack(title: "Comment", subTitle: username)
                
                rightButton.imageView?.borderWidth = 1
                rightButton.imageView?.borderColor = UIColor.white
            }
        }else {
            rightButton.imageView?.backgroundColor = UIColor.white
            let username : String = "as Anonymous"
            self.navigationItem.setNavBarWithBlack(title: "Comments", subTitle: username)
            rightButton.imageView?.cornerRadius = (rightButton.imageView?.frame.width)! / 2
            rightButton.setImage(#imageLiteral(resourceName: "E avatar icon"), for: UIControlState())
            rightButton.imageView?.borderWidth = 1.0
            rightButton.imageView?.borderColor = Apperance.appBlueColor
        }
    }
    
    func delete(at index: IndexPath) {
        let comment = chatRoomPostModel.post(at: index)
        
        ChatRoomPostAPI.deleteComment(for: comment.id, with: post.id, by: chatRoom.id) { (success, error) in
            if success {
                
                self.chatRoomPost.delete(comment: comment)
                self.chatRoomPost.reloadPosts()
                delay(delay: 0.0, closure: { 
                    self.tableView.reloadData()
                })
            }else if let error = error {
                Helper.show(alert: error.message)
            }
        }
    }
    
    func showCanvasController() {
        let kanvasNavigation = KanvasNavigationController()
        kanvasNavigation.cameraDelegate = self
        self.showModal(kanvasNavigation)
    }

    @IBAction func rightButtonPressed(_ sender: UIButton) {
        isAnonymous = !isAnonymous
    }
}
//MARK: - EXTENSIONS
extension CommentsExploreController {
    static func create(chatRoomPost: ChatRoomPost, chatRoom: ChatRoom) -> CommentsExploreController {
        let controller = UIStoryboard.explore.instantiateViewController(withIdentifier: "CommentsExploreController") as! CommentsExploreController
        let chatRoomPost = ChatRoomPostsManager.shared.getOrCreatePost(for: chatRoomPost)
        controller.chatRoomPost = chatRoomPost
        controller.chatRoom = chatRoom
        return controller
    }
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var inputAccessoryView: UIView? {
        return detailsBarView
    }
}

extension CommentsExploreController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return chatRoomPostModel.numberOfSections()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatRoomPostModel.numberOfItems(in: section)
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = chatRoomPostModel.cellForRow(tableView, at: indexPath, isComment: true)
        
//        cell.transform = CGAffineTransform(scaleX: 1, y: -1)
        cell.selectionStyle = .none
        cell.commentsView?.isHidden = true
        cell.delegate = self
        if let button = cell.moreButton {
            cell.selectionStyle = .none
            button.isHidden = true
            
        }
        
        return cell
    }
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        let comment = chatRoomPostModel.post(at: indexPath)
    
        if comment.isMine() {
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
    
    
    func showAlert() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Take a new one", style: .default, handler: { (handler) in
            self.showCanvasController()
        }))
        alert.addAction(UIAlertAction(title: "Remove media", style: .destructive, handler: { (handler) in
            //remove media
            self.detailsBarView.attachButton.setImage(#imageLiteral(resourceName: "M attach icon"), for: .normal)
            self.media = nil
            self.validateInputs()
            UIView.animate(withDuration: 0.2, animations: {
                self.detailsBarView.layoutIfNeeded()
            })
        }))
        
        alert.view.tintColor = Apperance.appBlueColor
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.view.tintColor = Apperance.appBlueColor
        self.navigationController?.present(alert, animated: true, completion: nil)
    }
    
    func validateInputs() {
        if !detailsBarView.messageTextView.text.isEmpty || media != nil {
            detailsBarView.sendButton.isEnabled = true
        }else {
            detailsBarView.sendButton.isEnabled = false
        }
    }
}

extension CommentsExploreController: DetailsBarViewDelegate{
    func detailsBarView(sender: DetailsBarView, didSelectUser user: User, at index: IndexPath) {
        //
    }

    
    func detailsBarView(sender: DetailsBarView, didPressSend button: UIButton, with message: String){
        createComment(sender: button)
    }
    func detailsBarView(sender: DetailsBarView, didPressMedia button: UIButton){
        
        if media != nil {
            showAlert()
        }else {
            showCanvasController()
        }
    }
    func detailsBarView(sender: DetailsBarView, didRecordAt url: URL) {
        
    }
    func detailsBarView(sender: DetailsBarView, didChange height: CGFloat){
    }
    func detailsBarView(sender: DetailsBarView, didBecomeFirstResponder textView: UITextView){
        scrollToBottom(animated: true)
    }
    func detailsBarView(sender: DetailsBarView, didOverlay button: UIButton) {
    }
    func detailsBarView(sender: DetailsBarView, didChangeText text: String) {
        validateInputs()
    }
}

extension CommentsExploreController: ExploreConversationTableCellDelgate {
    func exploreConversationCell(sender: ExploreConversationTableCell, didPressMoreButton button: UIButton) {
        //
    }
    func exploreConversationCell(sender: ExploreConversationTableCell, didPressLikeButton button: UIButton) {
        ChatRoomPostAPI.likeUnlikeComment(with: chatRoom.id, post: post, comment: sender.post!, liked: !sender.post!.isLiked) { (success, liked, error) in
            
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
        //
    }
    
    func exploreConversationCell(sender: ExploreConversationTableCell, post: ChatRoomPost, didPressTitleLabel label: UILabel) {
        
    }
    func exploreConversationCell(sender: ExploreConversationTableCell, post: ChatRoomPost, didPressDescriptionLabel label: UILabel) {
        
    }

    func exploreConversationCell(sender: ExploreConversationTableCell, didPressContentImage image: UIImage) {
        let preview = PreviewImageController.create(image: image)
        self.showModal(preview)
    }
}

//MARK: - Kanvas Camera NAvigationController Delegate
extension CommentsExploreController: KanvasCameraControllerDelegate {
    func camera(sender: KanvasNavigationController, didFinishPicking media: Media) {
        print("finish picking media: \(media)")
        AppDelegate.disableScreenOrientation()
        self.media = media
        
        self.post.hasMedia = true
        validateInputs()
        sender.hideModal()
        detailsBarView.attachButton.kf.setImage(with: media.getImageUrl(), for: .normal)
    }
}

extension CommentsExploreController : UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        validateInputs()
    }
}
