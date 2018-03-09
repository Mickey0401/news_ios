//
//  VideoReactionController.swift
//  havr
//
//  Created by Agon Miftari on 4/25/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import QuartzCore

class VideoReactionController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var shootButton: UIButton!
    @IBOutlet weak var myCameraImageView: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var doneButton: UIButton!
    
    var post : Post!
    var media: Media {
        return post.media
    }
    
    var statusBarHidden: Bool = false
    var player: AVPlayer?
    var resourceIsReady: Bool = false
    var isShootingVideo : Bool = false {
        didSet {
            if isShootingVideo != oldValue {
                UIView.animate(withDuration: 0.3, animations: { 
                    if (self.isShootingVideo) {
                        self.shootButton.isSelected = true
//                        self.doneButton.isHidden = false
                    }
                    else {
                        self.shootButton.isSelected = false
                        self.backButton.isHidden = false
                        self.doneButton.sendActions(for: .touchUpInside)
                    }
                })
            }
        }
    }
    
    lazy var cameraManager : CameraManager = {
        let m = CameraManager()
        m.writeFilesToPhoneLibrary = false
        m.shouldRespondToOrientationChanges = true
        m.cameraDevice = .front
        return m
    }()
    
    var tap : UITapGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GA.TrackScreen(name: "Reaction")

        setValues()
        setupDoubleTap()
        _ = cameraManager.addPreviewLayerToView(myCameraImageView, newCameraOutputMode: .videoWithMic, completition: nil)
        
        prepareResources()
        checkForOrientation()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        if media.isLandscape{
            return UIInterfaceOrientationMask(rawValue: UInt(UIInterfaceOrientation.landscapeLeft.rawValue))
        }
        return UIInterfaceOrientationMask(rawValue: UInt(UIInterfaceOrientation.portrait.rawValue))
    }
    
    override var shouldAutorotate: Bool{
        return false
    }
    
    func checkForOrientation(){
        if media.isLandscape{
            AppDelegate.enableScreenOrientationOnlyForLandscape()
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
            VideoReactionController.attemptRotationToDeviceOrientation()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        self.navigationController?.setNavigationBarHidden(true, animated: true)
        UIApplication.shared.isStatusBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        UIApplication.shared.isStatusBarHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @IBAction func shootButtonPressed(_ sender: UIButton) {
        
        if !resourceIsReady { return }
        
        if media.isVideo() {
            self.player?.play()
        }
        
        isShootingVideo = !isShootingVideo
        cameraManager.startRecordingVideo()
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        
        isShootingVideo = false
        doneButton.isHidden = true
        player?.pause()
        player?.seek(to: kCMTimeZero)
        
        cameraManager.stopRecordingVideo({ (videoUrl, error) in
            if let videoUrl = videoUrl, let media = Media.create(video: videoUrl) {
                let videoReviewVC = VideoReviewController.create(media: media)
                videoReviewVC.post = self.post
                self.push(videoReviewVC)
            }
        })
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        AppDelegate.disableScreenOrientation()
        self.hideModal()
    }
    
    func setupDoubleTap() {
        tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tap?.delegate = self
        tap?.numberOfTapsRequired = 2
        self.myCameraImageView.isUserInteractionEnabled = true
        self.myCameraImageView.addGestureRecognizer(tap!)
    }
    
    func setValues() {
        videoImageView.kf.setImage(with: post.getImageUrl())
    }
    
    func handleTap() {
        
        if cameraManager.cameraDevice == .front {
            cameraManager.cameraDevice = .back
        }else {
            cameraManager.cameraDevice = .front
        }
    }
    
    fileprivate func prepareResources() {
        self.showHud()
        self.shootButton.isEnabled = false
        if media.isVideo() {
            
            media.download(completion: {[weak self] (success, error) in
                guard let `self` = self else { return }
                
                self.hideHud()
                if success {
                    print("Resource downloaded")
                    self.shootButton.isEnabled = true
                    self.resourceIsReady = true
                    self.showVideoResource()
                    
                }
            }) { (downloadedProgress) in
                print("Download Progress: \(downloadedProgress)")
            }
        } else {
            videoImageView.kf.setImage(with: media.getImageUrl(), placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, error, cache, source) in
                self.hideHud()
                if let image = image {
                    OfflineFileManager.store(object: image.kf.jpegRepresentation(compressionQuality: Constants.imageCompressionRation)!, at: self.media.getAssetUrl())
                    
                    self.resourceIsReady = true
                    self.shootButton.isEnabled = true
                } else {
                    self.shootButton.isEnabled = false
                }
            })
        }
    }

    deinit {
        media.cancelDownload()
        print("Deinit VideoReaction Controller")
    }
    
    fileprivate func showVideoResource() {
        self.player = AVPlayer(url: self.media.getAssetUrl())
        let playerLayer = AVPlayerLayer(player: self.player)
        DispatchQueue.main.async {
            playerLayer.frame = self.videoImageView.bounds
//            playerLayer.backgroundColor = UIColor.black.cgColor
//            if self.media.isLandscape{
//                playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
//            }else{
//                playerLayer.videoGravity = AVLayerVideoGravityResize
//            }
            self.videoImageView.layer.addSublayer(playerLayer)
        }
    }
    
    fileprivate func showPictureResource() {
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if let sublayers = self.videoImageView.layer.sublayers{
            for layer in sublayers{
                layer.frame = CGRect.init(origin: CGPoint.zero, size: size)
            }
        }
    }
}

extension VideoReactionController {
    static func create(for post: Post) -> VideoReactionController {
        var identifier = "VideoReactionController"
        if post.media.isLandscape{
            identifier = "VideoReactionControllerLandscape"
        }
        let controller =  UIStoryboard.reaction.instantiateViewController(withIdentifier: identifier) as! VideoReactionController
        
        controller.post = post
        return controller
    }
}
