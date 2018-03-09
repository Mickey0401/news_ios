//
//  VideoReviewController.swift
//  havr
//
//  Created by Agon Miftari on 6/21/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MBProgressHUD

class VideoReviewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var myReactionImageView: UIImageView!
    
    var post : Post!
    var player: AVPlayer?
    var createdMedia: Media!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GA.TrackScreen(name: "Reaction Result")

        setupValues()
        // Do any additional setup after loading the view.

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        UIApplication.shared.isStatusBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        UIApplication.shared.isStatusBarHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        prepareVideo()
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem, queue: nil, using: { [weak self] (_) in
            DispatchQueue.main.async {
                self?.player?.seek(to: kCMTimeZero)
                self?.player?.play()
            }
        })
    }
    
    func setupValues() {
    }

    @IBAction func backButtonPressed(_ sender: UIButton) {
        OfflineFileManager.remove(with: createdMedia.getAssetUrl())
        OfflineFileManager.remove(with: createdMedia.getImageAssetUrl())
        self.pop()
    }

    @IBAction func sendButtonPressed(_ sender: UIButton) {
        sender.isEnabled = false
        showHud()
        createdMedia.upload(deleteOnUpload: true, completion: { (media, success, error) in
            if success{
                let newPost = Post()
                newPost.media = media
                self.create(post: newPost, sender: sender)
            }else{
                sender.isEnabled = true
                self.hideHud()
                MBProgressHUD.showWithStatus(view: self.view, text: error ?? "Post could not be uploaded!", image: #imageLiteral(resourceName: "ERROR"))
            }
        }) { (progress) in
            console("upload progress: \(progress)")
        }
    }
    
    fileprivate func create(post: Post, sender: UIButton) {
        delay(delay: 0) { 
            self.textField.resignFirstResponder()
            self.view.endEditing(true)
        }
        post.title = textField.text!
        post.interest?.id = 51 // id of reactions interest
        PostsAPI.create(new: post) { (post, error) in
            
            self.hideHud()
            sender.isEnabled = true
            
            if let post = post{
                console("post: \(post.id)")
                MBProgressHUD.showWithStatus(view: self.view, text: "Posted", image: #imageLiteral(resourceName: "SUCCESS"))
                
                self.slideController.profile.unfilteredPosts.insert(post, at: 0)
                CacheManager.write {
                    self.slideController.profile.user?.stats?.posts += 1
                }
                self.slideController.profile.collectionView.reloadData()
                
                delay(delay: 0.3, closure: {
                    self.dismiss()
                })
            }else{
                console("error: \(String(describing: error))")
                MBProgressHUD.showWithStatus(view: self.view, text: error!.message, image: #imageLiteral(resourceName: "ERROR"))
            }
        }
    }
    
    fileprivate func dismiss(){
        AppDelegate.disableScreenOrientation()

        self.player?.pause()
        self.player = nil
        self.parent?.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func prepareVideo() {
        guard let media = createdMedia else { self.pop(); return }
        self.showHud()

        if post.media.isVideo() {
            let videoEditor = VideoEditor(recorded: media)
                        
            videoEditor.create(video: post.media) { (mergeMedia) in
                self.hideHud()

                if let mergeMedia = mergeMedia {
                    
                    if let newMedia = Media.create(video: mergeMedia.getAssetUrl()) {
                        self.createdMedia = newMedia
                    }
                    
                    DispatchQueue.main.async {
                        self.player = AVPlayer(url: mergeMedia.getAssetUrl())
                        let playerLayer = AVPlayerLayer(player: self.player)
                        playerLayer.frame = self.myReactionImageView.bounds
                        playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
                        self.myReactionImageView.layer.addSublayer(playerLayer)
                        self.player?.play()
                    }
                } else {
                    Helper.show(alert: "Something went wrong while creating your reaction.")
                    self.pop()
                }
            }
        } else {
            let videoEditor = VideoEditor(recorded: media)
            videoEditor.create(image: post.media, completion: { (media) in
                self.hideHud()
                
                if let mergeMedia = media {
                    DispatchQueue.main.async {
                        self.player = AVPlayer(url: mergeMedia.getAssetUrl())
                        let playerLayer = AVPlayerLayer(player: self.player)
                        playerLayer.frame = self.myReactionImageView.bounds
                        playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
                        self.myReactionImageView.layer.addSublayer(playerLayer)
                        self.player?.play()
                    }
                } else {
                    Helper.show(alert: "Something went wrong while creating your reaction.")
                    self.pop()
                }
            })
        }
    }

}


extension VideoReviewController {
    
    static func create(media: Media) -> VideoReviewController {
        let controller =  UIStoryboard.reaction.instantiateViewController(withIdentifier: "VideoReviewController") as! VideoReviewController
        controller.createdMedia = media
        return controller
    }
}
