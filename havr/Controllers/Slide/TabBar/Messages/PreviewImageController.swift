//
//  PreviewImageController.swift
//  havr
//
//  Created by Ismajl Marevci on 7/27/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

class PreviewImageController: UIViewController {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var showPostButton: UIButton!
    
    
    var image: UIImage?
    var post: Post? 
    fileprivate var isButtonsShowed = false
    override func viewDidLoad() {
        super.viewDidLoad()
        showPostButton.isHidden = true
        if let image = image {
            imageView.image = image
        }
        if let post = post {
            showPostButton.isHidden = false
            showPostButton.alpha = 0
            closeButton.alpha = 0
            imageView.kf.setImage(with: post.getImageUrl())
        }
        setupScrollView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        AppDelegate.enableScreenOrientation()
        UIApplication.shared.isStatusBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppDelegate.disableScreenOrientation()
        UIApplication.shared.isStatusBarHidden = false
    }
    
    func setupScrollView() {
        scrollView.isScrollEnabled = true
        scrollView.delegate = self
        scrollView.addTapGestureFor(self, #selector(showButtons))
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(showButtons))
        doubleTap.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(doubleTap)
    }
    
    func showButtons() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.3) {
            self.hideButtons()
        }

        self.showPostButton.alpha = 0
        self.closeButton.alpha = 0
        UIView.animate(withDuration: 0.5) {
            self.showPostButton.alpha = 1.0
            self.closeButton.alpha = 1.0
            self.isButtonsShowed = true
        }

    }
    
    func hideButtons() {
        UIView.animate(withDuration: 0.5) {
            self.showPostButton.alpha = 0.0
            self.closeButton.alpha = 0.0
            self.isButtonsShowed = false
        }
    }

    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        scrollView.setZoomScale(1, animated: true)
        AppDelegate.disableScreenOrientation()
        self.hideModal()
    }
    
    @IBAction func showPost(_ sender: Any) {
        if let post = post {
            let controller = PostDetailController.create()
            controller.post = post
            controller.isFromSaved = true
            self.push(controller)
        }
    }
}

extension PreviewImageController {
    static func create(image: UIImage) -> PreviewImageController {
        let controller = UIStoryboard.messages.instantiateViewController(withIdentifier: "PreviewImageController") as! PreviewImageController
        controller.image = image
        return controller
    }
    
    static func create(post: Post) -> PreviewImageController {
        let controller = UIStoryboard.messages.instantiateViewController(withIdentifier: "PreviewImageController") as! PreviewImageController
        controller.post = post
        return controller
    }
}

extension PreviewImageController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func doubleTapped(sender: UITapGestureRecognizer) {
        
        let location = sender.location(in: scrollView)
        
        if(scrollView.zoomScale == scrollView.minimumZoomScale){
            let rect = CGRect(x: location.x - 50, y: location.y - 50, width: 100, height: 100)
            scrollView.zoom(to: rect, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        }
    }
}
