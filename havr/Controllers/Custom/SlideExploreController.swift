//
//  SlideExploreController.swift
//  havr
//
//  Created by Agon Miftari on 4/30/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

enum SlideExploreControllerPosition{
    case left
    case right
}

class SlideExploreController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var leftContainer: UIView!
    @IBOutlet weak var rightContainer: UIView!
    
    open var admin: AdminController!
    open var explore: ExploreController!
    
    open var didLayoutSubviews = false
    
    var position : SlideExploreControllerPosition {
        get {
            return getScrollPosition()
        }
    }
    
    var isScrollEnabled : Bool {
        get {
            return scrollView.isScrollEnabled
        }
        set {
            return scrollView.isScrollEnabled = newValue
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        findChildControllers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.slideController.tabBar.slideExplore.navigationController?.setNavigationBarHidden(true, animated: animated)
        
    }
    
    override func viewDidLayoutSubviews() {
        if !didLayoutSubviews {
            set(position: .right, animated: false)
            didLayoutSubviews = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    
   private func getScrollPosition() -> SlideExploreControllerPosition{
        let width = self.view.frame.width
        let offset = scrollView.contentOffset.x
        
        
        if offset >= 0 && offset < width{
            return .left
        }else {
            return .right
        }
    }
    
    private func findChildControllers() {
        for child in childViewControllers {
            
            if child is UINavigationController {
                if let controller = (child as! UINavigationController).viewControllers.first {
                    switch controller {
                    case is AdminController:
                        admin = controller as! AdminController
                        break
                    case is ExploreController:
                        explore = controller as! ExploreController
                        break
                    default:
                        break
                    }
                }
            }
        }
    }
    
    open func set(position: SlideExploreControllerPosition, animated: Bool = true) {
        self.view.endEditing(true)
        let width = self.view.frame.width
        var offset : CGFloat = 0.0
        
        switch position {
        case .left:
            admin.viewDidAppear(true)
            break
        case .right:
            offset = width
            explore.viewDidAppear(true)
            break
        }
        scrollView.setContentOffset(CGPoint.init(x: offset, y: 0), animated: animated)
        
    }
    
}


extension SlideExploreController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if position == .left {
            admin.viewDidAppear(true)
        }else {
            explore.viewDidAppear(true)
        }
    }
    
}

extension UIViewController {    
    
    @IBAction func presentLeftExploreViewController() {
        self.slideController.tabBar.slideExplore.set(position: .left)
    }
    
    @IBAction func presentRightExploreViewController() {
        self.slideController.tabBar.slideExplore.set(position: .right)
    }
}


















