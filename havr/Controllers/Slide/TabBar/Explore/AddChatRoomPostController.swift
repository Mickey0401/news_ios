//
//  AddNewCommentController.swift
//  havr
//
//  Created by Ismajl Marevci on 5/20/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import MBProgressHUD

protocol AddChatRoomPostControllerDelegate: class {
    func addChatRoomPostController(sender: AddChatRoomPostController, didCreate post: ChatRoomPost)
}

class AddChatRoomPostController: UIViewController {
    
    //MARK: - OUTLETS
    @IBOutlet weak var attachmentButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var leftBarButton: UIBarButtonItem!
    
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var titleTextField: UITextField!
    
    //MARK: - VARIABLEs
    var isAnonymous: Bool = false {
        didSet {
            Constants.isAnonymous = isAnonymous
            anonymous()
        }
    }
    let user = AccountManager.currentUser
    var chatroom: ChatRoom?
    var media: Media? = nil
    var openCamera: Bool = false
    weak var delegate: AddChatRoomPostControllerDelegate?
    
    //MARK: - VARIABLES
    lazy var sendButtonView : SendButtonView = {
        let s = SendButtonView.loadViewFromNib()
        s.delegate = self
        s.autoresizingMask = .flexibleHeight
        return s
    }()
    
    //MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        anonymous()
        titleTextField.becomeFirstResponder()
        
        isAnonymous = Constants.isAnonymous
        if openCamera {
            showCanvasController()
        }
        
        sendButtonView.sendButton.isEnabled = false
        commentTextView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.isStatusBarHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        titleTextField.becomeFirstResponder()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    func anonymous() {
        if isAnonymous {
            if let image = user?.getUrl() {
                rightButton.kf.setImage(with: image, for: UIControlState())
                rightButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
                rightButton.imageView?.cornerRadius = (rightButton.imageView?.frame.size.width)! / 2
                rightButton.imageView?.backgroundColor = Apperance.appBlueColor
                let username : String = "as \(String(describing: user!.fullName))"
                self.navigationItem.setNavBarWithBlack(title: "Post", subTitle: username)
                
                rightButton.imageView?.borderWidth = 1
                rightButton.imageView?.borderColor = UIColor.white
                rightButton.contentMode = .scaleAspectFill
            }
        }else {
            
            rightButton.contentMode = .scaleAspectFill
            rightButton.imageView?.cornerRadius = (rightButton.imageView?.frame.size.width)! / 2
            rightButton.imageView?.borderWidth = 1.0
            rightButton.imageView?.borderColor = Apperance.appBlueColor
            rightButton.setImage(#imageLiteral(resourceName: "E avatar icon"), for: UIControlState())
            
            rightButton.imageView?.backgroundColor = UIColor.white
            let username : String = "as Anonymous"
            self.navigationItem.setNavBarWithBlack(title: "Post", subTitle: username)
            rightButton.contentMode = .scaleAspectFill
        }
    }
    
    func createPost(sender: UIButton) {
        showHud()
        view.endEditing(true)
        if self.media != nil {
            uploadMedia(sender: sender)
        }else{
            addPost(sender: sender)
        }
    }
    
    func uploadMedia(sender: UIButton) {
        self.media?.upload(completion: { (media, success, error) in
            if success{
                self.addPost(sender: sender)
            }else{
                self.hideHud()
                //                sender.isEnabled = true
                MBProgressHUD.showWithStatus(view: self.view, text: error ?? "Something went wrong!", image: #imageLiteral(resourceName: "ERROR"))
            }
        })
    }
    
    func addPost(sender: UIButton) {
        
        guard let title = titleTextField.text, let text = commentTextView.text else {
            self.hideHud()
            titleTextField.shake()
            commentTextView.shake()
            return
        }
        
        //        sender.isEnabled = false
        
        let cp = ChatRoomPost()
        cp.title = title
        cp.text = text
        cp.isAnon = !self.isAnonymous
        cp.media = self.media
        
        ChatRoomPostAPI.createPost(post: cp, by: chatroom!.id) { (post, error) in
            self.hideHud()
            sender.isEnabled = true
            
            if let post = post {
                self.delegate?.addChatRoomPostController(sender: self, didCreate: post)
                self.sendButtonView.isHidden = true
                self.commentTextView.resignFirstResponder()
                UIView.animate(withDuration: 0.2, animations: {
                    self.view.layoutIfNeeded()
                }) { (_) in
                    self.hideModal()
                }
            }
            
            if let error = error {
                MBProgressHUD.showWithStatus(view: self.view, text: error.message, image: #imageLiteral(resourceName: "ERROR"))
            }
        }
    }
    
    func showCanvasController() {
        let kanvasNavigation = KanvasNavigationController()
        kanvasNavigation.cameraDelegate = self
        self.showModal(kanvasNavigation)
    }
    
    //MARK: - ACTIONS
    @IBAction func attachmentButtonPressed(_ sender: UIButton) {
        showCanvasController()
    }
    
    @IBAction func rightButtonPressed(_ sender: UIButton) {
        isAnonymous = !isAnonymous
    }
    @IBAction func leftBarButtonPressed(_ sender: UIBarButtonItem) {
        sendButtonView.isHidden = true
        self.commentTextView.resignFirstResponder()
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        }) { (_) in
            self.hideModal()
        }
    }
    @IBAction func textChanged(_ sender: UITextField) {
        
        validateInputs()
    }
    
    
    func validateInputs() {
        
        if titleTextField.text != "" || commentTextView.text != "" || media != nil {
            
            sendButtonView.sendButton.isEnabled = true
            sendButtonView.sendButton.backgroundColor = Apperance.appBlueColor
            sendButtonView.sendButton.setTitleColor(UIColor.white, for: .normal)
            
        } else if (titleTextField.text?.isEmpty)! || commentTextView.text.isEmpty || media == nil {
            
            sendButtonView.sendButton.backgroundColor = UIColor.clear
            sendButtonView.sendButton.isEnabled = false
            sendButtonView.sendButton.setTitleColor(Apperance.appBlueColor, for: .normal)
            
        }
        
    }
}
//MARK: - EXTENSIONS
extension AddChatRoomPostController {
    static func create() -> AddChatRoomPostController {
        return UIStoryboard.explore.instantiateViewController(withIdentifier: "AddChatRoomPostController") as! AddChatRoomPostController
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var inputAccessoryView: UIView? {
        return sendButtonView
    }
}

//MARK: - Kanvas Camera NAvigationController Delegate
extension AddChatRoomPostController: KanvasCameraControllerDelegate {
    func camera(sender: KanvasNavigationController, didFinishPicking media: Media) {
        print("finish picking media: \(media)")
        AppDelegate.disableScreenOrientation()
        
        self.media = media
        sender.hideModal()
        attachmentButton.kf.setImage(with: media.getImageUrl(), for: .normal)
        
        validateInputs()
    }
}

extension AddChatRoomPostController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text != "" {
            placeholderLabel.isHidden = true
        }else {
            placeholderLabel.isHidden = false
        }
        validateInputs()
        textView.layoutIfNeeded()
    }
    
}

extension AddChatRoomPostController: SendButtonViewDelegate {
    func sendButtonView(sender: SendButtonView, didPressSend button: UIButton) {
        createPost(sender: button)
    }
}

