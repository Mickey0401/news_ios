//
//  ConversationController.swift
//  havr
//
//  Created by Ismajl Marevci on 4/28/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import SwiftyJSON
import Kingfisher
import Photos
import UIScrollView_InfiniteScroll


class ConversationController: UITableViewController, UIGestureRecognizerDelegate {
    
    
    lazy var messageBarView : MessageBarView = {
        let d = MessageBarView.loadViewFromNib()
        d.autoresizingMask = .flexibleHeight
        
        // d.delegate = self
        return d
    }()

    var isFromBroadcastVC : Bool = false
    var isFromMessagesVC : Bool = false
    weak var photoLibraryPermission : AllowPermissionView? = {
        let pL = AllowPermissionView.createForPhotoLibrary()
        return pL
    }()
    
    var titleView: TitleView?
    
    lazy var rightButton: UIBarButtonItem = {
        let button = RoundedButton(type: .custom)
        button.setImage(Constants.defaultImageUser, for: UIControlState.normal)
        button.addTarget(self, action: #selector(rightBarButtonClicked), for: UIControlEvents.touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.cornerRadius = 15.0
        button.imageView?.clipsToBounds = true
        
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.widthAnchor.constraint(equalToConstant: 30).isActive = true
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        let barButton = UIBarButtonItem(customView: button)
        
        return barButton
    }()
    
    var socket: SocketManager {
        return SocketManager.shared
    }
    var selectedIndex: Int = 0
    var conversationMessages: ConversationMessages!
    
    var userStatus: UserOnlineStatusTypes?
    
    var conversation: Conversation! {
        get {
            return conversationMessages.conversation
        } set {
            conversationMessages.conversation = newValue
        }
    }
    
    var pagination: Pagination! {
        get {
            return conversationMessages.pagination
        } set {
            conversationMessages.pagination = newValue
        }
    }
    
    var messages: [Message] {
        get {
            return conversationMessages.messages
        } set {
            conversationMessages.messages = newValue
        }
    }
    
    var conversationMessage: MessagesModelView {
        get {
            return conversationMessages.conversationMessage
        }
        set {
            conversationMessages.conversationMessage = newValue
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableInit()
        commonInit()
        loadProfile()
        setupSocket()
        loadOfflineMessages()
        loadMessages()
        
        photoLibraryPermission?.permissionButtonPressed = permissionButtonPressed
        photoLibraryPermission?.laterButtonPressed = laterButtonPressed
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged),name: NSNotification.Name(rawValue: "ReachabilityChangedNotification"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameWillChange), name: .UIKeyboardWillChangeFrame, object: nil)
        
        tableView.reloadData()
        tableView.tableHeaderView?.isHidden = true
        scrollToBottom(animated: false)
        
        ChatManager.shared.conversationController = self
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        UIApplication.shared.statusBarView?.backgroundColor = Apperance.navTintColor// UIColor.green
        self.navigationController?.navigationBar.tintColor = Apperance.navTintColor//UIColor.green
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func dismissKeyboard () {
        self.messageBarView.messageTextView.resignFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GA.TrackScreen(name: "Conversation")

        messageBarView.messageTextView.becomeFirstResponder()
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let titleView = TitleView.loadViewFromNib()
        titleView.frame = CGRect(x: 0, y: 0, width: 150, height: 44)
        self.navigationItem.titleView = titleView
        titleView.titleForType(title: conversation.user.fullName, subtitle: "@\(conversation.user.username)")
        self.titleView = titleView
        
        //костыль
        titleView.transform = CGAffineTransform(translationX: 0, y: 20)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        Sound.stopAll()
    }
    
    
    func commonInit(){
        forceIncreaseVolumeInPlayer()
        //assign button to navigationbar
        self.navigationItem.rightBarButtonItem = rightButton
        messageBarView.delegate = self

        if isFromBroadcastVC {
            //self.navigationItem.setNavBarWithWhite(title: conversation.user.fullName, subTitle: "@\(conversation.user.username)")
        }else {
            //self.navigationItem.setNavBarWithBlack(title: conversation.user.fullName, subTitle: "@\(conversation.user.username)")
        }
    }
    func forceIncreaseVolumeInPlayer(){
        //try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: [])
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            //print("AVAudioSession Category Playback OK")
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                //print("AVAudioSession is Active")
            } catch _ as NSError {
                //print(error.localizedDescription)
            }
        } catch _ as NSError {
            //print(error.localizedDescription)
        }
    }
    
    func tableInit(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerSenderTextTableCell()
        tableView.registerSenderImageTableCell()
        tableView.registerReceiverImageTableCell()
        tableView.registerReceiverTextTableCell()
        
        tableView.registerSenderImageWithoutStatusTableCell()
        tableView.registerSenderTextWithoutStatusTableCell()
        
        tableView.registerSenderVoiceTableCell()
        tableView.registerReceiverVoiceTableCell()
        
        tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0)
        tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        tableView.registerConversationFooterView()
                
        let imgV = UIImageView.init(image: #imageLiteral(resourceName: "M Background"))
        imgV.frame = self.view.frame
        imgV.transform = CGAffineTransform(scaleX: 1, y: -1)
        tableView.backgroundView = imgV
        
        tableView.setShouldShowInfiniteScrollHandler {[weak self] (table) -> Bool in
            guard let `self` = self else { return false }
            
            return self.pagination.hasNext
        }
        
        tableView.addInfiniteScroll {[weak self] (table) in
            guard let `self` = self else { return }
            
            self.loadMoreMessages()
        }
    }
    
    
    func loadOfflineMessages() {
        self.mergeMessages(messages: self.conversationMessages.messages)
    }
    
    func loadMessages() {
        ConversationAPI.getMessages(conversation: conversation.id, limit: 10, lastMessage: Date(), page: 1) {[weak self] (messages, pagination, error) in
            guard let `self` = self else { return }
            
            self.tableView.finishInfiniteScroll()
            
            if let messages = messages, let pagination = pagination {
                
                let shouldScroll = self.messages.count == 0
                
                self.mergeMessages(messages: messages)
                self.tableView.reloadData()
                
                if shouldScroll {
                    self.scrollToBottom(animated: false)
                }
                
                self.conversationMessages.pagination = pagination
                self.markConversationAsSeen()
            }
            
            if let error = error {
                print("Error: \(error.message)")
            }
        }
    }
    
    func loadMoreMessages() {
        guard let lastMessage = self.conversationMessage.lastMessage else {
            tableView.finishInfiniteScroll()
            return
        }
        
        ConversationAPI.getMessages(conversation: conversation.id, lastMessage: lastMessage.createdAt, page: self.pagination.nextPage) {[weak self] (messages, pagination, error) in
            guard let `self` = self else { return }
            
            self.tableView.finishInfiniteScroll()
            if let messages = messages {
                self.mergeMessages(messages: messages)
                self.tableView.reloadData()
                self.pagination = pagination
            }
        }
    }
    
    func mergeMessages(messages: [Message]) {        
        self.conversationMessage.mergeMessages(messages: messages)
    }
    
    func markConversationAsSeen() {
        
        ConversationAPI.markAsSeen(conversation: conversation.id, completion: {[weak self] (success, error) in
            if success {
                delay(delay: 0, closure: { 
                    self?.conversation.unSeenCount = 0
                    ChatManager.shared.chatsController?.tableView?.reloadData()
                    ChatManager.shared.updateBadge()
                })
            }
        })
        
        delay(delay: 1) { 
            SocketManager.shared.sendSeenEvent()
        }
    }
    
    func loadProfile() {
        
        let button = self.rightButton.customView as? UIButton
        
        if let userImage = self.conversation.getUserImageUrl() {
            button?.kf.setImage(with: userImage, for: UIControlState())
            
        }else {
            button?.setImage(Constants.defaultImageUser, for: UIControlState.normal)
        }
    }
    
    func keyboardFrameWillChange(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            self.tableView.contentInset = UIEdgeInsetsMake(keyboardHeight, 0, 0, 0)
            self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(keyboardHeight, 0, 0, 0)
            self.tableView.contentOffset = CGPoint(x: 0, y: -keyboardHeight)
        }
    }
    
    func rightBarButtonClicked(button: UIBarButtonItem){
        let userVC = UserProfileController.create(for: conversation.user)
        userVC.isFromBroadcastVC = isFromBroadcastVC
        userVC.isFromMessagesVC = isFromMessagesVC
        self.push(userVC)
    }
    
    func setupSocket() {
        SocketManager.shared.connect(conversation: conversation)
    }
    
    func scrollToBottom(animated: Bool = true) {
        DispatchQueue.main.async {
            if self.conversationMessage.numberOfSections() > 0 {
                let lastindexPath = IndexPath(row: 0, section: 0)
                self.tableView.scrollToRow(at: lastindexPath, at: .top, animated: animated)
            }
        }
    }
    
    func reachabilityChanged(notification: Notification) {
        
    }
    
    func sendNewMessage(message: Message) {

        self.conversationMessages.mergeMessages(messages: [message])
        let index = self.conversationMessage.insertNewMessage(message: message)
        if index.isNewSection {
            tableView.reloadData()
        } else {
            tableView.insertRows(at: [index.index], with: .top)
        }
        
        ChatManager.shared.send(message: message, conversation: self.conversation) { [ weak self ] (message, success, error) in
            
            guard let `self` = self,
                  let index = self.conversationMessage.indexOf(message: message) else {
                return
            }
            
            DispatchQueue.main.async {
                if let cell = self.tableView.cellForRow(at: index) as? ConversationTableCell {
                    self.conversationMessage.update(message: message, at: index)
                    cell.message = message
                    return
                }
                
                if let cell = self.tableView.cellForRow(at: index) as? VoiceTableCell {
                    self.conversationMessage.update(message: message, at: index)
                    cell.message = message
                }
            }
        }
    }

    func checkPhotoLibraryPermission() {
        
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            self.photoLibraryPermission?.hide()
            self.openPhotoLibraryButton(self)
            self.messageBarView.isHidden = false
            
        //handle authorized status
        case .denied, .restricted :
            self.photoLibraryPermission?.show(to: self.navigationController!.view)
            self.messageBarView.isHidden = true
            
        //handle denied status
        case .notDetermined:
            // ask for permissions
            PHPhotoLibrary.requestAuthorization() { status in
                switch status {
                case .authorized:
                    self.photoLibraryPermission?.hide()
                    self.openPhotoLibraryButton(self)
                    self.messageBarView.isHidden = false
                    
                // as above
                case .denied, .restricted:
                    // as above
                    self.photoLibraryPermission?.show(to: self.navigationController!.view)
                    self.messageBarView.isHidden = true
                case .notDetermined:
                    return
                    // won't happen but still
                }
            }
        }
        
    }
    
    func laterButtonPressed() {
        self.photoLibraryPermission?.hide()
        self.messageBarView.isHidden = false
    }
    
    func permissionButtonPressed() {
        UIApplication.shared.openURL(NSURL(string:UIApplicationOpenSettingsURLString)! as URL)
    }
    
    func didReceiveMessage(message: Message) {
        if message.conversationId == self.conversation.id {
            
            if let index = self.conversationMessage.indexOf(message: message) {
                self.conversationMessage.update(message: message, at: index)
                
                if let cell = tableView.cellForRow(at: index) as? ConversationTableCell {
                    cell.message = message
                }
                
                if let cell = tableView.cellForRow(at: index) as? VoiceTableCell {
                    cell.message = message  
                }
            } else {
                _ = self.conversationMessage.insertNewMessage(message: message)
                self.tableView.reloadData()
            }
            
            self.conversationMessages.mergeMessages(messages: [message])
        }
        
        if !message.isMine && self.view.window != nil {
            markConversationAsSeen()
        }
        
        if !message.isMine {
            self.conversationMessages.markSeenAllMessages()
            self.tableView.reloadData()
        }
    }
    
    func didChangeSocketConnectionStatus(connected: Bool) {
        messageBarView.canSentMessage = connected
    }
    
    func didReceiveTyping(conversation: Conversation, isTyping: Bool) {
        
        if self.conversation.id != conversation.id { return }
        
        if isTyping {
            if titleView?.type != .typing {
                setTypingTitle()
            }
        } else {
            setNeutral(status: userStatus)
        }
    }
    
    func didReceiveStatus(status: UserOnlineStatusTypes, conversation: Conversation) {
        if conversation.id != self.conversation.id { return }
        userStatus = status
        setNeutral(status: status)
    }
    
    func didReceiveRecodingStatus(conversation: Conversation, isRecording: Bool) {
        if isRecording {
            if titleView?.type != .recording {
                setRecording()
            }
        } else {
            setNeutral(status: self.userStatus)
        }
    }
    
    func didSeenAllMessages(conversation: Conversation) {
        let value = self.conversationMessages.markSeenAllMessages()
        if value {
            self.tableView.reloadData()
        }
    }
    
    fileprivate func setTypingTitle() {
        titleView?.type = .typing
        titleView?.titleForType(title: conversation.user.fullName, subtitle: nil)
    }
    
    fileprivate func setRecording() {
        titleView?.type = .recording
        titleView?.titleForType(title: conversation.user.fullName, subtitle: nil)
    }
    
    fileprivate func setNeutral(status: UserOnlineStatusTypes? = nil) {
        titleView?.type = .neutral
        titleView?.titleForType(title: conversation.user.fullName, subtitle: status?.description ?? "@\(conversation.user.username)")
    }
      
    deinit {
        NotificationCenter.default.removeObserver(self)
        socket.close()

        console("Deinit ConversationController")
    }
    @IBAction func leftBarButtonPressed(_ sender: UIBarButtonItem) {
        self.pop()
    }
}

