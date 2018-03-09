//
//  PublicChatRoomController.swift
//  havr
//
//  Created by CloudStream on 2/18/18.
//  Copyright © 2018 Tenton LLC. All rights reserved.
//

import Foundation
class PublicChatRoomController: UIViewController {
    
    //MARK: - OUTLETS
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tfChatRoomName: UITextField!
    @IBOutlet weak var ivRoomProfile: UIImageView!
    @IBOutlet weak var tfAddress: UITextField!
    
    //MARK: - VARIABLES
    var users: [User] = []
    var imageMedia: Media?
    
    //MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commonInit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.statusBarStyle = .default
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("PublicChatRoomController DidAppear")
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    func commonInit(){
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        
        ivRoomProfile.cornerRadius = 30.0
        ivRoomProfile.masksToBounds = true
    }
    
    func openCamera(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    func openPhotoLibraryButton(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            
            imagePicker.navigationBar.barTintColor = Apperance.appBlueColor
            imagePicker.navigationBar.tintColor = UIColor.white
            imagePicker.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
            
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func onBtnCreate(_ sender: Any) {
        //ChatRoomConversation chatRoomConversation = getOrCreateConversation(for chatRoom: ChatRoom)
//        Conversation
//        let conversationVC = ConversationController.create(conversation: conversation)
//        
//        conversationVC.isFromMessagesVC = true
//        
//        self.push(conversationVC)
//        let user = selectedUsers(users: <#T##[User]#>)
//        
//        if let conversation = ConversationManager.shared.conversation(with: user.id) {
//            self.view.endEditing(true)
//            self.delegate?.searchController(sender: self, didSelect: conversation)
//        } else {
//            ChatManager.shared.getConversation(user: user.id) {[weak self] (conversation, error) in
//                guard let `self` = self else { return }
//                self.view.endEditing(true)
//                self.tableView.deselectRow(at: indexPath, animated: true)
//                
//                if let conversation = conversation {
//                    conversation.user = user
//                    self.delegate?.searchController(sender: self, didSelect: conversation)
//                }
//                
//                if let error = error {
//                    Helper.show(alert: error.message)
//                }
//            }
//        }
    }
    
    @IBAction func onBtnBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onBtnProfileImage(_ sender: Any) {
        let editPicture = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takeApicture = UIAlertAction(title: "Take a Photo", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in self.openCamera(sender) })
        let chooseFromCameraRoll = UIAlertAction(title: String.localized("Choose From Camera Roll"), style: .default, handler: {
            (alert: UIAlertAction!) -> Void in  self.openPhotoLibraryButton(sender) })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in })
        
        editPicture.addAction(takeApicture)
        editPicture.addAction(chooseFromCameraRoll)
        editPicture.addAction(cancelAction)
        editPicture.view.tintColor = Apperance.appBlueColor
        self.present(editPicture, animated: true, completion: nil)
        editPicture.view.tintColor = Apperance.appBlueColor
    }
}

extension PublicChatRoomController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count + 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            return tableView.dequeueReusableCell(withIdentifier: "AddMemberCell", for: indexPath)
        }
        
        let cell:CreateRoomContactCell = tableView.dequeueCreateRoomContactCell(index: indexPath)
        cell.user = users[indexPath.item - 1]
        
        cell.selectionStyle = .none
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 0) // Add Memeber
        {
            let contactSelVC = ContactSelectController.create()
            contactSelVC.selectedUsers = self.users
            contactSelVC.delegate = self
            present(contactSelVC, animated: true, completion: nil)
        }
        else {
            let user = users[indexPath.item - 1]
            print("user \(user.fullName) selected")
        }
        
        
//        if let conversation = ConversationManager.shared.conversation(with: user.id) {
//            self.view.endEditing(true)
//            self.delegate?.searchController(sender: self, didSelect: conversation)
//        } else {
//            ChatManager.shared.getConversation(user: user.id) {[weak self] (conversation, error) in
//                guard let `self` = self else { return }
//                self.view.endEditing(true)
//                self.tableView.deselectRow(at: indexPath, animated: true)
//
//                if let conversation = conversation {
//                    conversation.user = user
//                    self.delegate?.searchController(sender: self, didSelect: conversation)
//                }
//
//                if let error = error {
//                    Helper.show(alert: error.message)
//                }
//            }
//        }
    }
}

extension PublicChatRoomController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.ivRoomProfile.image = image
            self.ivRoomProfile.contentMode = .scaleAspectFill
            let media = Media.create(for: image)
//
            self.imageMedia = media
        }
        
        picker.dismiss(animated: true, completion: {
        })
    }
}

extension PublicChatRoomController {
    static func create() -> PublicChatRoomController {
        return UIStoryboard.messages.instantiateViewController(withIdentifier: "PublicChatRoomController") as! PublicChatRoomController
    }
}

extension PublicChatRoomController: ContactSelectControllerDelegate{
    func selectedUsers(users: [User]) {
        if users.count != 0 {
            self.users.append(contentsOf: users)
            self.tableView.reloadData()
        }
    }
}
