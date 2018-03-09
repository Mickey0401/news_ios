//
//  TabBarController.swift
//  havr
//
//  Created by Ismajl Marevci on 4/20/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import KanvasCameraSDK

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    open var broadcast: BroadcastController!
    open var search: SearchController!
    open var camera: CameraController!
    open var slideExplore: SlideExploreController!
    open var messages: ChatsController!
    
    var bFlagFirst: Bool = true

    static weak var shared: TabBarController?
    
    var messagesItem: UITabBarItem {
        return tabBar.items![4]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        findChildControllers()
        tabBarImages()
        loadResources()
        TabBarController.shared = self
    }
    func tabBarImages(){

        let unselectedColor = UIColor(red255: 192, green255: 197, blue255: 204)
        let selectedColor = UIColor.selectedDirtyBlue

        UITabBar.appearance().tintColor = UIColor.selectedDirtyBlue
        UITabBar.appearance().backgroundImage = UIImage.colorForNavBar(color: .white)
        UITabBar.appearance().shadowImage = UIImage.colorForNavBar(color: UIColor(red255: 228, green255: 228, blue255: 228))
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: unselectedColor], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: selectedColor], for: .selected)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AppDelegate.disableScreenOrientation()
        if (bFlagFirst) {
            self.addActiveUnderlineAtTabBarItemIndex(index: 0)
            bFlagFirst = false
        }
    }
    
    func addActiveUnderlineAtTabBarItemIndex(index: Int) {
        if (index == 2) {
            return
        }
        
        for subview in self.tabBar.subviews {
            if subview.tag == 1314 {
                subview.removeFromSuperview()
                break
            }
        }
        
        let bottomMargin: CGFloat = 4
        let activeLineWidth: CGFloat = 40
        
        let tabBarItemCount = CGFloat(self.tabBar.items!.count)
        
        let tabItemWidth = view.bounds.size.width / (tabBarItemCount)
        
        let  xOffset = tabItemWidth * (CGFloat(index) + CGFloat(0.5)) - activeLineWidth / 2.0
        
        //let imageHalfWidth: CGFloat = ((self.tabBar.items![index]).selectedImage?.size.width)!
        
        let ivActiveLine = UIImageView(frame: CGRect(x: xOffset, y: 50 - bottomMargin, width: activeLineWidth, height: 3))
        ivActiveLine.image = UIImage.init(named: "tab_active_underline")
        ivActiveLine.tag = 1314
        
        self.tabBar.addSubview(ivActiveLine)
    }
    
    private func findChildControllers(){
        for child in viewControllers! {
            if child is UINavigationController {
                if let controller = (child as! UINavigationController).viewControllers.first {
                    switch controller {
                    case is BroadcastController:
                        broadcast = controller as! BroadcastController
                        break
                        
                    case is SearchController:
                        search = controller as! SearchController
                        break
                        
                    case is CameraController:
                        camera = controller as! CameraController
                        break
                        
                    case is SlideExploreController:
                        slideExplore = controller as! SlideExploreController
                        break
                        
                    case is ChatsController:
                        messages = controller as! ChatsController
                        break
                    default:
                        break
                    }
                }
            }
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let controller = (viewController as! UINavigationController).viewControllers.first{
            var shouldResetVideoInBroadcast = true
            if controller is CameraController {
              
                let camVC = CameraViewController.create()
                self.showModal(camVC)
                
                return false
            }else if controller is BroadcastController{
                if (controller as! BroadcastController).canScrollToTop{
                    (controller as! BroadcastController).scrollToTop()
                    shouldResetVideoInBroadcast = false
                }
            }
            if shouldResetVideoInBroadcast {
                slideController.tabBar.broadcast.resetVideoView()
            }
        }
        
        
        return true
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        var selectedTabIndex: Int = 0
        if item == (self.tabBar.items!)[0]{
            //Do something if index is 0
            selectedTabIndex = 0
        }
        else if item == (self.tabBar.items!)[1]{
            //Do something if index is 1
            selectedTabIndex = 1
        }
        else if item == (self.tabBar.items!)[2]{
            //Do something if index is 1
            selectedTabIndex = 2
        }
        else if item == (self.tabBar.items!)[3]{
            //Do something if index is 1
            selectedTabIndex = 3
        }
        else if item == (self.tabBar.items!)[4]{
            //Do something if index is 1
            selectedTabIndex = 4
        }
        
        self.addActiveUnderlineAtTabBarItemIndex(index: selectedTabIndex)
    }
    
    func loadResources() {        
        InterestsAPI.getMine { (interests, error) in
            if let interests = interests {
                ResourcesManager.userInterests = interests
            }
        }
        
        InterestsAPI.getAll { (intersts, error) in
            if let interests = intersts {
                ResourcesManager.allInterests = interests
            }
        }
        
        InterestsAPI.getTrending { (interests, error) in
            if let interests = interests {
                ResourcesManager.trendingInterests = interests
            }
        }
    }
}

//MARK: - Kanvas Camera NAvigationController Delegate
extension TabBarController: KanvasCameraControllerDelegate {
    func camera(sender: KanvasNavigationController, didFinishPicking media: Media) {
        let createPost = CreatePostController.create()
        createPost.media = media
        delay(delay: 0) { 
            sender.pushViewController(createPost, animated: true)
        }
    }
}

extension UIColor {
    static var selectedDirtyBlue: UIColor {
        return UIColor(red255: 71, green255: 103, blue255: 141)
    }
}
