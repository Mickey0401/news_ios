//
//  HomeProfileReusableView.swift
//  havr
//
//  Created by Ismajl Marevci on 5/27/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

protocol HomeProfileReusableViewDelegate: class {
    func homeProfile(sender: HomeProfileReusableView, editProfileButton button: UIButton)
    func homeProfile(sender: HomeProfileReusableView, selectReactionsButton button: UIButton)
    func homeProfile(sender: HomeProfileReusableView, selectConnectionsButton button: UIButton)
    func homeProfile(sender: HomeProfileReusableView, selectPostsButton button: UIButton)
    
    var user: User? { get }
}

class HomeProfileReusableView: UICollectionReusableView {

    //MARK: - OUTLETS
    @IBOutlet weak var interestView: InterestView!
    @IBOutlet weak var editProfileButton: UIButton!
    
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
    
    //MARK: - VARIABLES
//    var user = AccountManager.currentUser{
//        didSet{
//            self.fetchProfile()
//        }
//    }
    weak var delegate: HomeProfileReusableViewDelegate?
    
    var activeInterests: [UserInterest] {
        return ResourcesManager.activeInterests
    }
    
    //MARK: - LIFE CYCLE
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setValues()
    }
    
    func setValues(){
        if let user = self.delegate?.user {
//            userFullNameLabel.text = user.fullName
//
//            usernameLabel.text = "@\(user.username)"
            
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
            interestView.type = .profile
            interestView.interestCollection.reloadData()
        }
    }
    
    func updateView() {
        setValues()
    }

    @IBAction func editProfileButtonPressed(_ sender: UIButton) {
        self.delegate?.homeProfile(sender: self, editProfileButton: sender)
    }
    @IBAction func reactionsButtonPressed(_ sender: UIButton) {
        self.delegate?.homeProfile(sender: self, selectReactionsButton: sender)
    }
    @IBAction func connectionsButtonPressed(_ sender: UIButton) {
        self.delegate?.homeProfile(sender: self, selectConnectionsButton: sender)
    }
    @IBAction func postsButtonPressed(_ sender: UIButton) {
        self.delegate?.homeProfile(sender: self, selectPostsButton: sender)
    }
    
    @IBAction func imageButtonPressed(_ sender: UIButton) {
                self.delegate?.homeProfile(sender: self, editProfileButton: sender)
    }
}
