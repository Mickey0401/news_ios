//
//  MentionsCollectionCell.swift
//  havr
//
//  Created by Ismajl Marevci on 8/22/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

class MentionsCollectionCell: UICollectionViewCell {

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var ivPhoto: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        ivPhoto.layer.cornerRadius = 13.0
        ivPhoto.layer.borderColor = UIColor.HexToColor("#F3F6FE").cgColor
        ivPhoto.layer.borderWidth = 1.0
        ivPhoto.layer.masksToBounds = true
    }
    
}
extension UICollectionView {
    func registerMentionsCollectionCell() {
        let nib = UINib(nibName: "MentionsCollectionCell", bundle: nil)
        self.register(nib, forCellWithReuseIdentifier: "MentionsCollectionCell")
    }
    
    func dequeueMentionsCollectionCell(indexpath: IndexPath) -> MentionsCollectionCell {
        return dequeueReusableCell(withReuseIdentifier: "MentionsCollectionCell", for: indexpath) as! MentionsCollectionCell
    }
}