//MARK: - EXTENSIONS
extension ConversationController {
    static func create(conversation: Conversation) -> ConversationController {
        let controller = UIStoryboard.messages.instantiateViewController(withIdentifier: "ConversationController") as! ConversationController
        
        let conversationsMessages = ConversationManager.shared.getOrCreate(with: conversation)
        
        controller.conversationMessages = conversationsMessages
        
        return controller
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var inputAccessoryView: UIView? {
        return messageBarView
    }
    
}
extension ConversationController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return conversationMessage.numberOfSections()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversationMessage.numberOfItems(in: section)
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = conversationMessage.cellForRow(tableView, at: indexPath)
        
        if let cell = cell as? ConversationTableCell {
            cell.delegate = self
        }
        
        if let cell = cell as? VoiceTableCell {
            cell.delegate = self
        }
        
        cell.transform = CGAffineTransform(scaleX: 1, y: -1)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? VoiceTableCell {
            cell.stopAudio()
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 35
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return conversationMessage.heightForRow(at: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let cell = tableView.dequeueConversationFooterView()

        cell.dateLabel.text = conversationMessage.titleAtSection(section: section)
        cell.transform = CGAffineTransform(scaleX: 1, y: -1)
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 24
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == tableView {
            let maxOffset = CGPoint(x: 0, y: -20)
            print(scrollView.contentOffset)
            if scrollView.contentOffset.y > maxOffset.y {
                scrollView.setContentOffset(maxOffset, animated: true)
            }
        }
    }
}
//MARK: - Conversation Table Cell Delegate
extension ConversationController: ConversationTableCellDelegate {
    func conversationTableCell(sender: ConversationTableCell, didSelectAt image: UIImage) {
        let preview = PreviewImageController.create(image: image)
        self.showModal(preview)
    }
    func conversationTableCell(sender: ConversationTableCell, didPressRetry button: UIButton) {
        if let indexPath = tableView.indexPath(for: sender) {
            
            let message = self.conversationMessage.message(at: indexPath)
            
            message.messageStatus = .sending
            
            ChatManager.shared.send(message: message, conversation: self.conversation) {[weak self] (message, success, error) in
                guard let `self` = self else { return }
                
                DispatchQueue.main.async {
                    if let index = self.conversationMessage.indexOf(message: message) {
                        self.conversationMessage.update(message: message, at: indexPath)
                        self.tableView.reloadRows(at: [index], with: .none)
                    }
                    
                }
            }
            
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
}

//MARK: Voice Table Cell Delegate
extension ConversationController: VoiceTableCellDelegate {
    func voiceTableCell(sender: VoiceTableCell, didPressPlay button: UIButton, with media: Media) {
        //
    }
    func voiceTableCell(sender: VoiceTableCell, didPressRetry button: UIButton) {
        if let indexPath = tableView.indexPath(for: sender) {
            
            let message = self.conversationMessage.message(at: indexPath)
            
            message.messageStatus = .sending
            
            
            ChatManager.shared.send(message: message, conversation: self.conversation) {[weak self] (message, success, error) in
                guard let `self` = self else { return }
                
                DispatchQueue.main.async {
                    if let index = self.conversationMessage.indexOf(message: message) {
                        self.conversationMessage.update(message: message, at: indexPath)
                        self.tableView.reloadRows(at: [index], with: .none)
                    }
                    
                }
            }
            
            tableView.reloadRows(at: [indexPath], with: .none)
        }

    }
}

//MARK: Details Bar View Delegate
extension ConversationController: MessageBarViewDelegate {
    func messageBarView(sender: MessageBarView, didPressSend button: UIButton, with message: String) {
        let m = Message.create(content: message, conversation: self.conversation.id)
        self.sendNewMessage(message: m)
    }
    func messageBarView(sender: MessageBarView, didPressMedia button: UIButton) {
        sender.messageTextView.resignFirstResponder()
        
        let editPicture = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takeApicture = UIAlertAction(title: "Take a Photo", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in self.openCamera(sender) })
        let chooseFromCameraRoll = UIAlertAction(title: String.localized("Choose From Camera Roll"), style: .default, handler: {
            (alert: UIAlertAction!) -> Void in  self.checkPhotoLibraryPermission() })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in })
        
