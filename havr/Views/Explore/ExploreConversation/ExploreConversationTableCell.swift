//
//  ExploreConversationTableCell.swift
//  havr
//
//  Created by Ismajl Marevci on 5/3/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
protocol ExploreConversationTableCellDelgate: class {
    func exploreConversationCell(sender: ExploreConversationTableCell, didPressMoreButton button: UIButton)
    func exploreConversationCell(sender: ExploreConversationTableCell, didPressLikeButton button: UIButton)
    func exploreConversationCell(sender: ExploreConversationTableCell, post: ChatRoomPost, didPressCommentsLabel label: UILabel)
    func exploreConversationCell(sender: ExploreConversationTableCell, post: ChatRoomPost, didPressTitleLabel label: UILabel)
    func exploreConversationCell(sender: ExploreConversationTableCell, didPressContentImage image: UIImage)
}

class ExploreConversationTableCell: UITableViewCell {
    
    //MARK: - OUTLETS
    @IBOutlet weak var mediaView: UIView!
    @IBOutlet weak var mediaViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var supportsButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var commentsView: UIView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var titleLabel: SRCopyableLabel!
    
    //MARK: - VARIABLES
    var post: ChatRoomPost?{
        didSet{
            setValues()
        }
    }
    weak var delegate: ExploreConversationTableCellDelgate?
    
    //MARK: - LIFE CYCLE
    override func awakeFromNib() {
        super.awakeFromNib()
        setupTaps()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupTaps() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(pressMedia))
        tap.numberOfTapsRequired = 1
        self.contentImageView?.isUserInteractionEnabled = true
        self.contentImageView?.addGestureRecognizer(tap)
        
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(didPressTitle))
        tap2.numberOfTapsRequired = 1
        self.titleLabel?.isUserInteractionEnabled = true
        self.titleLabel?.addGestureRecognizer(tap2)
        
        
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(didPressComment))
        tap3.numberOfTapsRequired = 1
        self.commentsLabel?.isUserInteractionEnabled = true
        self.commentsLabel?.addGestureRecognizer(tap3)
    }
    func pressMedia() {
        if let image = contentImageView.image {
            self.delegate?.exploreConversationCell(sender: self, didPressContentImage: image)
        }
    }
    func didPressComment() {
        if let label = commentsLabel {
            self.delegate?.exploreConversationCell(sender: self, post: post!, didPressCommentsLabel: label)
        }
    }
    func didPressTitle() {
        if let label = titleLabel {
            self.delegate?.exploreConversationCell(sender: self, post: post!, didPressTitleLabel: label)
        }
    }
    
    func setValues(){
        if let post = post {
            self.titleLabel.setChatRoomPost(title: post.title, subTitle: post.text)
            self.timeLabel.text = post.getTime()
            
            commentsLabel?.text = "\(post.commentsCount.abbreviated)"
            
            supportsButton?.setTitle("\(post.likesCount.abbreviated)", for: UIControlState())
            supportsButton?.setTitleColor(post.isLiked ? Apperance.redColor : Apperance.F8F8F8Color, for: UIControlState())
            supportsButton?.setImage(post.isLiked ? #imageLiteral(resourceName: "B supports filled icon") : #imageLiteral(resourceName: "B supports Icon"), for: UIControlState())
            
            if post.isAnon {
                userImage?.image = Constants.anonimImage
                usernameLabel?.text = "Anonymous"
            }else {
                usernameLabel?.text = post.user?.fullName
                if let image = post.user?.getUrl() {
                    userImage?.kf.setImage(with: image, placeholder: Constants.defaultImageUser)
                }else {
                    userImage?.image = Constants.defaultImageUser
                }
            }
            if let media = post.media {
                self.contentImageView?.kf.setImage(with: media.getImageUrl())
                mediaViewHeightConstraint?.constant = 200
            }else{
                mediaViewHeightConstraint?.constant = 0
            }
            self.mediaView?.layoutIfNeeded()
            self.layoutIfNeeded()
        }
    }
    
    //MARK: - ACTIONS
    @IBAction func moreButtonPressed(_ sender: UIButton) {
        self.delegate?.exploreConversationCell(sender: self, didPressMoreButton: sender)
    }
    @IBAction func supportsButtonPressed(_ sender: UIButton) {
        self.delegate?.exploreConversationCell(sender: self, didPressLikeButton: sender)
    }
}

//MARK: - EXTENSIONS
extension UITableView {
    func registerECSenderTextTableCell() {
        let nib = UINib(nibName: "ECSenderTextTableCell", bundle: nil)
        self.register(nib, forCellReuseIdentifier: "ECSenderTextTableCell")
    }
    func registerECReceiverTextTableCell() {
        let nib = UINib(nibName: "ECReceiverTextTableCell", bundle: nil)
        self.register(nib, forCellReuseIdentifier: "ECReceiverTextTableCell")
    }
    func registerECSenderCommentTableCell() {
        let nib = UINib(nibName: "ECSenderCommentTableCell", bundle: nil)
        self.register(nib, forCellReuseIdentifier: "ECSenderCommentTableCell")
    }
    func registerECReceiverCommentTableCell() {
        let nib = UINib(nibName: "ECReceiverCommentTableCell", bundle: nil)
        self.register(nib, forCellReuseIdentifier: "ECReceiverCommentTableCell")
    }
    
    func dequeueExploreConversationTableCell(identifier: String, indexPath: IndexPath) -> ExploreConversationTableCell {
        return self.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! ExploreConversationTableCell
    }
}
