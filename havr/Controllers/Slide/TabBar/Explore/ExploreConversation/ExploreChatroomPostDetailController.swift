//
//  ExploreChatroomPostDetailController.swift
//  havr
//
//  Created by Ismajl Marevci on 7/29/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import MBProgressHUD

class ExploreChatroomPostDetailController: UITableViewController {
    
    //MARK: - OUTLETS
    @IBOutlet weak var rightBarButton: UIButton!
    @IBOutlet weak var leftBarButton: UIBarButtonItem!
    
    //MARK: - VARIABLES
    var post: ChatRoomPost!

    fileprivate var chatRoomConversation: ChatRoomConversation!

    fileprivate var chatRoom: ChatRoom {
        return chatRoomConversation.chatRoom
    }
    
    //MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()

        tableInit()
        commonInit()
    }
    
    func tableInit(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerECSenderTextTableCell()
        tableView.registerECReceiverTextTableCell()
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0)
        tableView.registerConversationFooterView()
        let imgV = UIImageView.init(image: #imageLiteral(resourceName: "M Background"))
        imgV.frame = self.view.frame
        tableView.backgroundView = imgV
    }
    func commonInit(){
        let name : String = chatRoom.name
        let address : String = chatRoom.address
        self.navigationItem.setNavBarWithBlack(title: name, subTitle: address)
        
        if let image = chatRoom.getImageUrl() {
            rightBarButton.kf.setImage(with: image, for: UIControlState())
            rightBarButton.imageView?.cornerRadius = 6.5
            rightBarButton.contentMode = .scaleAspectFill
            
            rightBarButton.frame = CGRect(x: 0, y: 0, width: 37, height: 37)
            rightBarButton.widthAnchor.constraint(equalToConstant: 37).isActive = true
            rightBarButton.heightAnchor.constraint(equalToConstant: 37).isActive = true
        }
    }
    func delete(at index: IndexPath) {
        let id = post.id
        
        ChatRoomPostAPI.deletePost(with: id, by: chatRoom.id) { (success, error) in
            if success {
                //delegate of delete
            }else if let error = error {
                Helper.show(alert: error.message)
            }
        }
    }
    
    func showReportOptions(for post: ChatRoomPost){
        var reportMessage: ReportPostMessage = .inappropriate
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        
        alert.addAction(UIAlertAction(title: ReportPostMessage.accountHacked.description, style: .default, handler: {(action) in
            
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
    @IBAction func leftBarButtonPressed(_ sender: UIBarButtonItem) {
        self.pop()
    }
    
}
//MARK: - EXTENSIONS
extension ExploreChatroomPostDetailController {
    static func create(post: ChatRoomPost, chatRoom: ChatRoom) -> ExploreChatroomPostDetailController {
        let controller = UIStoryboard.explore.instantiateViewController(withIdentifier: "ExploreChatroomPostDetailController") as! ExploreChatroomPostDetailController
        
        let chatRoomConversation = ChatRoomConversationsManager.shared.getOrCreateConversation(for: chatRoom)
        controller.chatRoomConversation = chatRoomConversation
        controller.post = post
        
        return controller
    }
}
extension ExploreChatroomPostDetailController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueExploreConversationTableCell(identifier: post.getCellIdentifier(), indexPath: indexPath)
        cell.selectionStyle = .none
        cell.delegate = self
        cell.post = post
        cell.titleLabel.numberOfLines = 0
        return cell
    }
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ExploreChatroomPostDetailController: ExploreConversationTableCellDelgate {
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
    
    func exploreConversationCell(sender: ExploreConversationTableCell, post: ChatRoomPost, didPressDescriptionLabel label: UILabel) {
        //
    }
    func exploreConversationCell(sender: ExploreConversationTableCell, post: ChatRoomPost, didPressTitleLabel label: UILabel) {
        //
    }
    
    func exploreConversationCell(sender: ExploreConversationTableCell, didPressContentImage image: UIImage) {
        let preview = PreviewImageController.create(image: image)
        self.showModal(preview)
    }
}
