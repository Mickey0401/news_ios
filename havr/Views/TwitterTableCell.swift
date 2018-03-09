//
//  TwitterTableCell.swift
//  havr
//
//  Created by Alexandr Lobanov on 12/8/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import KILabel

protocol URLLabelDelegate: class {
    func twitterCell(_ cell: TwitterTableCell, didPressUrl url: String)
    func twitterCell(_ cell: TwitterTableCell, didPressHashtag hashtag: String)
}

class TwitterTableCell: UITableViewCell {

    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var twitTextLabel: KILabel!
    @IBOutlet weak var postDateLabel: UILabel!
    
    weak var delegate: URLLabelDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clear
         separatorView.addInnerShadow(onSide: UIView.innerShadowSide.top, shadowColor: UIColor.black, shadowSize: 2, shadowOpacity: 0.25)
                separatorView.addInnerShadow(onSide: UIView.innerShadowSide.bottom, shadowColor: UIColor.black, shadowSize: 1, shadowOpacity: 0.15)
    
    }
    
    func setupWithModel(model: TweetBroadcastModel) {
        userImageView.kf.setImage(with: model.userImageUrl)
        userNameLabel.text = model.username
        postDateLabel.text = model.createDate.timeAgoSinceDate()
        twitTextLabel.text = model.text
//        twitterTagLabel.text = "@" + (model.fullname)
        twitTextLabel.urlLinkTapHandler = didTapUrl
    }
    
    func didTapUrl(_ sender: KILabel, url: String, range: NSRange) {
        delegate?.twitterCell(self, didPressUrl: url)
        print(url)
    }
}
