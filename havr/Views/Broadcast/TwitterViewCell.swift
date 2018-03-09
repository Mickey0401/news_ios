//
//  TwitterViewCell.swift
//  havr
//
//  Created by CloudStream on 2/13/18.
//  Copyright © 2018 Tenton LLC. All rights reserved.
//

import TwitterKit
import UIKit

class TwitterViewCell: UITableViewCell, TWTRTweetViewDelegate{
    @IBOutlet weak var customTweetView: TWTRTweetView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var shadowView: UIView!
    
    weak var delegate: URLLabelDelegate?
    var tweetObj: TWTRTweet? = nil
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.clear
        separatorView.addInnerShadow(onSide: UIView.innerShadowSide.top, shadowColor: UIColor.black, shadowSize: 2, shadowOpacity: 0.25)
        separatorView.addInnerShadow(onSide: UIView.innerShadowSide.bottom, shadowColor: UIColor.black, shadowSize: 1, shadowOpacity: 0.15)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func configureCell(with tweet: TWTRTweet){
        self.customTweetView.showActionButtons = false
        tweetObj = tweet
        self.customTweetView.configure(with: tweet)
        self.customTweetView.delegate = self
    }
    
    // MARK:- TWTRTweetViewDelegate
    func tweetView(_ tweetView: TWTRTweetView, didTap url: URL) {
        if (delegate != nil) {
            delegate?.twitterCell(TwitterTableCell(), didPressUrl: url.absoluteString)
        }
    }
    
    func tweetView(_ tweetView: TWTRTweetView, didTap tweet: TWTRTweet) {
        if (delegate != nil) {
            delegate?.twitterCell(TwitterTableCell(), didPressUrl: tweet.permalink.absoluteString)
        }
    }
    
    func tweetView(_ tweetView: TWTRTweetView, didTap image: UIImage, with imageURL: URL) {
        if (delegate != nil && tweetObj != nil) {
            delegate?.twitterCell(TwitterTableCell(), didPressUrl: tweetObj!.permalink.absoluteString)
        }
    }
    
    func tweetView(_ tweetView: TWTRTweetView, didTapProfileImageFor user: TWTRUser) {
        if (delegate != nil) {
            delegate?.twitterCell(TwitterTableCell(), didPressUrl: tweetObj!.permalink.absoluteString)
        }
    }
}
