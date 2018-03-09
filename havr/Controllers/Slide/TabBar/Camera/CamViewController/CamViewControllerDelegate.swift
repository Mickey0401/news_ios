//
//  CamViewControllerDelegate.swift
//  havr
//
//  Created by Yuriy G. on 1/18/18.
//  Copyright © 2018 Tenton LLC. All rights reserved.
//
import UIKit

public protocol CamViewControllerDelegate: class {
    
    func camViewController(_ camViewController: CamViewController, didTake photo: UIImage)
  
    func camViewController(_ camViewController: CamViewController, didBeginRecordingVideo camera: CamViewController.CameraSelection)
    
    func camViewController(_ camViewController: CamViewController, didFinishRecordingVideo camera: CamViewController.CameraSelection)
    
    
    func camViewController(_ camViewController: CamViewController, didFinishProcessVideoAt url: URL)


    func camViewController(_ camViewController: CamViewController, didFailToRecordVideo error: Error)
    
    func camViewController(_ camViewController: CamViewController, didSwitchCameras camera: CamViewController.CameraSelection)

    func camViewController(_ camViewController: CamViewController, didFocusAtPoint point: CGPoint)
 
    func camViewController(_ camViewController: CamViewController, didChangeZoomLevel zoom: CGFloat)
    
    func camViewController(_ camViewController: CamViewController, didChangeRecordingTime seconds: Int)
}

public extension CamViewControllerDelegate {
    
    func camViewController(_ camViewController: CamViewController, didTake photo: UIImage) {
        // Optional
    }

    
    func camViewController(_ camViewController: CamViewController, didBeginRecordingVideo camera: CamViewController.CameraSelection) {
        // Optional
    }

    
    func camViewController(_ camViewController: CamViewController, didFinishRecordingVideo camera: CamViewController.CameraSelection) {
        // Optional
    }

    
    func camViewController(_ camViewController: CamViewController, didFinishProcessVideoAt url: URL) {
        // Optional
    }
    
    func camViewController(_ camViewController: CamViewController, didFailToRecordVideo error: Error) {
        // Optional
    }
    
    func camViewController(_ camViewController: CamViewController, didSwitchCameras camera: CamViewController.CameraSelection) {
        // Optional
    }

    
    func camViewController(_ camViewController: CamViewController, didFocusAtPoint point: CGPoint) {
        // Optional
    }

    
    func camViewController(_ camViewController: CamViewController, didChangeZoomLevel zoom: CGFloat) {
        // Optional
    }
    
    func camViewController(_ camViewController: CamViewController, didChangeRecordingTime seconds: Int) {
        // Optional
    }
}



