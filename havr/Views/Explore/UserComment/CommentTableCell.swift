//
//  CommentTableCell.swift
//  havr
//
//  Created by Ismajl Marevci on 5/2/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit


class CommentTableCell: UITableViewCell {

    @IBOutlet weak var commentLabel: MentionLabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let customType = ActiveType.custom(pattern: "([^\\s]+)")
        commentLabel.enabledTypes = [.mention]
        
        commentLabel.customColor[customType] = UIColor.red
        commentLabel.customSelectedColor[customType] = UIColor.red
        usernameLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        usernameLabel.numberOfLines = 0
        selectionStyle = .none
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var comment: Comment! {
        didSet {
            setValues()
        }
    }
    
    fileprivate func setValues() {
        let value = "\(comment.user.username)   \(comment.text) "
//        commentLabel.setComment(title: comment.user.username, subTitle: comment.text)
        commentLabel.textColor = UIColor.black.withAlphaComponent(1)
        //commentLabel.font = UIFont.sfProTextRegularFont(14)
        
        usernameLabel.text = comment.user.username
        usernameLabel.sizeToFit()
        usernameLabel.adjustsFontSizeToFitWidth = true
        usernameLabel.textAlignment = .center
        commentLabel.text  = comment.text
        //commentLabel.attributedText = myMutableString
    }
}
extension UITableView {
    func dequeueCommentTableCell(index: IndexPath) -> CommentTableCell {
        return self.dequeueReusableCell(withIdentifier: "CommentTableCell", for: index) as! CommentTableCell
    }
    
    func registerCommentTableCell() {
        let nib = UINib(nibName: "CommentTableCell", bundle: nil)
        self.register(nib, forCellReuseIdentifier: "CommentTableCell")
    }
}
