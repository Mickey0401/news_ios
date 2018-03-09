//
//  VideoViewController.swift
//  havr
//
//  Created by Yuriy G. on 1/21/18.
//  Copyright © 2018 Tenton LLC. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Photos

class VideoPlayViewController: UIViewController {
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private var videoURL                : URL
    fileprivate var filterView          : SCSwipeableFilterView!,
                    player              : SCPlayer!
    
    init(videoURL: URL) {
        self.videoURL = videoURL
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.view.backgroundColor = UIColor.white
        filterView = SCSwipeableFilterView()
        filterView.contentMode = .scaleAspectFit
        view.addSubview(filterView)
        
        player = SCPlayer.init()
       
        filterView.filters = [SCFilter.empty()]
        
        player.scImageView = filterView
        player.loopEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        player.setItemBy(videoURL)

        player?.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player.pause()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard self.isViewLoaded else {
            return
        }
        
        filterView.setNeedsDisplay()
        filterView.frame = view.frame
    }
    
    public func getMedia(_ completion: @escaping ((Media?) -> Void)) {
        Helper.exportVideo(sourceUrl: videoURL) { (media) in
            if let media = media {
                completion(media)
            } else {
                completion(nil)
            }
        }
    }
    
    @objc fileprivate func playerItemDidReachEnd(_ notification: Notification) {
        if self.player != nil {
            self.player!.seek(to: kCMTimeZero)
            self.player!.play()
        }
    }
    
    func saveCameraRoll(_ completion: @escaping ((Bool) -> Void)) {
        let url = videoURL as NSURL
        self.showHud()
        url.saveToCameraRoll(completion: { (path, error) in
            self.hideHud()
            print(error.debugDescription)
            let alert : UIAlertController = UIAlertController(title: "Video Saved", message: nil, preferredStyle: .alert)
            
            let cancelActionButton: UIAlertAction = UIAlertAction(title: "Ok", style: .cancel) { action -> Void in
                alert.dismiss(animated: true, completion: nil)
                completion(true)
            }
            alert.addAction(cancelActionButton)
            self.present(alert, animated: true, completion: nil)
        })
        
    }
}
