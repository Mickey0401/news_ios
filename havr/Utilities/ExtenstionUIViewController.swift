//
//  ExtenstionUIViewController.swift
//  SalesApp
//
//  Created by Lindi on 9/2/16.
//  Copyright © 2016 Tenton. All rights reserved.
//

import UIKit
import MBProgressHUD
import Foundation
import ObjectiveC


fileprivate var hudKey: UInt8 = 0

extension UIViewController{
    
    var hud: MBProgressHUD?{
        get{
            return objc_getAssociatedObject(self, &hudKey) as? MBProgressHUD
        }
        set{
            objc_setAssociatedObject(self, &hudKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            newValue?.contentColor = Apperance.EFEFEFColor
            newValue?.backgroundColor = .clear
            newValue?.label.text = "Loading.."
        }
    }
    
    func showHud(_ message: String = ""){
        delay(delay: 0) { 
            self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        }
    }
    
    func hideHud(){
        delay(delay: 0) { 
            self.hud?.hide(animated: true)
        }
    }
    func hideHudWithMark(image: UIImage, string: String){
        let doneImageView = UIImageView(image: image)
        self.hud?.mode = MBProgressHUDMode.customView;
        self.hud?.contentColor = Apperance.EFEFEFColor
        self.hud?.customView = doneImageView
        self.hud?.label.text = string
        self.hud?.hide(animated: true, afterDelay: 1)
        //self.hud?.
//        delay(delay: 3) {
//            self.hud?.hide(animated: true)
//        }
    }
    func push(_ controller: UIViewController, animated: Bool = true, hideBottomBar : Bool? = nil) {
        if let hbt = hideBottomBar {
            controller.hidesBottomBarWhenPushed = hbt
        }
        
        self.navigationController?.pushViewController(controller, animated: animated)
    }
    func pop(_ animated: Bool = true) {
        if let controller = self.navigationController {
            controller.popViewController(animated: animated)
        }
    }
    func popToRoot(_ animated: Bool = true) {
        if let controller = self.navigationController {
            controller.popToRootViewController(animated: animated)
        }
    }
    
    func showModal(_ controller: UIViewController, animated: Bool = true, completion: (()->Void)? = nil) {
        self.present(controller, animated: animated, completion: completion)
    }
    
    func hideModal(_ animated: Bool = true, completion : (()->Void)? = nil) {
        self.dismiss(animated: animated, completion: completion)
    }
    
    static func create(controller: String, storyboardName: String) -> UIViewController? {
        return UIStoryboard(name: storyboardName, bundle: nil).instantiateViewController(withIdentifier: controller)
    }
    
    func setTabBarVisible(_ visible:Bool, animated: Bool = true){
        if let tabBar = self.tabBarController?.tabBar {
            // get a frame calculation ready
            let frame = tabBar.frame
            let height = frame.size.height
            let diff = UIScreen.main.bounds.height - tabBar.frame.origin.y - tabBar.frame.height
            let offsetY = (visible ? (diff == 0 ? 0 : -height) : (diff == 0 ? height : 0))
            
            // zero duration means no animation
            let duration: TimeInterval = (animated ? 0.3 : 0.0)
            
            //  animate the tabBar
            UIView.animate(withDuration: duration, animations: {
                self.tabBarController?.tabBar.frame = frame.offsetBy(dx: 0, dy: offsetY)
            }, completion: { (completed) in
                self.tabBarController?.tabBar.isHidden = !visible
            })
        }
    }
    
    func switchWindowRoot(to place: ApplicationPlace){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.switchWindowRoot(to: place)
    }
}

extension UIStoryboard {
    static var main : UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }
    static var broadcast: UIStoryboard {
        return UIStoryboard(name: "Broadcast", bundle: nil)
    }
    static var search: UIStoryboard {
        return UIStoryboard(name: "Search", bundle: nil)
    }
    static var profile: UIStoryboard {
        return UIStoryboard(name: "Profile", bundle: nil)
    }
    static var chating: UIStoryboard {
        return UIStoryboard(name: "Chating", bundle: nil)
    }
    static var camera: UIStoryboard {
        return UIStoryboard(name: "Camera", bundle: nil)
    }
    static var messages: UIStoryboard {
        return UIStoryboard(name: "Messages", bundle: nil)
    }
    static var introduction: UIStoryboard {
        return UIStoryboard(name: "Introduction", bundle: nil)
    }
    static var explore: UIStoryboard {
        return UIStoryboard(name: "Explore", bundle: nil)
    }
    static var settings: UIStoryboard {
        return UIStoryboard(name: "Settings", bundle: nil)
    }
    static var reaction: UIStoryboard {
        return UIStoryboard(name: "Reaction", bundle: nil)
    }
    static var slide: UIStoryboard {
        return UIStoryboard(name: "Slide", bundle: nil)
    }
    static var slideExplore: UIStoryboard {
        return UIStoryboard(name: "SlideExplore", bundle: nil)
    }
    static var admin: UIStoryboard {
        return UIStoryboard(name: "Admin", bundle: nil)
    }
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
