//
//  VoiceTableCell.swift
//  havr
//
//  Created by Ismajl Marevci on 8/22/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox
import SwiftyTimer

typealias MyTimer = SwiftyTimer.Timer

protocol VoiceTableCellDelegate: class {
    func voiceTableCell(sender: VoiceTableCell, didPressPlay button: UIButton, with media: Media)
    func voiceTableCell(sender: VoiceTableCell, didPressRetry button: UIButton)

}

class VoiceTableCell: UITableViewCell {
    
    //MARK: - OUTLETS
    @IBOutlet weak var waveView: UIView! // w: 123 h: 25
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var progressConstraint: NSLayoutConstraint!
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var rightImageView: UIImageView!
    
    var sound: Sound?
    
    var timer: Timer?
    //MARK: - VARIABLES
    weak var delegate: VoiceTableCellDelegate?
    var audioPlayer = AVAudioPlayer()
    var isPlaying: Bool = false {
        didSet {
            playButton.setImage(isPlaying ? #imageLiteral(resourceName: "recordPause icon") : #imageLiteral(resourceName: "recordPlay icon"), for: UIControlState())
        }
    }
    var wave: WaveformView?
    var message: Message! {
        didSet {
            setValues()
        }
    }
    
    //MARK: - LIVE CYCLE
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupShadow()
        forceIncreaseVolumeInPlayer()
        
        NotificationCenter.default.addObserver(self, selector: #selector(stopAudio), name: Sound.stopNotificationName, object: nil)
    }
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        playButton.backgroundColor = UIColor.clear
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        playButton.backgroundColor = UIColor.clear
    }
    // MARK: Set Volume On, even in mute mode
    func forceIncreaseVolumeInPlayer(){
        //try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: [])
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            //print("AVAudioSession Category Playback OK")
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                //print("AVAudioSession is Active")
            } catch _ as NSError {
                //print(error.localizedDescription)
            }
        } catch _ as NSError {
            //print(error.localizedDescription)
        }
    }
    func setupShadow() {
        shadowView.shadowColor = UIColor.init(red255: 208, green255: 208, blue255: 208)
        shadowView.shadowOpacity = 0.6
        shadowView.shadowOffset = CGSize.zero
        shadowView.shadowRadius = 4.0
        shadowView.masksToBounds =  false
        
        loadingActivityIndicator.hide()
        
        
        wave = WaveformView.init(frame: CGRect(x: 0, y: 0, width: 120, height: 10))
        wave?.barColor = Apperance.B5B5B5Color
        wave?.barSize = CGSize(width: 3.0, height: 25.0)
        wave?.barVerticalAlignment = .bottom
        wave?.maximumBarAnimationDuration = 0.90
        wave?.barSpacing = CGFloat(3.0)
        
        waveView.addSubview(wave!)
        delay(delay: 0) {
            self.wave?.startAnimating()
            delay(delay: 0.05, closure: {
                self.wave?.stopAnimating()
            })
        }
        waveView.layoutSubviews()
    }
    
    fileprivate func setValues() {
        
        if let message = message {
            durationLabel.text = message.media.videoLength.toTimeLeftVideo(currentSeconds: 0.0)
            timeLabel.text = message.getTime()

            
            switch message.messageStatus {
            case .created, .sending:
                self.rightImageView?.isHidden = true
                self.retryButton?.isHidden = true
                self.rightImageView?.image = Constants.defaultSentMessageGrayImage
            case .sent:
                self.rightImageView?.isHidden = false
                self.retryButton?.isHidden = true
                self.rightImageView?.image = Constants.defaultSentMessageGrayImage
                
            case .failed:
                self.retryButton?.isHidden = false
                self.rightImageView?.image = Constants.defaultSentMessageGrayImage
            }
            
            if message.isSeen {
                self.rightImageView?.image = Constants.defaultSeenMessageBlueImage
            }
 
            
        }
    }
    
    func stopAudio() {
        wave?.stopAnimating()

        sound?.stop()
        isPlaying = false
        message.media?.cancelDownload()
    }
    
    //MARK: - ACTIONS
    @IBAction func retryButtonPressed(_ sender: UIButton) {
        self.delegate?.voiceTableCell(sender: self, didPressRetry: sender)
    }
    @IBAction func playButtonClicked(_ sender: UIButton) {
        sender.backgroundColor = UIColor.clear
        guard let media = message.media else { return  }
        if !media.isAudio() { return }
        
        if isPlaying {
            stopAudio()
            return
        }
        
        if media.existsInAssets {
            self.playButton.isHidden = false
            loadingActivityIndicator.hide()
            self.play()
            
        } else {
            self.playButton.isHidden = true
            loadingActivityIndicator.show()
            media.download(completion: { [weak self] (success, error) in
                
                guard let `self` = self else { return }
                
                self.playButton.isHidden = false
                self.loadingActivityIndicator.hide()
                if success {
                    self.play()
                }
            }, progress: { (progress) in
                print("Download Progress: \(progress)")
            })
        }
    }
    
    fileprivate func play() {
        guard let media = message.media else { return  }
        
        Sound.stopAll()
        let url = media.getAssetUrl()
        isPlaying = true
        
        sound = Sound(url: url)
        wave?.startAnimating()

        sound?.play(numberOfLoops: 0, completion: {[weak self] (finished) in
            guard let `self` = self else { return }
            
            self.isPlaying = false
            self.wave?.stopAnimating()
        })
        /*
        let interval: TimeInterval = 1.0
        
        timer = Timer.every(interval, { [weak self] in
            guard let `self` = self else {
                return
            }
            
            if !self.isPlaying {
                self.timer?.invalidate()
                
                return
            }
            
            let length = self.message.media.videoLength
         
        })
        */
    }
}
extension UITableView {
    func registerReceiverVoiceTableCell() {
        let nib = UINib(nibName: "ReceiverVoiceTableCell", bundle: nil)
        self.register(nib, forCellReuseIdentifier: "ReceiverVoiceTableCell")
    }
    func registerSenderVoiceTableCell() {
        let nib = UINib(nibName: "SenderVoiceTableCell", bundle: nil)
        self.register(nib, forCellReuseIdentifier: "SenderVoiceTableCell")
    }
    
    func dequeueVoiceTableCell(identifier: String, indexPath: IndexPath) -> VoiceTableCell {
        return self.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! VoiceTableCell
    }
}
