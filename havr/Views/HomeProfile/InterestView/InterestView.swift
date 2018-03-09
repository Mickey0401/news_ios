//
//  InterestView.swift
//  havr
//
//  Created by Agon Miftari on 4/23/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

enum InterestViewType {
    case profile
    case userProfile
    case nearby
    case posting
}

protocol InterestViewDelegate :class{
    func didSelect(contentType: InterestContent, interest: UserInterest?,  in collectionCiew: UICollectionView, at indexPath: IndexPath)
    //    func didSelect(interest: UserInterest, at index: IndexPath)
    func didUpload(media: Media?, error: ErrorMessage?, at index: Int)
    func didSave(sender : InterestView)
}

class InterestView: UIView {
    
    //MARK: - OUTLETS
    @IBOutlet weak var interestCollection: UICollectionView!
    
    //MARK: - VARIABLES
    var horizontalCenterConstraint: NSLayoutConstraint?
    var centerX : CGFloat?
    var selectedCell: IndexPath? = nil
    
    var createPost: (() -> Void)? = nil
    var view: UIView!
    var selectedIndex: Int = -1
    var delegate: InterestViewDelegate?
    var footerView : SaveImageView? = nil
    
    var footerViewSaveStatus: Bool = false {
        didSet {
            if footerViewSaveStatus {
                footerView?.saveLabel.text = "saved"
                footerView?.imageView.image = #imageLiteral(resourceName: "SUCCESS")
                footerView?.saveButton.isEnabled = false
            } else {
                footerView?.saveLabel.text = "save"
                footerView?.imageView.image = #imageLiteral(resourceName: "C save icon")
                footerView?.saveButton.isEnabled = true
            }
        }
    }
    
    var profileInterests: [UserInterest]{
        return ResourcesManager.activeInterests
    }
    
    var postingInterests: [UserInterest] {
        var interest = ResourcesManager.activeInterestsWithoutSaved
        return interest.filter({ (item) -> Bool in
            return !item.isReaction()
        }).map({ (item) -> UserInterest in
            return item
        })
    }

    var dataSource: [InterestContent] {
        get {
            switch self.type {
            case .profile:
                let filteredResult = profileInterests.sorted(by: { (lhs, rhs) -> Bool in
                    guard let first = lhs.item?.id, let second = rhs.item?.id else { return false }
                    return first > second
                })
                var interest = filteredResult.map({ interest -> InterestContent in
                    if interest.item?.name == "saved" {
                        return InterestContent.save(id: (interest.item?.id)!)
                    }
                    return InterestContent.interest(name: interest.item?.name, imageUrl: interest.item?.getUrl(), isSeen: interest.item?.isSeen, id: (interest.item?.id)!)
                })
                interest.insert(InterestContent.save(id: 0), at: 0)
                interest.insert(InterestContent.last24Hour(isSeen: true), at: 1)
                if interest.count < 4 {
                    interest.insert(InterestContent.addNew, at: interest.count)
                }
//                if interest.count > 1 {
//                    interest.swapAt(0, 1)
//                }
                return interest
            case .userProfile, .nearby:
                let filteredResult = userProfileInterests.sorted(by: { (lhs, rhs) -> Bool in
                    guard let first = lhs.item?.id, let second = rhs.item?.id else { return false }
                    return first > second
                })
                var interest = filteredResult.map({ interest -> InterestContent in
                    if interest.item?.name == "saved" {
                        return InterestContent.save(id: (interest.item?.id)!)
                    }

                    return InterestContent.interest(name: interest.item?.name, imageUrl: interest.item?.getUrl(), isSeen: interest.item?.isSeen, id: (interest.item?.id)!)
                })
                if interest.count > 1 {
                    interest.swapAt(0, 1)
                }
                return interest
            case .posting:
                let interest = postingInterests.map({ interest -> InterestContent in
                    return InterestContent.interest(name: interest.item?.name, imageUrl: interest.item?.getUrl(), isSeen: interest.item?.isSeen, id: (interest.item?.id)!)
                })
                return interest
            }
        }
        set {
            if type == .userProfile{
                interestCollection.reloadData()
            }
        }
    }
    
    var userProfileInterests: [UserInterest] = []
    var media: Media?
    private var _user : User? = nil
    var user : User?{
        didSet{
            if let userId = user?.id, _user == nil{
                _user = user
                getInterests(for: userId)
            }
        }
    }
    var type: InterestViewType = .profile{
        didSet{
            interestCollection.reloadData()
        }
    }
    
