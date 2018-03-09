//
//  BroadcastTableCell.swift
//  havr
//
//  Created by Ismajl Marevci on 4/22/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import OnlyPictures
import KILabel

protocol BroadcastControllerDelegate : class {
    func broadcastCell(sender: BroadcastTableCell, didSelectAt view: UIView)
    func broadcastCell(sender: BroadcastTableCell, didPressPostCommentsButton button: UIButton)
    func broadcastCell(sender: BroadcastTableCell, didPressPostSupoortButton button: UIButton)
    func broadcastCell(sender: BroadcastTableCell, didPressMoreButton button: UIButton)
    func broadcastCell(sender: BroadcastTableCell, didPressMoreDescriptionButton button: UIButton)
    func broadcastCell(sender: BroadcastTableCell, didPressisLikeButton button: UIButton)
    func broadcastCell(sender: BroadcastTableCell, didPressReactionButton button: UIButton)
    func broadcastCell(sender: BroadcastTableCell, didSelectComment user: User)
    func broadcastCell(sender: BroadcastTableCell, didPressName user: User)
    func broadcastCell(sender: BroadcastTableCell, didChangePageAt index: Int)
    func broadcastCell(sender: BroadcastTableCell, didTapAt image: UIImage)
    func broadcastCell(sender: BroadcastTableCell, didPressPromoteButton button: UIButton)
    func broadcastCell(_ sender: BroadcastTableCell, didPressMoreButtonFor post: Post)
}

class BroadcastTableCell: UITableViewCell {
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var likeView: UIView!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var saveView: UIView!
    
