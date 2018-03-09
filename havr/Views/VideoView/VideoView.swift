//
//  VideoView.swift
//  havr
//
//  Created by Arben Pnishi on 6/27/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import SwiftyTimer
import AVFoundation

protocol VideoPlayerViewDelegate: class {
    func videoControl(sender: VideoView, didTapAt view: UIView)
    func videoControl(sender: VideoView, didPressFullScreen button: UIButton)
    func videoControl(sender: VideoView, didPressPlayPause button: UIButton)
    func videoControl(sender: VideoView, didPressVolume button: UIButton)
    func videoControl(onPlayBy sender: VideoView)
    func videoControl(onPauseBy sender: VideoView)
    func videoControl(onTimeChange time: String, sender: VideoView)
}

class VideoView: UIView {
    
    var view: UIView!
    
    //MARK: - OUTLETS
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var videoControlsView: UIView!
    @IBOutlet weak var fullscreenButton: UIButton!
    @IBOutlet weak var volumeButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var reactionImageView: UIImageView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    @IBOutlet weak var timeShadowView: UIView!
    //MARK: - VARIABLES
    weak var videoPlayerDelegate: VideoPlayerViewDelegate?
    var post: Post!{
        didSet{
            timeLabel.text = post.media.videoLength.toTimeLeftVideo(currentSeconds: 0.0)
                reactionImageView.isHidden = !post.isReaction()
        }
    }
    
    private var controls: [UIView] {
        return [playPauseButton, volumeButton, fullscreenButton, timeShadowView]
    }
    private var timer: Timer?
    private var isAnimatingControls = false
    private var observersAdded = false
    
    var firstTimePlaying = true{
        didSet{
            console("firstTimePlaying didSet")
        }
    }
    var areControlsShown = true
    var isFullScreen = false
    
    var playerTimeObserver: Any?
    
    var isMuted: Bool = false{
        didSet{
            volumeButton.isSelected = isMuted
            post.player.isMuted = isMuted
        }
    }
    
