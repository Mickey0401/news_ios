//
//  FocusImageCollectionCell.swift
//  havr
//
//  Created by Agon Miftari on 4/21/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

class FocusImageCollectionCell: UICollectionViewCell {

    @IBOutlet weak var videoImageIcon: UIImageView!
    @IBOutlet weak var productHomeImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

extension UICollectionView {
    
    func registerFocusImageCollectionCell() {
        
        let nib = UINib(nibName: "FocusImageCollectionCell", bundle: nil)
        
        self.register(nib, forCellWithReuseIdentifier: "FocusImageCollectionCell")
    }
    
    func dequeueFocusImageCollectionCell(indexpath: IndexPath) -> FocusImageCollectionCell {
        return dequeueReusableCell(withReuseIdentifier: "FocusImageCollectionCell", for: indexpath) as! FocusImageCollectionCell
    }
    
}
