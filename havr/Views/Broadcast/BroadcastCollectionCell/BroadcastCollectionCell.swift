//
//  BroadcastCollectionCell.swift
//  havr
//
//  Created by Ismajl Marevci on 4/22/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import SkeletonView

protocol BroadcastCollectionCellDelegate: class {
    func broadcastCollectionCell(sender: BroadcastCollectionCell, didTapAt image: UIImage)
}

class BroadcastCollectionCell: UICollectionViewCell {

    //MARK: - OUTLETS
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var videoContainer: UIView!
    var videoView: VideoView?
    
    //MARK: - VARIABLES
    weak var videoPlayerDelegate: VideoPlayerViewDelegate?{
        didSet{
            videoView?.videoPlayerDelegate = self.videoPlayerDelegate
        }
    }
    weak var delegate: BroadcastCollectionCellDelegate? = nil

    var post: Post!{
        didSet{
            setValues()
            videoView?.post = post
        }
    }
    
    //MARK: - LIFE CYCLE
    override func awakeFromNib() {
        super.awakeFromNib()
        videoView = VideoView.instanceFromNib()
        videoContainer.addSubview(videoView!)
        videoView?.addEdgeConstraints()
        setupTap()
    }
    
    func setupTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(mediaPressed))
        tap.numberOfTapsRequired = 1
        postImageView?.isUserInteractionEnabled = true
        postImageView?.addGestureRecognizer(tap)
    }
    func mediaPressed() {
        if let image = postImageView.image {
            self.delegate?.broadcastCollectionCell(sender: self, didTapAt: image)
        }
    }
    func setValues(){

        videoContainer.isHidden = !post.isVideo()

        postImageView.kf.indicatorType = .activity
        postImageView.kf.setImage(with: post.getImageUrl())
        
        if post.isVideo(){
        }else{
            //video length
        }
    }
}

//MARK: - EXTENSIONS
extension UICollectionView {
    func registerBroadcastCollectionCell() {
        let nib = UINib(nibName: "BroadcastCollectionCell", bundle: nil)
        self.register(nib, forCellWithReuseIdentifier: "BroadcastCollectionCell")
    }
    func dequeueBroadcastCollectionCell(indexpath: IndexPath) -> BroadcastCollectionCell {
        return dequeueReusableCell(withReuseIdentifier: "BroadcastCollectionCell", for: indexpath) as! BroadcastCollectionCell
    }
}
