//
//  UserProfileCollectionView.swift
//  havr
//
//  Created by Alexandr Lobanov on 12/4/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import SkeletonView

@objc protocol UserProfileDelegate: class {
    func userProfile(_ sender: UserProfileReusableCollectionView, didTapEditButton: UIButton?)
    func userProfile(_ sender: UserProfileReusableCollectionView, didTapFollowersButton: UIButton?)
    func userProfile(_ sender: UserProfileReusableCollectionView, didTapConnections: UIButton)
    func homeProfile(sender: UserProfileReusableCollectionView, selectPostsButton button: UIButton)
    func userProfile(_ sender:UserProfileReusableCollectionView, didFetchProfile: User)
    
    @objc optional func userProfile(_ sender: UserProfileReusableCollectionView, showConnections: UIView)
    @objc optional func userProfile(_ sender: UserProfileReusableCollectionView, didStartLoadUser: Bool)
    @objc optional func userProfile(_ sender: UserProfileReusableCollectionView, didPressConnectButton button: UIButton)
    @objc optional func userProfile(_ sender: UserProfileReusableCollectionView, didPressMessage button: UIButton)
    
    var userUpdate: User? { get }
}

class UserProfileReusableCollectionView: UICollectionReusableView {
    
    @IBOutlet weak var interestsView: InterestView!
    @IBOutlet weak var userImageView: RoundedImageView!
    @IBOutlet weak var userTagLabel: UILabel!
    @IBOutlet weak var fullenameLabel: UILabel!
    @IBOutlet weak var connectedCountLabel: UILabel!
    @IBOutlet weak var followwersCountLabel: UILabel!
    @IBOutlet weak var connetedButton: BorderedButton!
    @IBOutlet weak var editProfileButton: BorderedButton!
    @IBOutlet weak var connectedLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    
    var publicUser: User!
    
    weak var delegate: UserProfileDelegate? {
        didSet {
            guard let user = delegate?.userUpdate else { return }
            guard let selfUser = AccountManager.currentUser else { return }
            let isCurrenUser = user.id == selfUser.id
            editProfileButton.setTitle(isCurrenUser ? "EDIT" : "FOLLOWING", for: .normal)
            connetedButton.isHidden = isCurrenUser
            self.isCurrentUser = isCurrenUser
        }
    }
    fileprivate var isCurrentUser: Bool!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupGesturesForLabels()
    }
    
    @IBAction func actionDependingOnState(_ sender: UIButton) {
        guard isCurrentUser else {
            showFollowers()
            return
        }
        editProfile(sender)
    }
    
    @IBAction func connectedAction(_ sender: UIButton) {
        conectAction(sender)
    }
    
    func updateView() {
        guard let user = delegate?.userUpdate else { return }
        if let imageUrl = user.getUrl() {
            userImageView.kf.setImage(with: imageUrl, placeholder: user.getPlaceholder())
        } else {
            userImageView.setImageForName(string: user.fullName, circular: true, textAttributes: nil)
        }
        guard let stats = user.stats else { return }
        self.userTagLabel.text = "@" + user.username
        self.fullenameLabel.text = user.fullName
        self.connectedCountLabel.text = stats.connections.abbreviated
        self.followwersCountLabel.text = stats.viewsCount.abbreviated
        self.interestsView.user = user
        self.interestsView.type = self.isCurrentUser ? .profile : .userProfile
        self.interestsView.interestCollection.reloadData()
        self.updateInformation()
    }
    
    func updateInformation() {
        guard let user = delegate?.userUpdate else { return }
        switch user.status {
        case .connect:
            connetedButton.setTitle("CONNECT", for: .normal)
            guard let selfUser = AccountManager.currentUser else { return }
            let _ = user.id == selfUser.id ? connetedButton.disable() : connetedButton.enable()
        case .connected:
            connetedButton.setTitle("CONNECTED", for: .normal)
            connetedButton.enable()
        case .requested:
            connetedButton.setTitle("REQUSTED", for: .normal)
            connetedButton.enable()
        case .requesting:
            connetedButton.setTitle("ACCEPT", for: .normal)
            connetedButton.enable()
        case .declined:
            connetedButton.setTitle("CONNECT", for: .normal)
            connetedButton.enable()
        case .blocked:
            connetedButton.setTitle("", for: .normal)
            connetedButton.disable()
        case .blocking:
            connetedButton.setTitle("UNBLOCK", for: .normal)
            connetedButton.enable()
        }
    }
    
    func fetchProfile() {
        self.showAnimatedSkeleton()
        delegate?.userProfile!(self, didStartLoadUser: true)
        UsersAPI.getUser(by: publicUser.id) { (user, error) in
            if let user = user {
                self.publicUser = user
                self.updateView()
                self.hideSkeleton()
                self.delegate?.userProfile(self, didFetchProfile: user)
            }
        }
    }
}

private extension UserProfileReusableCollectionView {
    func setupGesturesForLabels() {
        userImageView.addTapGestureFor(self,  #selector(UserProfileReusableCollectionView.editProfile(_:)))
        followwersCountLabel.addTapGestureFor(self, #selector(UserProfileReusableCollectionView.showFollowers))
        followersLabel.addTapGestureFor(self, #selector(UserProfileReusableCollectionView.showFollowers))
        connectedLabel.addTapGestureFor(self, #selector(UserProfileReusableCollectionView.showConnections))
        connectedCountLabel.addTapGestureFor(self, #selector(UserProfileReusableCollectionView.showConnections))
    }
}

private extension UserProfileReusableCollectionView {
    @objc func conectAction(_ sender: UIButton) {
        guard let user = delegate?.userUpdate else { return }
        guard let selfUser = AccountManager.currentUser else { return }
        if user.id == selfUser.id {
            delegate?.userProfile(self, didTapConnections: sender)
        } else {
            delegate?.userProfile!(self, didPressConnectButton: sender)
        }
    }
    
    @objc func showConnections(_ sender: UIView) {
        delegate?.userProfile!(self, showConnections: sender)
    }
    
    @objc func showFollowers() {
        delegate?.userProfile(self, didTapFollowersButton: nil)
    }
    
    @objc func editProfile(_ sender: UIButton?) {
        delegate?.userProfile(self, didTapEditButton: sender)
    }
}

extension UIView {
    func addTapGestureFor(_ target: Any?, _ selector: Selector) {
        let gesture = UITapGestureRecognizer(target: target, action: selector)
        gesture.numberOfTapsRequired = 1
        isUserInteractionEnabled = true
        addGestureRecognizer(gesture)
    }
}
