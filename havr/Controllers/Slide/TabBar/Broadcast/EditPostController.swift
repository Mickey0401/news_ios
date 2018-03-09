//
//  EditPostController.swift
//  havr
//
//  Created by Ismajl Marevci on 6/20/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import MBProgressHUD

protocol EditPostControllerDelegate: class {
    func didUpdate(post: Post)
}

class EditPostController: UIViewController {

    //MARK: - OUTLETS
    @IBOutlet weak var saveChangesButton: UIButton!

    @IBOutlet weak var titleTextView: GrowingTextView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var dismissButton: UIButton!
    
    //MARK: - VARIABLES
    var post: Post!
    weak var delegate: EditPostControllerDelegate!

    
    
    //MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        fillPost()
        titleTextView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GA.TrackScreen(name: "Edit Post")
    }
    
    func fillPost(){
        saveChangesButton.setTitle("Save changes", for: UIControlState())
        titleTextView.text = post.title
        usernameLabel.text = post.author.fullName
        timeLabel.text = post.createdDate.timeAgoSinceDate()
        if let image = post.author.getUrl() {
            userImageView.kf.setImage(with: image, placeholder: Constants.defaultImageUser)
        }else {
            userImageView.image = Constants.defaultImageUser
        }
        titleTextView.becomeFirstResponder()
    }

    
    //MARK: - ACTIONS
    @IBAction func dismissButtonPressed(_ sender: UIButton) {
        self.hideModal()
    }
    @IBAction func saveChangesButtonPressed(_ sender: UIButton) {
        self.showHud()
        sender.setTitle("Please wait...", for: UIControlState())
        let title = titleTextView.text!
        PostsAPI.update(post: post, title: title) { (success, error) in
            self.hideHud()
            if success {
                self.post.title = title
                self.delegate.didUpdate(post: self.post)
                MBProgressHUD.showWithStatus(view: self.view, text: "Success", image: #imageLiteral(resourceName: "SUCCESS"))
                self.hideModal()
            }else{
                MBProgressHUD.showWithStatus(view: self.view, text: error?.message ?? "Post could not be updated!", image: #imageLiteral(resourceName: "ERROR"))
            }
            sender.setTitle("Save changes", for: .normal)
        }
    }
}
extension EditPostController: GrowingTextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            return false
        }
        return true
    }
}

//MARK: - EXTENSIONS
extension EditPostController {
    static func create() -> EditPostController {
        return UIStoryboard.broadcast.instantiateViewController(withIdentifier: "EditPostController") as! EditPostController
    }
}
