//
//  InterestListCollectionCell.swift
//  havr
//
//  Created by Ismajl Marevci on 6/7/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

class InterestListCollectionCell: UICollectionViewCell {
    @IBOutlet weak var isActiveView: UIView!
    
    @IBOutlet weak var interestBackgroundView: UIView!
    @IBOutlet weak var interestNameLabel: UILabel!
    @IBOutlet weak var interestImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
extension UICollectionView {
    func registerInterestListCollectionCell() {
        let nib = UINib(nibName: "InterestListCollectionCell", bundle: nil)
        
        self.register(nib, forCellWithReuseIdentifier: "InterestListCollectionCell")
    }
    
    func dequeueInterestListCollectionCell(indexpath: IndexPath) -> InterestListCollectionCell {
        return dequeueReusableCell(withReuseIdentifier: "InterestListCollectionCell", for: indexpath) as! InterestListCollectionCell
    }
}
