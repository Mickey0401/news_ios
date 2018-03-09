//
//  UIImage.swift
//  havr
//
//  Created by Personal on 6/26/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import Kingfisher
extension UIImage {
    func resizeUserImage(isSignup: Bool = false) -> UIImage {
        let max = isSignup ? Constants.maximumUserSignUpImageSize : Constants.maximumUserImageSize
        
        if size.height > size.width {
            if size.height > max.height {
                return kf.resize(to: self.size.aspectRatio(height: max.height))
            } else {
                return self
            }
        } else {
            if size.width > max.width {
                return kf.resize(to: self.size.aspectRatio(width: max.width))
            } else {
                return self
            }
        }
    }
    
    func resizeTo(size: CGSize) -> UIImage {
        if self.size.equalTo(size) {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    func resizePostImage() -> UIImage {
        let max = Constants.maximumPostImageSize
        
        if size.height > size.width {
            if size.height > max.height {
                return kf.resize(to: self.size.aspectRatio(height: max.height))
            } else {
                return self
            }
        } else {
            if size.width > max.width {
                return kf.resize(to: self.size.aspectRatio(width: max.width))
            } else {
                return self
            }
        }
    }
    func resizeMessageImage() -> UIImage {
        let max = Constants.maxmimumMessageImageSize
        
        if size.height > size.width {
            if size.height > max.height {
                return kf.resize(to: self.size.aspectRatio(height: max.height))
            } else {
                return self
            }
        } else {
            if size.width > max.width {
                return kf.resize(to: self.size.aspectRatio(width: max.width))
            } else {
                return self
            }
        }
    }
}