    //MARK: - LIFE CYCLE
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionInit()
    }
    
    func collectionInit(){
        interestCollection.delegate = self
        interestCollection.dataSource = self
        interestCollection.registerInterestCollectionCell()
        
        interestCollection.register(UINib.init(nibName: "SaveImageView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "SaveImageView")
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
        //        setupHorizontalTriangle()
    }
    
    func setup(){
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        
        
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        return UINib(nibName: "InterestView", bundle: bundle).instantiate(withOwner: self, options: nil)[0] as! UIView
    }
    
    
    func setupHorizontalTriangle() {
        let horizontalBarView = UIView()
        
        horizontalBarView.backgroundColor = UIColor(red255: 230, green255: 230, blue255: 230)
        horizontalBarView.translatesAutoresizingMaskIntoConstraints = false
        horizontalBarView.transform = CGAffineTransform(rotationAngle: CGFloat(0.766666))
        self.addSubview(horizontalBarView)
        
        //constraints for x, y, width and height
        horizontalCenterConstraint = horizontalBarView.centerXAnchor.constraint(equalTo: self.leftAnchor)
        horizontalCenterConstraint?.constant = -20
        horizontalCenterConstraint?.isActive = true
        
        let bottomAnchorBarView = horizontalBarView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        bottomAnchorBarView.constant = 8
        bottomAnchorBarView.isActive = true
        
        horizontalBarView.widthAnchor.constraint(equalToConstant: 16).isActive = true
        horizontalBarView.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        if type == .nearby {
            horizontalBarView.isHidden = true
        }else {
            horizontalBarView.isHidden = false
        }
    }
    
    func upload(media: Media, at index: Int){
        selectedIndex = index
        if media.uploadStatus == .uploaded {
            self.reloadCollection(at: index)
            
            self.delegate?.didUpload(media: media, error: nil, at: index)
            return
        }
        
        if media.uploadStatus == .uploading {
            return
        }
        
        self.media = media
        self.media!.upload(deleteOnUpload: true, completion: { (media, success, error) in
            self.media = media
            self.reloadCollection(at: index)
            
            if success{
                self.delegate?.didUpload(media: media, error: nil, at: index)
            }else{
                self.delegate?.didUpload(media: media, error: error, at: index)
                console("upload error: \(String(describing: error))")
            }
        }, progress: { (progress) in
            let cell = self.interestCollection.cellForItem(at: IndexPath.init(row: index, section: 0)) as! InterestCollectionCell
            
            if let media = self.media, media.uploadStatus == .uploading{
                delay(delay: 0, closure: {
                    cell.progressView.isHidden = false
                    cell.interestImageView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
                    
                    cell.progressView.animate(toAngle: Double(media.progress * 360), duration: 1.0, completion: { (sucess) in
                    })
                })
            }else{
                delay(delay: 0, closure: {
                    cell.interestImageView.transform = CGAffineTransform.identity
                    cell.progressView.isHidden = true
                })
            }
            
            if media.progress == 1{
                cell.interestImageView.transform = CGAffineTransform.identity
                cell.progressView.isHidden = true
            }
            console("upload progress: \(progress)")
        })
    }
    
    func reloadCollection(at index: Int){
        delay(delay: 0, closure: {
            self.interestCollection.performBatchUpdates({
                let indexSet = IndexSet(integer: 0)
                self.interestCollection.reloadSections(indexSet)
                //                self.interestCollection.reloadItems(at: [IndexPath.init(row: index, section: 0)])
            }, completion: nil)
            //            self.interestCollection.reloadData()
        })
    }
    
    func getInterests(for userId: Int) {
        InterestsAPI.getInterest(for: userId) { (interest, error) in
            if let i = interest {
                self.userProfileInterests = i
                DispatchQueue.main.async {
                    self.interestCollection.reloadData()
                }
            }
        }
        DispatchQueue.main.async {
            self.interestCollection.reloadData()
        }
    }
}

//MARK: - EXTENSIONS
extension InterestView : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueInterestCollectionCell(indexpath: indexPath)
        if let selectedIndexPath = selectedCell {
            if selectedIndexPath == indexPath {
                cell.interestName.font = UIFont.helveticaBold(12)
            } else {
                cell.interestName.font = UIFont.helveticaRegualr(12)
            }
        }
        switch type {
        case .profile:
//            if indexPath.item < dataSource.count {
                let interest = dataSource[indexPath.item]
                cell.bindInterestImageWithoutRoundedView()
                cell.update(with: interest)
//
//            } else {
//                cell.bindAddInterestWithoutRoundedView()
//                cell.interestName.text = nil
//            }
        case .userProfile, .nearby:
            if indexPath.item < dataSource.count {
                
                let interest = dataSource[indexPath.item]
                //isSeen or NotSeen Badge
//                delay(delay: 0.1, closure: {
//                    //                    if interest.item?.isSeen == true {
//                    //                        cell.isSeenView.isHidden = false
//                    //                        cell.bindIsSeen()
//                    //                    }else {
//                    //                        cell.isSeenView.isHidden = false
//                    //                        cell.bindIsNotSeen()
//                    //                    }
//                })
                cell.bindInterestImageWithoutRoundedView()
                cell.update(with: interest)
            } else {
                cell.interestName.text = nil
            }
        case .posting:
            if indexPath.item < dataSource.count {
                
                let interest = dataSource[indexPath.item]
                cell.progressView.isHidden = true
                
                if selectedIndex == indexPath.row {
                    if let media = self.media, media.uploadStatus == .uploaded{
                        delay(delay: 0, closure: {
                            cell.progressView.isHidden = false
                            cell.progressView.animate(toAngle: Double(360), duration: 0, completion: { (sucess) in
                            })
                        })
                    }
                }else{
                    cell.interestImageView.transform = CGAffineTransform.identity
                    cell.progressView.isHidden = true
                }
                cell.bindInterestImageWithoutRoundedView()
                cell.interestName.textColor = .black
                cell.update(with: interest)
            } else {
                cell.interestName.text = nil
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.size.width - 70) / 5
        let height = collectionView.frame.size.height - 4
        let size = CGSize(width: width, height: height)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if type == .posting {
            let interest = dataSource.count + 1
            let totalWidth = collectionView.frame.size.width
            let space = 14
            
            let cellWidth = (totalWidth - (CGFloat(space) * 5 )) / 5
            
            let totalCellsWidth = (cellWidth * CGFloat(interest)) + CGFloat(space * interest)
            let totalSpacingWidth = (totalWidth - totalCellsWidth)
            
            let leftInset = totalSpacingWidth / 2
            _ = leftInset
            if interest == 6 {
                collectionView.isScrollEnabled = true
                collectionView.isPagingEnabled = false
                collectionView.bounces = true
                return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 10)
            }
            return UIEdgeInsets(top: 0, left: leftInset + 16, bottom: 2, right: 10)
        }
        return UIEdgeInsets(top: 0, left: 16, bottom: 2, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        footerView = (collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "SaveImageView", for: indexPath) as! SaveImageView)
        
        footerViewSaveStatus = footerViewSaveStatus || false
        
        footerView?.delegate = self
        return  footerView!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if type == .posting {
            let height = collectionView.frame.size.height
            let width = ((collectionView.frame.size.width - 70) / 5) + 10
            return CGSize(width: width, height: height)
        }else {
            return CGSize(width: 0, height: 0)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! InterestCollectionCell
        cell.interestName.font = UIFont.helveticaBold(12)
        selectedCell = indexPath
        
        
        if let media = self.media, media.uploadStatus == .uploading{
            return
        }
        
        if selectedIndex == indexPath.item {
            //create post
            self.createPost?()
        }
        
        var indexesArray = [indexPath]
        if selectedIndex >= 0 && selectedIndex != indexPath.item {
            let oldIndexPath = IndexPath(item: selectedIndex, section: 0)
            indexesArray.append(oldIndexPath)
        }
        
        selectedIndex = indexPath.item
        //        collectionView.reloadItems(at: indexesArray)
        
        let interest = dataSource[indexPath.row]
        //        interest.item?.isSeen = true
        
        for i in 0..<dataSource.count{
            let item = dataSource[i]
            if i == indexPath.row {
                //                interest.isSelected = !interest.isSelected
                dataSource[i] = interest
            }else{
                //                item.isSelected = false
            }
        }
        collectionView.isUserInteractionEnabled = false
        switch self.type {
        case .posting:
            let selectedIntersr = postingInterests[safe: indexPath.item]
            selectedIntersr?.item?.isSeen = true
            self.delegate?.didSelect(contentType: interest, interest: selectedIntersr, in: collectionView, at: indexPath)
        case .profile:
            let selectedIntersr = profileInterests[safe: indexPath.item]
            selectedIntersr?.item?.isSeen = true
            self.delegate?.didSelect(contentType: interest, interest: selectedIntersr, in: collectionView, at: indexPath)
        case .userProfile, .nearby:
            let selectedIntersr = userProfileInterests[safe: indexPath.item]
            selectedIntersr?.item?.isSeen = true
            self.delegate?.didSelect(contentType: interest, interest: selectedIntersr, in: collectionView, at: indexPath)
        }
    }
}

extension InterestView: SaveImageViewDelegate {
    func saveImageView(sender: SaveImageView, didPressSaveButton button: UIButton) {
        self.delegate?.didSave(sender: self)
    }
}
