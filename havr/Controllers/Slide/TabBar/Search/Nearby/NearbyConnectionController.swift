//
//  NearbyConnectionController.swift
//  havr
//
//  Created by Ismajl Marevci on 4/21/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

class NearbyConnectionController: UIViewController {
    
    //MARK: - OUTLETS
    @IBOutlet weak var behindLeftView: UIView!
    @IBOutlet weak var behindRightView: UIView!
    @IBOutlet weak var frontLeftView: UIView!
    @IBOutlet weak var frontRightView: UIView!
    @IBOutlet weak var imageLeftView: UIImageView!
    @IBOutlet weak var imageRightView: UIImageView!
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var keepLookingButton: UIButton!

    //MARK: - VARIABLES
    var user: User!
    var me = AccountManager.currentUser
    
    //MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        responseRadiusViews()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        responseRadiusViews()
    }

    func responseRadiusViews() {
        let bigRadius = behindLeftView.frame.size.height / 2
        let smallRadius = frontLeftView.frame.size.height / 2
        
        behindLeftView.layer.cornerRadius = bigRadius
        behindRightView.layer.cornerRadius = bigRadius
        
        frontLeftView.layer.cornerRadius = smallRadius
        frontRightView.layer.cornerRadius = smallRadius
        
        let butonRadius = sendMessageButton.frame.size.height / 2
        sendMessageButton.layer.cornerRadius = butonRadius
        keepLookingButton.layer.cornerRadius = butonRadius
        
        if let image = me?.getUrl() {
            imageLeftView.kf.setImage(with: image, placeholder: Constants.defaultImageUser)
        }else {
            imageLeftView.image = Constants.defaultImageUser
        }
        if let image = user?.getUrl() {
            imageRightView.kf.setImage(with: image, placeholder: Constants.defaultImageUser)
        }else {
            imageRightView.image = Constants.defaultImageUser
        }
        
    }
    
    //MARK: - ACTIONS
    @IBAction func sendMessageButtonClicked(_ sender: UIButton) {
        ChatManager.shared.getConversation(user: self.user.id) { (conversation, error) in
            if let conversation = conversation {
                
                self.hideModal(true, completion: { 
                    conversation.user = self.user
                    let conversationVC = ConversationController.create(conversation: conversation)
                    conversationVC.isFromBroadcastVC = false
                    self.presentingViewController?.push(conversationVC)
                })
            }
            
            if let error = error {
                Helper.show(alert: error.message)
            }
        }
    }
    @IBAction func keepLookingButtonClicked(_ sender: UIButton) {
        self.hideModal()
    }

}

//MARK: - EXTENSIONS
extension NearbyConnectionController {
    static func create() -> NearbyConnectionController {
        return UIStoryboard.search.instantiateViewController(withIdentifier: "NearbyConnectionController") as! NearbyConnectionController
    }
}
