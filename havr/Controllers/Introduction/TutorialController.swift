//
//  TutorialController.swift
//  havr
//
//  Created by Arben Pnishi on 11/2/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import LTMorphingLabel

class TutorialController: UIViewController, LTMorphingLabelDelegate {
    
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var firstLabel: LTMorphingLabel!
    @IBOutlet weak var secondLabel: LTMorphingLabel!
    
    @IBOutlet weak var lastImageView: UIImageView!
    @IBOutlet weak var lastImgHorizontalConstraint: NSLayoutConstraint!
    
    fileprivate var firstTexts = ["New look!", "Navigate easily", "Receive Notifications", "Interests Criteria"]
    fileprivate var secondTexts = ["We’ve got a new look with some creative features.", "Everything you need to navigate your way around.", "Don’t miss out on the latest activities of your connections.", "Sort your interests and stay organized."]
    fileprivate var didLayoutSubviews = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
    }
    
    func commonInit(){
        scroll.delegate = self
        pageControl.numberOfPages = firstTexts.count
        
        firstLabel.delegate = self
        firstLabel.morphingEffect = .evaporate
        secondLabel.delegate = self
        secondLabel.morphingEffect = .evaporate
    }
    
    override func viewDidLayoutSubviews() {
        if !didLayoutSubviews {
            setData()
            setCorrectImageFrames()
            didLayoutSubviews = true
        }
    }
    
    func setCorrectImageFrames(){
        if let img = lastImageView.image{
            let ratio = lastImageView.frame.height / img.size.height
            let currentImgWidth = img.size.width * ratio
            let offset = (scroll.frame.width - currentImgWidth) / 2
            lastImgHorizontalConstraint.constant = offset
            
            dispatch {
                self.lastImageView.layoutIfNeeded()
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func setData(){
        let index = scroll.currentPage
        
        firstLabel.text = firstTexts[index]
        secondLabel.text = secondTexts[index]
        
        if index == firstTexts.count - 1{
            nextButton.setTitle("FINISH", for: .normal)
        }else{
            nextButton.setTitle("NEXT", for: .normal)
        }
        pageControl.currentPage = index
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        if scroll.currentPage == firstTexts.count - 1{
            closeButtonPressed(UIButton())
        }else{
            scroll.setContentOffset(CGPoint.init(x: CGFloat(scroll.currentPage + 1) * scroll.frame.width, y: 0) , animated: true)
            delay(delay: 0.3, closure: {
                self.setData()
            })
        }
    }
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        self.hideModal()
    }
}

extension TutorialController: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        setData()
    }
}

//MARK: - EXTENSIONS
extension TutorialController {
    static func create() -> TutorialController {
        return UIStoryboard.introduction.instantiateViewController(withIdentifier: "TutorialController") as! TutorialController
    }
}

