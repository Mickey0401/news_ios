//
//  PhotoViewController.swift
//  havr
//
//  Created by Yuriy G. on 1/20/18.
//  Copyright © 2018 Tenton LLC. All rights reserved.
//

import UIKit
import CoreImage

class PhotoViewController: UIViewController {

	override var prefersStatusBarHidden: Bool {
		return true
	}

	fileprivate var backgroundImage     : UIImage!
    fileprivate var filterView          : SCSwipeableFilterView!
    fileprivate var scrollView          : UIScrollView!,
                    containerView       : UIView!,
                    lblAlert            : UILabel!,
                    gesture             : UITapGestureRecognizer!
    
    fileprivate var imageViews          = [UIImageView]()

	init(image: UIImage) {
		self.backgroundImage = image
		super.init(nibName: nil, bundle: nil)
	}

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard self.isViewLoaded else {
            return
        }        
        
        filterView.frame = view.frame
        lblAlert.frame = CGRect(x: (view.frame.width - 200)/2, y: 45, width: 200, height: 30)
    }
    
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = UIColor.white
        filterView = SCSwipeableFilterView()
        view.addSubview(filterView)
        
        lblAlert = UILabel()
        lblAlert.textColor = UIColor.white
        lblAlert.text = "Swipe to left"
        lblAlert.textAlignment = .center
        
        view.addSubview(lblAlert)
	}
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        

        filterView.contentMode = .scaleAspectFit

        filterView.filters = [SCFilter.empty(),
                              SCFilter.init(ciFilter: Helper.getSkinFilter(Filter.skinSmoothing)) ?? SCFilter.empty(),
                              SCFilter.init(ciFilter: Helper.getVIVIDFilter(Filter.toneCurve)) ?? SCFilter.empty(),
                              SCFilter.init(ciFilter: Helper.getNormalFilter(Filter.noir)) ?? SCFilter.empty(),
                              SCFilter.init(ciFilter: Helper.getNormalFilter(Filter.chrome)) ?? SCFilter.empty(),
                              SCFilter.init(ciFilter: Helper.getNormalFilter(Filter.instant)) ?? SCFilter.empty(),
                              SCFilter.init(ciFilter: Helper.getNormalFilter(Filter.process)) ?? SCFilter.empty(),
                              SCFilter.init(ciFilter: Helper.getNormalFilter(Filter.transfer)) ?? SCFilter.empty(),
                              SCFilter.init(ciFilter: Helper.getVIVIDFilter(Filter.histogram)) ?? SCFilter.empty()]
        
        filterView.setImageBy(backgroundImage)
        

        displayAlert()
        
        gesture = UITapGestureRecognizer(target: self, action: #selector (self.touchAction (_:)))
        view.addGestureRecognizer(gesture)
    }
 
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let guester = gesture {
            view.removeGestureRecognizer(guester)
        }
    }
    
    func touchAction(_ sender:UITapGestureRecognizer){
        displayAlert()
    }
    
    fileprivate func displayAlert() {
        lblAlert.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.lblAlert.isHidden = true
        }
    }
 
    public func getMedia() -> Media? {
        if let image = filterView.renderedUIImage() {
            return Media.create(for: image)
        }
        
        return nil
    }

    public func saveCameraRoll(_ completion: @escaping ((Bool) -> Void)) {
        if let image = filterView.renderedUIImage() {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
            let alert : UIAlertController = UIAlertController(title: "Photo Saved", message: nil, preferredStyle: .alert)
            
            let cancelActionButton: UIAlertAction = UIAlertAction(title: "Ok", style: .cancel) { action -> Void in
                alert.dismiss(animated: true, completion: nil)
                completion(true)
            }
            alert.addAction(cancelActionButton)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
}


