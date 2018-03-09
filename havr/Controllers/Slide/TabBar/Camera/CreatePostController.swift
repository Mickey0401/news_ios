//
//  CreatePostController.swift
//  havr
//
//  Created by Arben Pnishi on 5/23/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import AWSS3
import MBProgressHUD
import AVFoundation
import Photos

class CreatePostController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var scroll: UIScrollView!
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var interestView: InterestView!
    @IBOutlet weak var captionTextView: GrowingTextView!
    
    var media: Media?
    
    var videoImage: UIImage?
    
    var player: AVPlayer?
    let post = Post()
    var isPoppingBack = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        interestView.type = .posting
        interestView.user = AccountManager.currentUser
        interestView.delegate = self
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem, queue: nil, using: { [weak self] (_) in
            DispatchQueue.main.async {
                self?.player?.seek(to: kCMTimeZero)
                self?.player?.play()
            }
        })
        captionTextView.delegate = self
//        captionTextView.enablesReturnKeyAutomatically = false
        delay(delay: 0) {
            self.interestView.interestCollection.reloadData()
        }
        if self.media?.getType() == .image {
            self.setupImage()
        } else if self.media?.getType() == .video {
            self.setupVideo()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        GA.TrackScreen(name: "Create Post")

        UIApplication.shared.isStatusBarHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        isPoppingBack = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !isPoppingBack {
            UIApplication.shared.isStatusBarHidden = false
        }

        player?.pause()
        player = nil
    }
    
    fileprivate func setupImage() {
        if let imageData = self.media?.getAssetData(), let image = UIImage(data: imageData) {
            self.imageView.image = image
            self.videoView.isHidden = true
        }
    }
    
    fileprivate func setupVideo() {
        if let videoUrl = media?.getAssetUrl() {
            player = AVPlayer(url: videoUrl)
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = self.videoView.bounds
//            playerLayer.videoGravity = AVLayerVideoGravityResize
            self.videoView.layer.addSublayer(playerLayer)
            self.imageView.isHidden = true
            player?.play()
            
            if let image = Helper.generateSnapShot(for: videoUrl) {
                self.videoImage = image
            }
        }
    }
    func createPost() {
        captionTextView.resignFirstResponder()
        showHud()
        post.title = captionTextView.text!
        PostsAPI.create(new: post) { (post, error) in
            self.hideHud()
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
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        createPost()
    }
    @IBAction func backButtonPressed(_ sender: UIButton) {
        scroll.setContentOffset(CGPoint.init(x: 0, y: 0), animated: true)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
//        self.dismiss()
        
        let alert = UIAlertController(title: "Discard Changes?", message: "Are you sure you want to discard changes?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (_) in
            self.isPoppingBack = true
            self.pop()
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (_) in
            
        }))
        
        alert.view.tintColor = Apperance.appBlueColor
        self.present(alert, animated: true, completion: nil)
        alert.view.tintColor = Apperance.appBlueColor    }
    
    fileprivate func dismiss(){
        AppDelegate.disableScreenOrientation()
        self.parent?.dismiss(animated: true, completion: nil)
    }
    
    func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            MBProgressHUD.showAlert(view: self.view)
            interestView.footerViewSaveStatus = true
        }
    }
}

extension CreatePostController {
    static func create() -> CreatePostController {
        return UIStoryboard.camera.instantiateViewController(withIdentifier: "CreatePostController") as! CreatePostController
    }
}

extension CreatePostController: InterestViewDelegate{
    func didSelect(contentType: InterestContent, interest: UserInterest?, in collectionCiew: UICollectionView, at indexPath: IndexPath) {
        switch contentType {
        case .interest(name: let name, imageUrl: let url, isSeen: let isSeen, id: let id):
            print("select interes with ID \(id)")
            post.interest = interest?.item
            collectionCiew.isUserInteractionEnabled = true
            interestView.upload(media: media!, at: indexPath.item)
        default:
            return
        }
    }
    
    
    func didSave(sender: InterestView) {
        if let imageData = self.media?.getAssetData(), let image = UIImage(data: imageData) {
            
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(CreatePostController.image(_:didFinishSavingWithError:contextInfo:)), nil)
            
        }else if media!.isVideo() {
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: self.media!.getAssetUrl())
            }) { saved, error in
                if saved {
                    delay(delay: 0, closure: { 
                        MBProgressHUD.showAlert(view: self.view)
                        sender.footerViewSaveStatus = true
                    })
                }
                if error != nil {
                    let ac = UIAlertController(title: "Save error", message: error?.localizedDescription, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(ac, animated: true)
                }
            }
        }
    }

    func didSelect(interest: UserInterest, at index: IndexPath) {
        post.interest = interest.item
        interestView.upload(media: media!, at: index.item)
    }
    
    func didUpload(media: Media?, error: ErrorMessage?, at index: Int) {
        if let media = media{
            self.media = media
            self.post.media = media
            self.scroll.setContentOffset(CGPoint.init(x: self.scroll.frame.size.width, y: 0), animated: true)
        }else{
            console("upload error: \(String(describing: error))")
        }
    }
}

extension CreatePostController: GrowingTextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            createPost()
        }
        return true
    }
    
}
