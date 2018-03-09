//
//  WebNavigationController.swift
//  havr
//
//  Created by CloudStream on 2/23/18.
//  Copyright © 2018 Tenton LLC. All rights reserved.
//

import Foundation
import SHGWebViewController
class WebNavigationController: UINavigationController {
    var webUrl: String?
    var strTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initWebViewController()
    }
    
    func setup(url: String?, _ title: String? = nil) {
        webUrl = url
       
        if (title == nil) {
            strTitle = URL(string: url!)?.host
        }
    }
    
    func initWebViewController() {
        if (webUrl == nil || strTitle == nil) {
            setup(url: "http://apple.com")
        }
        
        let webController = WebViewController(urlToLoad: webUrl!)
        
        webController.delegate = self
        webController.toolBarTintColor = UIColor.gray.withAlphaComponent(0.5)
        webController.progressTintColor = UIColor.selectedDirtyBlue
        
        let titleView = UILabel()
        titleView.font = UIFont.navigationTitleFont
        titleView.text = strTitle
        webController.navigationItem.titleView = titleView

        self.navigationBar.backgroundColor = self.navigationController?.navigationBar.backgroundColor
        self.navigationBar.tintColor = self.navigationController?.navigationBar.tintColor
        self.navigationBar.isTranslucent = false
        self.viewControllers = [webController]
    }
}

extension WebNavigationController: WebViewControllerDelegate {
    func webViewController(_ webViewController: WebViewController, setupAppearanceForMain view: UIView) {
        
    }
    
    func webViewControllerDidStartLoad(_ webViewController: WebViewController) {
    }
    
    func webViewControllerDidFinishLoad(_ webViewController: WebViewController) {
    }
    
    func webViewController(_ webViewController: WebViewController, enabledTintColorFor button: UIButton) -> UIColor {
        return UIColor.HexToColor("#47678D")
    }
}
