//
//  PreviewView.swift
//  havr
//
//  Created by Yuriy G. on 1/18/18.
//  Copyright © 2018 Tenton LLC. All rights reserved.
//

import UIKit
import AVFoundation

public enum CamVideoGravity {

    case resize
    case resizeAspect
    case resizeAspectFill
}

class PreviewView: UIView {
    
    private var gravity: CamVideoGravity = .resizeAspect
    
    init(frame: CGRect, videoGravity: CamVideoGravity) {
        gravity = videoGravity
        super.init(frame: frame)
        self.backgroundColor = UIColor.black
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
	var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        let previewlayer = layer as! AVCaptureVideoPreviewLayer
        switch gravity {
        case .resize:
            previewlayer.videoGravity = AVLayerVideoGravityResize
        case .resizeAspect:
            previewlayer.videoGravity = AVLayerVideoGravityResizeAspect
        case .resizeAspectFill:
            previewlayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        }
		return previewlayer
	}
	
	var session: AVCaptureSession? {
		get {
			return videoPreviewLayer.session
		}
		set {
			videoPreviewLayer.session = newValue
		}
	}
    
    public func getMetadataOutputRectConverted() -> CGRect? {
        return videoPreviewLayer.metadataOutputRectOfInterest(for: self.frame)
    }
	
	// MARK: UIView	
	override class var layerClass : AnyClass {
		return AVCaptureVideoPreviewLayer.self
	}
}
