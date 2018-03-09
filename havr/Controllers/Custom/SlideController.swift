//
//  SlideViewController.swift
//  havr
//
//  Created by Arben Pnishi on 4/8/17.
//  Copyright © 2017 TENTON. All rights reserved.
//

import UIKit
import Foundation

enum SlideControllerPosition {
    case left
    case right
}

class SlideController: UIViewController {
    
    open var profile: ProfileController!
    open var tabBar: TabBarController!
    
    private var didLayoutSubviews = false
    
    @IBOutlet private weak var scroll: UIScrollView!
    @IBOutlet private weak var leftContainer: UIView!
    @IBOutlet private weak var rightContainer: UIView!
    
    var position: SlideControllerPosition{
        get{
            return getScrollPosition()
        }
    }
    
    var isScrollEnabled: Bool{
        get{
            return scroll.isScrollEnabled
        }
        
        set{
            scroll.isScrollEnabled = newValue
        }
    }
    
    private func getScrollPosition() -> SlideControllerPosition{
        let width = self.view.frame.width
        let offset = scroll.contentOffset.x
        
        if offset >= 0  && offset < width{
            return .left
        }else{
            return .right
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        findChildControllers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        if !didLayoutSubviews {
            set(position: .right, animated: false)
            didLayoutSubviews = true
        }
    }
    
    private func findChildControllers(){
        for child in childViewControllers {
            if child is UINavigationController {
                if let controller = (child as! UINavigationController).viewControllers.first {
                    switch controller {
                    case is ProfileController:
                        profile = controller as! ProfileController
                        break
                        
                    case is TabBarController:
                        tabBar = controller as! TabBarController
                        break
                        
                    default:
                        break
                    }
                }
            }
        }
    }
    
    open func set(position: SlideControllerPosition, animated: Bool = true){
        self.view.endEditing(true)
        let width = self.view.frame.width
        var offset: CGFloat = 0.0
        
        switch position {
        case .left:
            profile.viewDidAppear(true)
            break
            
        case .right:
            tabBar.viewDidAppear(true)
            offset = width
            break
        }
        scroll.setContentOffset(CGPoint.init(x: offset, y: 0), animated: animated)
    }
}

extension SlideController: UIScrollViewDelegate{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if position == .left {
            profile.viewDidAppear(true)
        }else{
            tabBar.viewDidAppear(true)
        }
    }
}

extension UIViewController {
    
    func setStatusBarBackgroundColor(color: UIColor) {
        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
        statusBar.backgroundColor = color
    }
    
    var slideController: SlideController! {
        return getSlideController()
    }
    
    var slideNavigationController: UINavigationController{
        
        return self.slideController.navigationController!
    }
    
    private func getSlideController() -> SlideController! {

        let appDelegate  = UIApplication.shared.delegate as! AppDelegate
        let navigation = appDelegate.window!.rootViewController as! UINavigationController
        
        let controller = navigation.viewControllers[0]
        if controller is SlideController{
            return controller as! SlideController
        }
        return nil
    }
    
    @IBAction func presentLeftMenuViewController() {
        self.slideController?.set(position: .left)
        slideController.tabBar.broadcast.resetVideoView()
    }
    
    @IBAction func presentRightMenuViewController() {
        self.slideController?.set(position: .right)
    }
}

extension SlideController: UIBarPositioningDelegate{
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}
