//
//  PostsHeaderCollectionReusableView.swift
//  havr
//
//  Created by Ismajl Marevci on 6/1/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

class PostsHeaderCollectionReusableView: UICollectionReusableView {
    
    //MARK: - OUTLETS
    @IBOutlet weak var interestView: InterestView!
    
    //MARK: - VARIABLES
    var user : User!
    var isFromProfileVC : Bool = false
    //MARK: - LIFE CYCLE
    override func awakeFromNib() {
        super.awakeFromNib()
        setValues()
    }
    func setValues() {
        interestView.user = user
        
        if isFromProfileVC {
            interestView.type = .profile
        }else {
            interestView.type = .userProfile
        }
    }
    
    func fetchProfile() {
        UsersAPI.getUser(by: user.id) { (user, error) in
            if let user = user {
                self.user = user
                self.setValues()
            }
        }
    }
}
