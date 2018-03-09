//
//  KanvasNavigationController.swift
//  havr
//
//  Created by Arben Pnishi on 8/22/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import KanvasCameraSDK

protocol KanvasCameraControllerDelegate: class {
    func camera(sender: KanvasNavigationController, didFinishPicking media: Media)
}

class KanvasNavigationController: UINavigationController {
    weak var cameraDelegate: KanvasCameraControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.isNavigationBarHidden = true
        UIApplication.shared.isStatusBarHidden = true
        AppDelegate.enableScreenOrientation()

        let kanvas = KVNCameraViewController.createVerifiedController()
        kanvas.delegate = self
        self.viewControllers = [kanvas]
    }
    
    override var shouldAutorotate: Bool{
        return false
    }
}

//Mark: - KVNCameraViewControllerDelegate

extension KanvasNavigationController: KVNCameraViewControllerDelegate{
    func cameraViewController(_ cameraViewController: KVNCameraViewController!, didFinishWith image: UIImage!) {
        if image != nil{
            console("image: \(image!)")
            delay(delay: 0, closure: { 
//                cameraViewController.dismiss(animated: false, completion: nil)
            })
            let resizedImage = image.resizePostImage()
            let media = Media.create(for: resizedImage)
            self.cameraDelegate?.camera(sender: self, didFinishPicking: media)
        }
    }
    
    func cameraViewController(_ cameraViewController: KVNCameraViewController!, didFinishWithVideo fileURL: URL!) {
        
        console("video: \(fileURL)")
        
        Helper.exportVideo(sourceUrl: fileURL) { (media) in
            if let media = media {
                delay(delay: 0, closure: { 
//                    cameraViewController.dismiss(animated: true, completion: nil)
                })
                self.cameraDelegate?.camera(sender: self, didFinishPicking: media)
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
            delay(delay: 0, closure: { 
//                cameraViewController.dismiss(animated: true, completion: nil)
            })
            self.cameraDelegate?.camera(sender: self, didFinishPicking: media)
        } else {
            Helper.show(alert: "Something went wrong while generating your gif.")
        }
    }
    
    func cameraViewController(_ cameraViewController: KVNCameraViewController!, willDismiss sender: Any!) {
        delay(delay: 0) { 
//            cameraViewController.dismiss(animated: true, completion: nil)
        }
        self.presentRightMenuViewController()
        self.dismiss(animated: true, completion: nil)
        UIApplication.shared.isStatusBarHidden = false
    }
}

extension KVNCameraViewController{
    open class func createVerifiedController() -> KVNCameraViewController {
        let kanvasCameraVC = KVNCameraViewController.verified()!
        
        //Images
        kanvasCameraVC.settings.closeImage = #imageLiteral(resourceName: "C back icon")
        kanvasCameraVC.settings.rotateImage = #imageLiteral(resourceName: "C rotate icon")
        kanvasCameraVC.settings.cameraImage =  #imageLiteral(resourceName: "C camera icon")
        kanvasCameraVC.settings.filtersImage = #imageLiteral(resourceName: "C filter icon")
        kanvasCameraVC.settings.videoImage = #imageLiteral(resourceName: "C video icon")
        kanvasCameraVC.settings.gifImage = #imageLiteral(resourceName: "C boomerang icon")
        kanvasCameraVC.settings.enableBorders = false
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
        kanvasCameraVC.settings.editSettings.enableBorders = false
        
        kanvasCameraVC.settings.editSettings.gifQuality = Constants.gifQuality
        kanvasCameraVC.settings.editSettings.gifCompressionFactor = Constants.gifCompressionRation
        //kanvasCameraVC.settings.editSettings.scaleMode = kEditScaleModeFit
        
        return kanvasCameraVC
    }
}
