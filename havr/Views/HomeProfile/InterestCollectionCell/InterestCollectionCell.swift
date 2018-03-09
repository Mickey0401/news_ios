//
//  InterestCollectionCell.swift
//  havr
//
//  Created by Agon Miftari on 4/22/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import KDCircularProgress

enum InterestContent {
    case save(id: Int)
    case addNew
    case interest(name: String?, imageUrl: URL?, isSeen: Bool?, id: Int)
    case last24Hour(isSeen: Bool?)
}

class InterestCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var progressView: KDCircularProgress!
    @IBOutlet weak var interestName: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var interestImageView: RoundedImageView!
    @IBOutlet weak var addInterestImageView: RoundedImageView!
    
    @IBOutlet weak var cameraImageView: RoundedImageView!
    @IBOutlet weak var isSeenView: UIView!
    
    let isNotSeenColor: UIColor = UIColor(red255: 209, green255: 51, blue255: 67)
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override var isSelected: Bool {
        didSet {
            interestName.font = isSelected ? UIFont.helveticaBold(12) : UIFont.helveticaRegualr(12)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.interestImageView.image = nil
        self.addInterestImageView.image = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        delay(delay: 0) { 
            self.interestImageView.layoutIfNeeded()
            self.interestImageView.masksToBounds = true
            
            self.addInterestImageView.layoutIfNeeded()
            self.addInterestImageView.masksToBounds = true
            
            self.cameraImageView.layoutIfNeeded()
            self.cameraImageView.masksToBounds = true
            
            self.bindRoundedViewWithoutCamera(with: Color.purpleColor)
            
            //self.update(with: InterestContent.addNew)
        }
    }
    
    func bindIsNotSeen() {
        self.isSeenView.backgroundColor = isNotSeenColor
        self.isSeenView.isHidden = false

    }
    
    func bindIsSeen() {
        self.isSeenView.isHidden = true
    }
    
    func bindRoundedViewWithoutCamera(with color: UIColor){
        delay(delay: 0) {
            self.containerView.isHidden = false
            self.interestImageView.isHidden = false
            self.cameraImageView.isHidden = true
            self.addInterestImageView.isHidden = true
            self.containerView.layer.cornerRadius = self.containerView.frame.size.width / 2
            self.containerView.layer.borderWidth = 2
            self.containerView.layer.borderColor = color.cgColor
        }
    }
//
    func bindInterestImageWithoutRoundedView() {
        containerView.isHidden = true
        interestImageView.isHidden = false
        cameraImageView.isHidden = true
        addInterestImageView.isHidden = true
    }

    func bindAddInterestWithoutRoundedView() {
        containerView.isHidden = true
        interestImageView.isHidden = true
        cameraImageView.isHidden = true
        addInterestImageView.isHidden = false
    }
    
    func update(with content: InterestContent) {
        self.interestImageView.kf.cancelDownloadTask()
        switch content {
        case .addNew:
            self.interestName.text = "add"
            self.interestImageView.image = #imageLiteral(resourceName: "add_new_interest")
            self.isSeenView.isHidden = true
        case .save:
            self.interestName.text = "favourite"
            self.interestImageView.image = #imageLiteral(resourceName: "save_interests")
            self.isSeenView.isHidden = true
        case .interest(let name, let url, let isSeen, _):
            self.interestName.text =  name
            self.interestImageView.kf.setImage(with: url)
            self.isSeenView.isHidden = isSeen ?? false
        case .last24Hour(let isSeen):
            self.interestName.text =  "moments"
            self.interestImageView.image = #imageLiteral(resourceName: "24hour")
            self.isSeenView.isHidden = isSeen ?? false
        }
    }
}

extension UICollectionView {
    func registerInterestCollectionCell() {
        let nib = UINib(nibName: "InterestCollectionCell", bundle: nil)
        
        self.register(nib, forCellWithReuseIdentifier: "InterestCollectionCell")
    }
    
    func dequeueInterestCollectionCell(indexpath: IndexPath) -> InterestCollectionCell {
        return dequeueReusableCell(withReuseIdentifier: "InterestCollectionCell", for: indexpath) as! InterestCollectionCell
    }
}