    //MARK: - LIFE CYCLE
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //        setup()
    }
    
    func setup(){
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
    func addEdgeConstraints(){
        self.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: self.superview!.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: self.superview!.bottomAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: self.superview!.leadingAnchor, constant: 0).isActive = true
        self.trailingAnchor.constraint(equalTo: self.superview!.trailingAnchor, constant: 0).isActive = true
        
        self.layoutIfNeeded()
        self.superview?.layoutIfNeeded()
        updateFrames()
    }
    
    func updateFrames() {
        if playerView == nil { return }
        
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.frame = self.superview!.bounds
        self.playerView.frame = videoView.bounds
        self.playerView.layer.frame = self.playerView.bounds
        if let layers = self.playerView.layer.sublayers{
            for layer in layers{
                layer.frame = self.playerView.bounds
            }
        }
    }
    
    func configureObservers(){
        if firstTimePlaying {
            NotificationCenter.default.addObserver(self, selector: #selector(playerFinishedPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: post.playerItem)
            NotificationCenter.default.addObserver(self, selector: #selector(playerPlaybackStalled), name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: post.playerItem)
            
            post.player.addObserver(self, forKeyPath: "status", options:NSKeyValueObservingOptions(), context: nil)
            post.player.addObserver(self, forKeyPath: "playbackBufferEmpty", options:NSKeyValueObservingOptions(), context: nil)
            post.player.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options:NSKeyValueObservingOptions(), context: nil)
            post.player.addObserver(self, forKeyPath: "playbackBufferFull", options: NSKeyValueObservingOptions(), context: nil)
            post.player.addObserver(self, forKeyPath: "loadedTimeRanges", options: NSKeyValueObservingOptions(), context: nil)
            
            observersAdded = true
            
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(viewControlsTapped(_:)))
            videoControlsView.addGestureRecognizer(tap)
            
            let swipeDown = UISwipeGestureRecognizer.init(target: self, action: #selector(fullscreenButtonPressed(_:)))
            swipeDown.direction = .down
            videoControlsView.addGestureRecognizer(swipeDown)
            
            timeLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
            timeLabel.layer.shadowOpacity = 1
            timeLabel.layer.shadowRadius = 4
            
            reactionImageView.layer.shadowOffset = CGSize(width: 0, height: 2)
            reactionImageView.layer.shadowOpacity = 1
            reactionImageView.layer.shadowRadius = 4
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if object is AVPlayerItem {
            if keyPath == "status" {
                
            }
            
            if keyPath == "playbackBufferEmpty" {
                loader.startAnimating()
                //                fullSizeVideo?.videoView.loader.startAnimating()
            }
            
            if keyPath == "playbackLikelyToKeepUp" || keyPath == "playbackBufferFull" {
                loader.stopAnimating()
                //                fullSizeVideo?.videoView.loader.stopAnimating()
            }
        }
    }
    
    func play(){
        if firstTimePlaying {
            post.playerItem = AVPlayerItem.init(url: post.media.getUrl())
            post.player.replaceCurrentItem(with: post.playerItem)
            let playerLayer = AVPlayerLayer.init(player: post.player)
            playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            if isFullScreen {
                playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
            }
            reactionImageView.isHidden = true
            playerLayer.needsDisplayOnBoundsChange = true

            playerLayer.frame = playerView.bounds
            playerLayer.backgroundColor = UIColor.black.cgColor
            playerView.layer.addSublayer(playerLayer)
            post.player.seek(to: kCMTimeZero)
            post.player.play()
            
            configureObservers()
            
            firstTimePlaying = false
        }else{
            post.player.play()
            reactionImageView.isHidden = true
        }
        
        let interval = CMTime.init(value: 1, timescale: 2)
        playerTimeObserver = post.player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [unowned self] time in
            let timeLeft = self.post.media.videoLength.toTimeLeftVideo(currentSeconds: CMTimeGetSeconds(time))
            self.videoPlayerDelegate?.videoControl(onTimeChange: timeLeft, sender: self)
        }
    }
    
    func pause(){
        console("video paused")
        post.player.pause()
        self.videoPlayerDelegate?.videoControl(onPauseBy: self)
        if let pto = playerTimeObserver{
            post.player.removeTimeObserver(pto)
            playerTimeObserver = nil
        }
        reactionImageView.isHidden = false
    }
    
    func reset(){
        pause()
        post.player.seek(to: kCMTimeZero)
        playPauseButton.isSelected = false
        timeLabel.text = post.media.videoLength.toTimeLeftVideo(currentSeconds: 0.0)
        setControls(hidden: false)
        firstTimePlaying = true
        playPauseButton.alpha = 1
    }
    
    func destroy(){
        deallocObservers(player: post.player)
        firstTimePlaying = true
        post.playerItem = nil
        playerView.layer.sublayers?.removeAll()
        post.player.pause()
    }
    
    fileprivate func deallocObservers(player: AVPlayer) {
        if let pto = playerTimeObserver{
            self.post.player.removeTimeObserver(pto)
        }
        if observersAdded {
            player.removeObserver(self, forKeyPath: "status")
            player.removeObserver(self, forKeyPath: "playbackBufferEmpty")
            player.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
            player.removeObserver(self, forKeyPath: "playbackBufferFull")
            player.removeObserver(self, forKeyPath: "loadedTimeRanges")
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    func playerFinishedPlaying() {
        post.player.seek(to: kCMTimeZero)
        post.player.play()
    }
    func playerPlaybackStalled() {
        loader.startAnimating()
    }
    func changeControlsState(){
        setControls(hidden: areControlsShown)
    }
    
    func setControls(hidden: Bool) {
        if isAnimatingControls {
            return
        }
        isAnimatingControls = true
        for item in self.controls {
            UIView.animate(withDuration: 0.15, animations: {
                if item == self.playPauseButton && hidden{
                    if self.post.player.isPlaying{
                        item.alpha = hidden ? 0 : 1
                    }
                }else{
                    item.alpha = hidden ? 0 : 1
                }
            }, completion: { (completed) in
                self.isAnimatingControls = false
                self.areControlsShown = !hidden
            })
        }
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        return UINib(nibName: "VideoView", bundle: bundle).instantiate(withOwner: self, options: nil)[0] as! UIView
    }
    
    @IBAction func playPauseButtonPressed(_ sender: UIButton) {
        sender.bubble()
        sender.isSelected = !sender.isSelected
        
        if isFullScreen && firstTimePlaying {
            self.videoPlayerDelegate?.videoControl(onPlayBy: self)
        }else{
            self.videoPlayerDelegate?.videoControl(sender: self, didPressPlayPause: sender)
        }
        if firstTimePlaying {
            delay(delay: 0, closure: {
                self.loader.startAnimating()
            })
        }
        startTimer(sender.isSelected ? 1.0 : 3)
    }
    @IBAction func fullscreenButtonPressed(_ sender: UIButton) {
        isFullScreen = !isFullScreen
        var playerLayer: AVPlayerLayer? = nil
        
        if let layers = self.playerView.layer.sublayers{
            for layer in layers{
                if layer is AVPlayerLayer{
                    playerLayer = layer as? AVPlayerLayer
                }
                layer.frame = self.playerView.bounds
            }
        }
        fullscreenButton.isHidden = !isFullScreen

        if isFullScreen {
//            fullscreenButton.setImage(#imageLiteral(resourceName: "minimize screen button"), for: .normal)
            playerLayer?.videoGravity = AVLayerVideoGravityResizeAspect
        }else{
//            fullscreenButton.setImage(#imageLiteral(resourceName: "full screen button"), for: .normal)
            playerLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            AppDelegate.disableScreenOrientation()
        }
        
        if post.player.isPlaying {
            if !firstTimePlaying {
                startTimer()
            }else{
                if isFullScreen {
                    self.backgroundColor = .black
                }else{
                    self.backgroundColor = .clear
                }
            }
        }
        self.videoPlayerDelegate?.videoControl(sender: self, didPressFullScreen: sender)
    }
    @IBAction func volumeButtonPressed(_ sender: UIButton) {
        sender.bubble(scale: 1.4, with: 0.15)
        startTimer()
        sender.isSelected = !sender.isSelected
        self.videoPlayerDelegate?.videoControl(sender: self, didPressVolume: sender)
    }
    @IBAction func viewControlsTapped(_ sender: UITapGestureRecognizer) {
        if !firstTimePlaying {
            invalidateTimer()
            if !areControlsShown {
                startTimer()
            }
            changeControlsState()
        }
        
        self.videoPlayerDelegate?.videoControl(sender: self, didTapAt: videoControlsView)
    }
    
    private func invalidateTimer(){
        timer?.invalidate()
        timer = nil
    }
    
    func startTimer(_ interval: TimeInterval = 3){
        invalidateTimer()
        timer = Timer.after(interval, {
            self.setControls(hidden: true)
        })
    }
    
    class func instanceFromNib() -> VideoView {
        return UINib(nibName: "VideoView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! VideoView
    }
}

extension VideoView{
    static func == (lhs:VideoView, rhs:VideoView) -> Bool{
        return lhs.post.id == rhs.post.id
    }
}