    @IBOutlet weak var commentsCountLabel: UILabel!
    @IBOutlet weak var likesCountLabel: UILabel!
    //MARK: - OUTLETS
    @IBOutlet weak var commentedUserHorizontalPicturesView: OnlyHorizontalPictures!
    @IBOutlet weak var userFullnameLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var userTapView: UIView!
    @IBOutlet weak var isLikeButton: UIButton!
    @IBOutlet weak var postDateLabel: UILabel!
    @IBOutlet weak var postDescriptionLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var promoteButton: UIButton!
    @IBOutlet weak var allCommentsLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!    
    @IBOutlet weak var sliderLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var sliderWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var slider: UIView!
    @IBOutlet weak var containerView: UIView!
    
    
    //MARK: - VARIABLEs
    var broadcastPost: BroadcastPost? {
        didSet{
            guard let broadcastPost = broadcastPost else { return }
            self.setupHorizontalBar()
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.commentedUserHorizontalPicturesView.reloadData()
            }
            if let mainIndex = broadcastPost.currentPage, !broadcastPost.didScrollToMainPost {
                lastPage = mainIndex
                scrollToMainPost()
            }else{
                delay(delay: 0, closure: {
                    self.collectionView.scrollToItem(at: IndexPath.init(row: broadcastPost.currentPage!, section: 0), at: .left, animated: false)
                })
            }
            setValues(post: broadcastPost.posts[broadcastPost.currentPage!])
        }
    }
    var owner: User = User()
    weak var delegate: BroadcastControllerDelegate? = nil
    weak var videoPlayerDelegate: VideoPlayerViewDelegate?
    weak var mentionLabelDelegate: MentionLabelDelegate?
    weak var urlLabelDelegate: URLLabelDelegate? 
    //    var page: Int = 0
    var index: Int = 0
    var lastPage = 0
    
    //MARK: - LIFE CYCLE
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionInit()
        onlyPicturesInit()
        separatorView.addInnerShadow(onSide: UIView.innerShadowSide.top, shadowColor: .black, shadowSize: 2, shadowOpacity: 0.25)
            separatorView.addInnerShadow(onSide: UIView.innerShadowSide.bottom, shadowColor: .black, shadowSize: 2, shadowOpacity: 0.25)
        allCommentsLabel.addTapGestureFor(self, #selector(showAllCommentsAction(_:)))
    }
    
    override func layoutSubviews() {
        delay(delay: 0) {
            self.setupHorizontalBar()
        }
    }
    
    func setupHorizontalBar() {
        guard let broadcastPost = broadcastPost else  { return }
         slider.isHidden = broadcastPost.posts.count == 1
        //        slider.backgroundColor = UIColor(red255: 70, green255: 70, blue255: 70)
        slider.translatesAutoresizingMaskIntoConstraints = false
        sliderWidthConstraint.constant = containerView.frame.width / CGFloat(broadcastPost.posts.count)
        slider.layoutIfNeeded()
    }
    
    func onlyPicturesInit() {
        commentedUserHorizontalPicturesView.alignment = .left
        commentedUserHorizontalPicturesView.spacingColor = .white
        commentedUserHorizontalPicturesView.recentAt = .right
        commentedUserHorizontalPicturesView.delegate = self
        commentedUserHorizontalPicturesView.dataSource = self
    }
    
    func collectionInit(){
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerBroadcastCollectionCell()
        setupTap()
    }
    
    func setupTap() {
//        saveView.addTapGestureFor(self, #selector(BroadcastTableCell.saveAction(_:)))
//        likeView.addTapGestureFor(self, #selector(BroadcastTableCell.isLikeButtonPressed(_:)))
//        messageView.addTapGestureFor(self, #selector(BroadcastTableCell.postCommentsButtonPressed(_:)))
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewTapFunction))
        tap.delegate = self
        tap.numberOfTapsRequired = 1
        self.userTapView.isUserInteractionEnabled = true
        self.userTapView.addGestureRecognizer(tap)
        
        let tapUser = UITapGestureRecognizer(target: self, action: #selector(userTapFunction))
        tapUser.delegate = self
        tapUser.numberOfTapsRequired = 1
        self.userImageView.isUserInteractionEnabled = true
        self.userImageView.addGestureRecognizer(tapUser)
        
        let tapUser1 = UITapGestureRecognizer(target: self, action: #selector(userTapFunction))
        tapUser1.delegate = self
        tapUser1.numberOfTapsRequired = 1
        self.userNameLabel.isUserInteractionEnabled = true
        self.userNameLabel.addGestureRecognizer(tapUser1)
        
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(profileTaped))
        tap2.delegate = self
        tap2.numberOfTapsRequired = 1
        //        self.promoteLabel.isUserInteractionEnabled = true
        //        self.promoteLabel.addGestureRecognizer(tap2)
    }
    
    
    
    func estimatedNumberOfRows(text: String) -> Int {
        let size = CGSize(width: UIScreen.main.bounds.width - 73, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let attributes = [NSFontAttributeName: UIFont.robotoRegularFont(12.0)]
        let rectangleHeight = String(text).boundingRect(with: size, options: options, attributes: attributes, context: nil).height
        
        let rows = rectangleHeight / 15.8
        return Int(rows)
    }
    
    func setValues(post: Post) {
        guard let broadcastPost = broadcastPost else { return }
        if let image = broadcastPost.author?.getUrl() {
            userImageView.kf.setImage(with: image, placeholder: Constants.defaultImageUser)
        }else {
            userImageView.setImageForName(string: post.author.fullName, circular: true, textAttributes: nil)
        }
        
        owner = post.author
        
        allCommentsLabel.text = post.postComment == 0 ? "No one left comment yet" : "See all \(post.postComment) comments"
        userFullnameLabel.text = post.owner.fullName
        userNameLabel.text = post.owner.username
        postDateLabel.text = post.createdDate.timeAgoSinceDate()
        locationLabel.text = "User location"
        if post.postComment == 1 {
            commentsCountLabel.text = "1"
        }else{
            commentsCountLabel.text = "\(post.postComment.abbreviated)"
        }
        
        likesCountLabel.textColor = post.isLiked ? UIColor(red255: 253, green255: 92, blue255: 99) : UIColor(red255: 151, green255: 153, blue255: 166)
        likesCountLabel.text = "\(post.likesCount)"
        DispatchQueue.main.async {
            guard let currentPage = broadcastPost.currentPage else { return }
            self.commentedUserHorizontalPicturesView.isHidden = broadcastPost.posts[currentPage].lastComments.count == 0
            self.commentedUserHorizontalPicturesView.reloadData()
        }
        
        if post.title != "" {
            postDescriptionLabel.text = post.title
            postDescriptionLabel.textColor = UIColor.black.withAlphaComponent(1)
            
        }else {
            postDescriptionLabel.text = "No caption"
            //            moreView.isHidden = true
            postDescriptionLabel.textColor = UIColor.lightGray
        }
        isLikeButton.setImage(post.isLiked ? #imageLiteral(resourceName: "B supports filled icon") : #imageLiteral(resourceName: "like"), for: .normal)
        promoteButton.setImage(post.isSaved() ? #imageLiteral(resourceName: "save_selected") : #imageLiteral(resourceName: "save"), for: .normal)
    }
    
    
    func scrollToMainPost(){
        guard var broadcastPost = broadcastPost else { return }
        guard let currentPage = broadcastPost.currentPage, !broadcastPost.didScrollToMainPost else { return }
        broadcastPost.didScrollToMainPost = true
        delay(delay: 0, closure: {
            self.collectionView.scrollToItem(at: IndexPath.init(row: currentPage, section: 0), at: .left, animated: false)
        })
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func viewTapFunction(){
        self.delegate?.broadcastCell(sender: self, didSelectAt: userTapView)
    }
    func userTapFunction(){
        guard let broadcastPost = broadcastPost else { return }
        let user = broadcastPost.author
        self.delegate?.broadcastCell(sender: self, didPressName: user!)
    }
    func profileTaped() {
        if owner.id != 0 {
            self.delegate?.broadcastCell(sender: self, didPressName: owner)
        }
    }
    
    //MARK: - ACTIONS
    @IBAction func moreAction(_ sender: Any) {
        guard let broadcastPost = broadcastPost else { return }
        guard let currentPage = broadcastPost.currentPage else { return }
        let post = broadcastPost.posts[currentPage]
        delegate?.broadcastCell(self, didPressMoreButtonFor: post)
    }
    @IBAction func reactionButtonPressed(_ sender: UIButton) {
        self.delegate?.broadcastCell(sender: self, didPressReactionButton: sender)
    }
    @IBAction func isLikeButtonPressed(_ sender: UIButton) {
        self.delegate?.broadcastCell(sender: self, didPressisLikeButton: sender)
    }
    @IBAction func moredotsButtonPressed(_ sender: UIButton) {
        self.delegate?.broadcastCell(sender: self, didPressMoreButton: sender)
    }
    @IBAction func postCommentsButtonPressed(_ sender: UIButton) {
        self.delegate?.broadcastCell(sender: self, didPressPostCommentsButton: sender)
    }
    @IBAction func postSupportsButtonPressed(_ sender: UIButton) {
        self.delegate?.broadcastCell(sender: self, didPressPostSupoortButton: sender)
    }
    @IBAction func moreDescriptionButtonPressed(_ sender: UIButton) {
        self.delegate?.broadcastCell(sender: self, didPressMoreDescriptionButton: sender)
    }
    
    @IBAction func saveAction(_ sender: UIButton) {
        self.delegate?.broadcastCell(sender: self, didPressPromoteButton: sender)
    }
    
    func showAllCommentsAction(_ sender: Any) {
        self.delegate?.broadcastCell(sender: self, didSelectComment: owner)
    }
}
//MARK: - EXTENSIONS
extension UITableView {
    func registerBroadcastTableCell(){
        let nib = UINib(nibName: "BroadcastTableCell", bundle: nil)
        self.register(nib, forCellReuseIdentifier: "BroadcastTableCell")
    }
    func dequeueBroadcastTableCell(indexpath: IndexPath) -> BroadcastTableCell{
        return self.dequeueReusableCell(withIdentifier: "BroadcastTableCell", for: indexpath) as! BroadcastTableCell
    }
}

extension BroadcastTableCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let broadcastPost = broadcastPost else { return 0 }
        return broadcastPost.posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let broadcastPost = broadcastPost else { return UICollectionViewCell()}
        let cell = collectionView.dequeueBroadcastCollectionCell(indexpath: indexPath)
        cell.videoPlayerDelegate = self.videoPlayerDelegate
        cell.delegate = self
        cell.post = broadcastPost.posts[indexPath.row]
        //        cell.videoView.pause()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let height = collectionView.frame.size.height
        let width = collectionView.frame.size.width
        return CGSize(width: contentView.frame.width, height: height)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let broadcastPost = broadcastPost else { return }
                let ratio = containerView.frame.width / self.frame.width
                sliderLeadingConstraint.constant = ((scrollView.contentOffset.x * ratio) / CGFloat(broadcastPost.posts.count))
                Helper.horizontalBarAnimation(view: containerView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard var broadcastPost = broadcastPost else { return }
        let page = Int(self.collectionView.contentOffset.x / self.collectionView.frame.size.width)
        broadcastPost.currentPage = page
        if lastPage != page{
            self.delegate?.broadcastCell(sender: self, didChangePageAt: lastPage)
        }
        lastPage = page
        setValues(post: broadcastPost.posts[broadcastPost.currentPage!])
    }
}

extension BroadcastTableCell: BroadcastCollectionCellDelegate{
    func broadcastCollectionCell(sender: BroadcastCollectionCell, didTapAt image: UIImage) {
        self.delegate?.broadcastCell(sender: self, didTapAt: image)
    }
}

extension BroadcastTableCell: OnlyPicturesDelegate {
    func pictureView(_ imageView: UIImageView, didSelectAt index: Int) {
        
    }
}

extension BroadcastTableCell: OnlyPicturesDataSource {
    func numberOfPictures() -> Int {
        guard let broadcastPost = broadcastPost else { return 0}
        guard let currentPage = broadcastPost.currentPage else { return 0 }
        return  broadcastPost.posts[currentPage].lastComments.count
    }
    
    func visiblePictures() -> Int {
        return 6
    }
    
    func pictureViews(_ imageView: UIImageView, index: Int) {
        guard let broadcastPost = broadcastPost else { return }
        let url = broadcastPost.posts[broadcastPost.currentPage!].lastComments[index].user.getUrl()
        imageView.image = #imageLiteral(resourceName: "likeFill")
        imageView.kf.setImage(with: url)
    }
}

