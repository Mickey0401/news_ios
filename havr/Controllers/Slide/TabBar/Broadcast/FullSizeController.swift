//
//  FullSizeController.swift
//  havr
//
//  Created by Ismajl Marevci on 6/28/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import AVFoundation

class FullSizeController: UIViewController {
    
    @IBOutlet weak var postImageView: UIImageView!
    private var didLayoutSubviews = false
    var videoView: VideoView!
    
    var post: Post!
    var player: AVPlayer!{
        didSet{
            let playerLayer = AVPlayerLayer.init(player: player)
            playerLayer.frame = view.bounds
            videoView.playerView.layer.addSublayer(playerLayer)
            player.seek(to: player.currentTime())
            
            videoView.isMuted = player.isMuted
            videoView.playPauseButton.isSelected = player.isPlaying
            if player.isPlaying {
                videoView.startTimer()
            }
//            videoView.isFullScreen = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        commonInit()
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        GA.TrackScreen(name: "Full Size Video")

        AppDelegate.enableScreenOrientation()
//        videoView.fullscreenButton.isHidden = false
        UIApplication.shared.setStatusBarHidden(true, with: .fade)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(false)
        AppDelegate.disableScreenOrientation()
        UIApplication.shared.setStatusBarHidden(false, with: .fade)
//        videoView.fullscreenButton.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !didLayoutSubviews {
            
            didLayoutSubviews = true
            self.view.addSubview(videoView)
            videoView.addEdgeConstraints()
        }
    }
    func commonInit(){
        if let image = post.getImageUrl() {
            postImageView.kf.setImage(with: image)
        }
        
//        videoView.videoPlayerDelegate = self
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.videoView.frame = CGRect.init(origin: CGPoint.zero, size: size)
        
        self.videoView.playerView.frame = videoView.bounds
        self.videoView.playerView.layer.frame = self.videoView.playerView.bounds
        if let layers = self.videoView.playerView.layer.sublayers{
            for layer in layers{
                layer.frame = self.videoView.playerView.bounds
            }
        }
//        self.videoView.updateFrames()
        self.view.layoutIfNeeded()
        //        self.videoView.set()
    }
    
}

//MARK: - EXTENSIONS
extension FullSizeController {
    static func create() -> FullSizeController {
        return UIStoryboard.broadcast.instantiateViewController(withIdentifier: "FullSizeController") as! FullSizeController
    }
}

extension FullSizeController: VideoPlayerViewDelegate{
    func videoControl(sender: VideoView, didTapAt view: UIView){
        console("didTapAt")
    }
    
    func videoControl(sender: VideoView, didPressFullScreen button: UIButton){
//        self.hideModal()
//        videoView.destroy()
        console("didPressFullScreen")
    }
    
    func videoControl(sender: VideoView, didPressPlayPause button: UIButton){
        console("didPressPlayPause")
        button.isSelected = !button.isSelected
    }
    
    func videoControl(sender: VideoView, didPressVolume button: UIButton){
        console("didPressVolume")
        button.isSelected = !button.isSelected
    }
    
    func videoControl(onPlayBy sender: VideoView) {
        
    }
    
    func videoControl(onPauseBy sender: VideoView) {
        
    }
    
    func videoControl(onTimeChange time: String, sender: VideoView) {
        
    }
}
