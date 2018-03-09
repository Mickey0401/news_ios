//
//  UserProfileCollectionReusableView.swift
//  havr
//
//  Created by Ismajl Marevci on 5/27/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

protocol UserProfileCollectionReusableViewDelegate: class {
    func userProfile(sender: UserProfileCollectionReusableView, selectConnectButton button: UIButton)
    func userProfile(sender: UserProfileCollectionReusableView, selectMessageButton button: UIButton)
    func userProfile(sender: UserProfileCollectionReusableView, selectReactionsButton button: UIButton)
    func userProfile(sender: UserProfileCollectionReusableView, selectConnectionsButton button: UIButton)
    func userProfile(sender: UserProfileCollectionReusableView, selectPostsButton button: UIButton)
    func userProfileDidFetchProfile(sender: UserProfileCollectionReusableView, user: User)
}

class UserProfileCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var interestView: InterestView!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    
    @IBOutlet weak var reactionsButton: UIButton!
    @IBOutlet weak var numberOfReactionsLabel: UILabel!
    @IBOutlet weak var reactionsLabel: UILabel!
    
    @IBOutlet weak var connectionsButton: UIButton!
    @IBOutlet weak var numberOfConnectionsLabel: UILabel!
    @IBOutlet weak var connectionsLabel: UILabel!
    
    @IBOutlet weak var postsButton: UIButton!
    @IBOutlet weak var postsLabel: UILabel!
    @IBOutlet weak var numberofPostsLabel: UILabel!

    @IBOutlet weak var userImageView: UIImageView!
    
    var user : User!
    weak var delegate: UserProfileCollectionReusableViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setValues()
    }
    
    func setValues() {
        
        if let user = user {
            
            if let image = user.getUrl() {
                userImageView.kf.setImage(with: image, placeholder: user.getPlaceholder())
            }else {
                userImageView.image = #imageLiteral(resourceName: "defaultImageUser")
            }
            
            if let stats = user.stats {
                
                if stats.connections == 1 {
                    connectionsLabel.text = "CONNECTION"
                }else {
                    connectionsLabel.text = "CONNECTIONS"
                }
                self.numberOfConnectionsLabel.text = stats.connections.abbreviated
                
                if stats.posts == 1 {
                    postsLabel.text = "POST"
                }else {
                    postsLabel.text = "POSTS"
                }
                self.numberofPostsLabel.text = stats.posts.abbreviated
                
                if stats.viewsCount == 1 {
                    reactionsLabel.text = "PROFILE VIEW"
                }else {
                    reactionsLabel.text = "PROFILE VIEWS"
                }
                self.numberOfReactionsLabel.text = stats.viewsCount.abbreviated
            }
            
            update()
        }
        interestView.user = user
        interestView.type = .userProfile
    }
    
    func fetchProfile() {
        UsersAPI.getUser(by: user.id) { (user, error) in
            if let user = user {
                self.user = user
                self.setValues()
                self.delegate?.userProfileDidFetchProfile(sender: self, user: user)
            }
        }
    }
    
    func update(){
        connectButton.setTitle(user.status.rawValue, for: .normal)
        connectButton.backgroundColor = Apperance.appGreenColor
        connectButton.borderColor = Apperance.appGreenColor
        connectButton.setTitleColor(UIColor.white, for: UIControlState())
        connectButton.borderWidth = 1
        switch user.status {
            
        case .connected:
            connectButton.backgroundColor = UIColor.white
            connectButton.borderColor = Apperance.EFEFEFColor
            connectButton.setTitleColor(UIColor.black, for: UIControlState())
            connectButton.borderWidth = 1
            connectButton.setTitle("CONNECTED", for: .normal)
            break
        case .connect:
            connectButton.setTitle("CONNECT", for: .normal)
            break
        case .declined:
            connectButton.setTitle("CONNECT", for: .normal)
            break
        case .requested:
            connectButton.setTitle("REQUESTED", for: .normal)
            break
        case .requesting:
            connectButton.setTitle("ACCEPT", for: .normal)
            break
            
        case .blocked:
            connectButton.setTitle("", for: .normal)
            break
            
        case .blocking:
            connectButton.setTitle("UNBLOCK", for: .normal)
            break
        }
    }
    
    
    @IBAction func messageButtonPressed(_ sender: UIButton) {
        self.delegate?.userProfile(sender: self, selectMessageButton: sender)
    }
    @IBAction func connectButtonPressed(_ sender: UIButton) {
        self.delegate?.userProfile(sender: self, selectConnectButton: sender)
    }
    @IBAction func reactionsButtonPressed(_ sender: UIButton) {
        self.delegate?.userProfile(sender: self, selectReactionsButton: sender)
    }
    @IBAction func connectionsButtonPressed(_ sender: UIButton) {
        self.delegate?.userProfile(sender: self, selectConnectionsButton: sender)
    }
    @IBAction func postsButtonPressed(_ sender: UIButton) {
        self.delegate?.userProfile(sender: self, selectPostsButton: sender)
    }
    
}
