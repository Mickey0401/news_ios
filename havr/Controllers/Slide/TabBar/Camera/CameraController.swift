//
//  CameraController.swift
//  havr
//
//  Created by Arben Pnishi on 4/21/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import KanvasCameraSDK

protocol CameraControllerDelegate: class {
    func camera(sender: CameraController, didFinishPicking media: Media)
}

class CameraController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var flipCameraButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var cameraImageView: UIImageView!
    
    @IBOutlet weak var bottomCameraContainerView: UIView!
    
    var isOpenedFromTabBar = true
    var didLayout = false
    
    weak var delegate: CameraControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commonInit()
        setupDoubleTap()
        GA.TrackScreen(name: "Camera")

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !didLayout {
            showKanvasCamera()
            didLayout = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("CameraController DidAppear")
        UIApplication.shared.isStatusBarHidden = true
        //        _ = cameraManager.addPreviewLayerToView(cameraImageView, newCameraOutputMode: .stillImage, completition: nil)
        delay(delay: 0.1) {
            self.bottomCameraContainerView.isHidden = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        UIApplication.shared.isStatusBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func commonInit(){
    }
    
    func showKanvasCamera(){
        let kanvasCameraVC = KVNCameraViewController.verified()!
        kanvasCameraVC.delegate = self
        
        //Settings
        //        kanvasCameraVC.settings.enableMenu = false
        //        kanvasCameraVC.settings.enableGifMode = true
        
        //Images
        kanvasCameraVC.settings.closeImage = #imageLiteral(resourceName: "C back icon")
        kanvasCameraVC.settings.rotateImage = #imageLiteral(resourceName: "C rotate icon")
        kanvasCameraVC.settings.cameraImage =  #imageLiteral(resourceName: "C camera icon")
        kanvasCameraVC.settings.filtersImage = #imageLiteral(resourceName: "C filter icon")
        kanvasCameraVC.settings.videoImage = #imageLiteral(resourceName: "C video icon")
        kanvasCameraVC.settings.gifImage = #imageLiteral(resourceName: "C boomerang icon")
//        kanvasCameraVC.settings.enableFilters = false

        //Video
        kanvasCameraVC.settings.maxVideoDuration = 300
        
        //Edit Settings
        //        kanvasCameraVC.settings.editSettings.enableCrop = false
        kanvasCameraVC.settings.editSettings.backImage = UIImage.init(named: "back icon")
        kanvasCameraVC.settings.editSettings.filtersImage = UIImage.init(named: "C filter icon")
        kanvasCameraVC.settings.editSettings.sendImage = UIImage.init(named: "C send icon")
        kanvasCameraVC.settings.editSettings.drawingImage = UIImage.init(named: "C draw icon")
        kanvasCameraVC.settings.editSettings.stampsImage = UIImage.init(named: "C sticker icon")
        kanvasCameraVC.settings.editSettings.textImage = UIImage.init(named: "C text icon")
        kanvasCameraVC.settings.editSettings.defaultScaleMode = kEditScaleModeFit
        kanvasCameraVC.settings.editSettings.gifQuality = Constants.gifQuality
        kanvasCameraVC.settings.editSettings.gifCompressionFactor = Constants.gifCompressionRation
        
//        //Add it as a child view controller
//        self.addChildViewController(kanvasCameraVC)
//        self.view.addSubview(kanvasCameraVC.view)
//        self.view.bringSubview(toFront: kanvasCameraVC.view)
//        kanvasCameraVC.didMove(toParentViewController: self)
        self.push(kanvasCameraVC)
    }
    
    @IBAction func flipCameraButtonPressed(_ sender: UIButton) {
        
        //        if cameraManager.cameraDevice == .front {
        //            cameraManager.cameraDevice = .back
        //        }else {
        //            cameraManager.cameraDevice = .front
        //        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        goBack()
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        
    }
    
    func goBack() {
        if isOpenedFromTabBar {
            self.dismiss(animated: true, completion: nil)
        }else{
            self.pop()
        }
    }
    
    func setupDoubleTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tap.delegate = self
        tap.numberOfTapsRequired = 2
        self.cameraImageView.isUserInteractionEnabled = true
        self.cameraImageView.addGestureRecognizer(tap)
    }
    
    func handleTap() {
        //        if cameraManager.cameraDevice == .front {
        //            cameraManager.cameraDevice = .back
        //        }else {
        //            cameraManager.cameraDevice = .front
        //        }
    }
    
}

extension CameraController {
    static func create() -> CameraController {
        return UIStoryboard.camera.instantiateViewController(withIdentifier: "CameraController") as! CameraController
    }
}

//Mark: - KVNCameraViewControllerDelegate

extension CameraController: KVNCameraViewControllerDelegate{
    func cameraViewController(_ cameraViewController: KVNCameraViewController!, didFinishWith image: UIImage!) {
        if image != nil{
            console("image: \(image!)")
            cameraViewController.dismiss(animated: false, completion: nil)
            
            let resizedImage = image.resizePostImage()
            
            let media = Media.create(for: resizedImage)
            self.delegate?.camera(sender: self, didFinishPicking: media)
        }
    }
    
    func cameraViewController(_ cameraViewController: KVNCameraViewController!, didFinishWithVideo fileURL: URL!) {
        
        console("video: \(fileURL)")
        
        Helper.exportVideo(sourceUrl: fileURL) { (media) in
            if let media = media {
                cameraViewController.dismiss(animated: true, completion: nil)
                self.delegate?.camera(sender: self, didFinishPicking: media)
            } else {
                Helper.show(alert: "Something went wrong while generating your video.")
            }
        }
    }
    
    func cameraViewController(_ cameraViewController: KVNCameraViewController!, didFinishWith outputData: KVNOutputData!) {
        
    }
    
    func cameraViewController(_ cameraViewController: KVNCameraViewController!, didFinishWithGifURL fileURL: URL!) {
        console("gif: \(fileURL)")
        
        if let media = Media.create(gif: fileURL) {
            cameraViewController.dismiss(animated: true, completion: nil)
            self.delegate?.camera(sender: self, didFinishPicking: media)
        } else {
            Helper.show(alert: "Something went wrong while generating your gif.")
        }
    }
    
    func cameraViewController(_ cameraViewController: KVNCameraViewController!, willDismiss sender: Any!) {
        cameraViewController.dismiss(animated: true, completion: nil)
        goBack()
    }
}