        editPicture.addAction(takeApicture)
        editPicture.addAction(chooseFromCameraRoll)
        editPicture.addAction(cancelAction)
        
        editPicture.view.tintColor = Apperance.appBlueColor
        self.present(editPicture, animated: true, completion: nil)
        editPicture.view.tintColor = Apperance.appBlueColor
    }
    func messageBarView(sender: MessageBarView, didChange height: CGFloat) {
        
    }
    func messageBarView(sender: MessageBarView, didBecomeFirstResponder textView: UITextView) {
//        self.scrollToBottom(animated: true)
    }
    func messageBarView(sender: MessageBarView, didChangeText text: String) {
        if !text.isEmpty {
            TypingsManager.shared.sendTypper()
        }
    }
    
    func messageBarView(sender: MessageBarView, didRecordAt url: URL) {
        print(url)
        
        if let media = Media.create(audioUrl: url) {
            OfflineFileManager.remove(with: url) //remove temporary file
            
            let message = Message.create(audioMedia: media, conversation: self.conversation.id)
            self.sendNewMessage(message: message)
        }
    }
}

//MARK: - Image Picker Delegates
extension ConversationController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func openCamera(_ sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = false
            DispatchQueue.main.async {
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
    }
    func openPhotoLibraryButton(_ sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            
            if isFromBroadcastVC {
                imagePicker.navigationBar.barTintColor = Apperance.appBlueColor
                imagePicker.navigationBar.tintColor = UIColor.white
                imagePicker.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
            }
            
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.allowsEditing = false
            DispatchQueue.main.async {
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            print("Image selected.")
            picker.dismiss(animated: true, completion: {
                
                let resizeImage = image.resizeMessageImage()
                
                let message = Message.create(image: resizeImage, conversation: self.conversation.id)
                
                self.sendNewMessage(message: message)
            })
        }
    }

}
