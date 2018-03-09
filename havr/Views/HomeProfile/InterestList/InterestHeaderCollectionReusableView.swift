//
//  InterestHeaderCollectionReusableView.swift
//  havr
//
//  Created by Ismajl Marevci on 6/9/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

protocol InterestHeaderCollectionReusableViewDelegate: class {
    func segmentController(sender: InterestHeaderCollectionReusableView, interests index: Int)
    func segmentController(sender: InterestHeaderCollectionReusableView, trending index: Int)
    func segmentController(sender: InterestHeaderCollectionReusableView, inactive index: Int)
    
}

class InterestHeaderCollectionReusableView: UICollectionReusableView {

    @IBOutlet weak var selectedLabel: UILabel!
    @IBOutlet weak var segmentLabel: UILabel!
    @IBOutlet weak var segmentController: TwicketSegmentedControl!
    
    
    let titles = ["Interests", "Trending", "Inactive"]
    weak var delegate: InterestHeaderCollectionReusableViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        segmentController.setSegmentItems(titles)
        segmentController.delegate = self
        segmentController.backgroundColor = UIColor.clear
    }
}

extension InterestHeaderCollectionReusableView: TwicketSegmentedControlDelegate {
    func didSelect(_ segmentIndex: Int) {
        
        
        switch segmentIndex {
        case 0:
            self.delegate?.segmentController(sender: self, interests: segmentIndex)
            segmentLabel.text = "You can select up to 5 interests. Your interests are things that you do over and over again which you want to add as part of your portfolio."
            break
        case 1:
            self.delegate?.segmentController(sender: self, trending: segmentIndex)
            segmentLabel.text = "Select from top trending emojis that express your interests best."
            break
        case 2:
            self.delegate?.segmentController(sender: self, inactive: segmentIndex)
            segmentLabel.text = "These inactive interests still have your uploads in them. Select the ones you want to bring back."
            break
        default:
            break
        }
    }
}
