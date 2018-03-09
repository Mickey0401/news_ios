//
//  EventsCollectionCell.swift
//  havr
//
//  Created by Ismajl Marevci on 6/30/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import AVKit

protocol EventsCollectionCellDelegate: class {
    func eventsCollectionCell(sender: EventsCollectionCell, isTouching: Bool)
    func eventsCollectionCell(sender: EventsCollectionCell, isLoading: Bool)
    func eventsCollectionCell(sender: EventsCollectionCell, didTapForward forward: Bool)
}

class EventsCollectionCell: UICollectionViewCell {
    
    static var touchSpanPeriod: TimeInterval = 0.05
    static var separationWidth: CGFloat = 0.35 //width from left

    var event: EventPost! {
        didSet {
            setValues()
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var touchButton: UIButton!
    
    weak var delegate: EventsCollectionCellDelegate?
    
    fileprivate var player: AVPlayer!
    
    fileprivate var playerLayer: AVPlayerLayer!
    
    fileprivate var touchStartTime: Date!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func changePlayerStatus(paused: Bool) {
        if paused {
            self.player?.pause()
        } else {
            self.player?.play()
        }
    }
    
    @IBAction func touchButtonDown(_ sender: UIButton) {
        touchStartTime = Date()
        
        guard let media = self.event?.media else { return }
        
        if media.isGif() || media.isImage() {
          
            if imageView.image == nil { return }
            
            self.delegate?.eventsCollectionCell(sender: self, isTouching: true)
            return
        }
        
        if media.isVideo() {
            if player == nil { return }
            
            if player.currentItem == nil { return }
            
            if player.isPlaying {
                self.player?.pause()
                self.delegate?.eventsCollectionCell(sender: self, isTouching: true)
            }
        }
    }
    @IBAction func touchButtonOpInside(_ sender: UIButton, forEvent event: UIEvent) {
        let period = abs(touchStartTime.timeIntervalSinceNow)
        
        if period < EventsCollectionCell.touchSpanPeriod {
            
            changePost(sender: sender, event: event)
            return
        }
        print("Hold Period: \(period)")
        
        
        guard let media = self.event?.media else { return }
        
        if media.isGif() || media.isImage() {
            
            if imageView.image == nil { return }
            
            self.delegate?.eventsCollectionCell(sender: self, isTouching: true)
            return
        }
        
        if media.isVideo() {
            self.player?.play()
            self.delegate?.eventsCollectionCell(sender: self, isTouching: false)
        }
    }
    
    fileprivate func setValues() {
        if event.hasMedia, let media = event.media, media.isImage() || media.isGif() {
            imageView.kf.indicatorType = .activity
            loadingActivityIndicator.hide()
            imageView.kf.setImage(with: media.getImageUrl(), placeholder: nil, options: nil, progressBlock: { (value, total) in
                self.delegate?.eventsCollectionCell(sender: self, isLoading: true) //pause while image is downloading
            }, completionHandler: { (image, error, cache, url) in
                self.delegate?.eventsCollectionCell(sender: self, isLoading: false) //play when image is downloaded
            })
            
            removeAndStop()
        }
        
        if event.hasMedia, let media = event.media, media.isVideo() {
            imageView.image = nil
            self.delegate?.eventsCollectionCell(sender: self, isLoading: true)
            if media.existsInAssets {
                self.playVideo()
            } else {
                loadingActivityIndicator.show()
                media.download(completion: {[weak self] (success, error) in
                    guard let `self` = self else { return }
                    if success {
                        self.playVideo()
                    }
                }, progress: { (progress) in
                    self.delegate?.eventsCollectionCell(sender: self, isLoading: true)
                })
            }
        }
    }
    
    fileprivate func playVideo() {
        guard let media = self.event?.media, media.isVideo() && media.existsInAssets else { return }
        
        loadingActivityIndicator.hide()
        removePlayerFromAnyView()
        
        player = AVPlayer(url: media.getAssetUrl())
        
        NotificationCenter.default.addObserver(self, selector:#selector(playerDidFinishPlaying),name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.bounds
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
        self.imageView.layer.addSublayer(playerLayer)
        
        player.play()
        
        delegate?.eventsCollectionCell(sender: self, isLoading: false)
    }
    
    fileprivate func removePlayerFromAnyView() {
        player?.pause()
        player = nil
        
        playerLayer?.player = nil
        playerLayer?.removeFromSuperlayer()
    }
    
    func removeAndStop() {
        removePlayerFromAnyView()
        NotificationCenter.default.removeObserver(self)
        event?.media?.cancelDownload()
    }
    
    func playerDidFinishPlaying(notification: Notification) {
        removePlayerFromAnyView()
    }
    
    fileprivate func changePost(sender: UIButton, event: UIEvent) {
        guard let touch = event.allTouches?.first else { return }
        
        let point = touch.location(in: sender)
        let positionX = point.x
        let viewWidth = sender.frame.width
        
        let separateWidth = viewWidth * EventsCollectionCell.separationWidth
        
        if positionX > separateWidth {
            self.delegate?.eventsCollectionCell(sender: self, didTapForward: true)
        } else {
            self.delegate?.eventsCollectionCell(sender: self, didTapForward: false)
        }
    }
    deinit {
        removeAndStop()
    }
    
}

extension UICollectionView {
    func registerEventsCollectionCell() {
        let nib = UINib(nibName: "EventsCollectionCell", bundle: nil)
        self.register(nib, forCellWithReuseIdentifier: "EventsCollectionCell")
    }
    
    func dequeueEventsCollectionCell(indexpath: IndexPath) -> EventsCollectionCell {
        return dequeueReusableCell(withReuseIdentifier: "EventsCollectionCell", for: indexpath) as! EventsCollectionCell
    }
}
