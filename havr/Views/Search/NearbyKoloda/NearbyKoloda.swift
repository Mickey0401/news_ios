//
//  NearbyKoloda.swift
//  havr
//
//  Created by Ismajl Marevci on 5/27/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import Koloda

class NearbyKoloda: OverlayView {
    
    @IBOutlet lazy var userImageView: UIImageView! = {
        [unowned self] in
        
        var imageView = UIImageView(frame: self.bounds)
        self.addSubview(imageView)
        
        return imageView
        }()
    @IBOutlet weak var interestView: InterestView!
    @IBOutlet weak var userinfoLabel: UILabel!
    @IBOutlet weak var superView: UIView!
    
    var user: User!{
        didSet{
           updateFileds()
        }
    }

    //MARK: - LIFE CYCLE
    override func awakeFromNib() {
        super.awakeFromNib()
        setValues()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setValues()
    }
    func setValues() {
        interestView.user = user
        interestView.type = .userProfile
    }
    
    func fetchProfile() {
        UsersAPI.getUser(by: user.id) { (user, error) in
            if let user = user {
                self.user = user
                self.setValues()
            }
        }
    }
    
    func updateFileds() {
        if let image = user.getUrl() {
            userImageView.kf.setImage(with: image, placeholder: Constants.defaultImageUserKoloda)
        }else {
            userImageView.image = Constants.defaultImageUserKoloda
        }
        userinfoLabel.text = "\(user.getFirstName()), \(user.age)"
    }
    
}
