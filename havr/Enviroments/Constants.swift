//
//  Constants.swift
//  havr
//
//  Created by Personal on 5/11/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import AWSS3
import AVFoundation
import KanvasCameraSDK

struct Constants {
    static var serviceUrl = "http://ec2-52-60-108-139.ca-central-1.compute.amazonaws.com/api/"
    static var socketUrl = "ws://ec2-52-60-108-139.ca-central-1.compute.amazonaws.com/"
    
    static var resourceUrl = "http://havr.s3.amazonaws.com/"
    
    static var defaultImageUser = #imageLiteral(resourceName: "defaultImageUser")
    static var defaultImageUserKoloda = #imageLiteral(resourceName: "defaultImageUserKoloda")
    static var defaultEventImage = #imageLiteral(resourceName: "E Event PIN")
    static var defaultEventGroupImage = #imageLiteral(resourceName: "E event group")
    static var defaultChatRoomImage = #imageLiteral(resourceName: "E Chatroom PIN")
    
    static var recordingImage = #imageLiteral(resourceName: "Recording.gif")
    static var typingImage = #imageLiteral(resourceName: "Typing.gif")
    
    static var defaultSeenMessageBlueImage = #imageLiteral(resourceName: "M seen")
    static var defaultSentMessageGrayImage = #imageLiteral(resourceName: "M delivered")
    
    static var anonimImage = #imageLiteral(resourceName: "E avatar icon")
    static var cameraBackground = #imageLiteral(resourceName: "cameraHolder")
    static let searchBarFrame = CGRect(x: 0, y: 0, width: (UIScreen.main.bounds.width - 105), height: 44)
    static let onClickSearchBarFrame = CGRect(x: -20, y: 0, width: (UIScreen.main.bounds.width - 20), height: 44)

    
    static let AWS_ACCESS_KEY_ID = "AKIAJRXUYHHARKBGH32A"
    static let AWS_SECRET_ACCESS_KEY = "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"
    static let AWS_S3_BUCKET_NAME = "havr"
    static let AWS_REGION = "ca-central-1"
    
    static let TWITTER_FEED_ITEM_PER_PAGE = 3
    static let NEWS_FEED_ITEM_PER_PAGE = 15
    static let FEED_ITEM_CNT_PER_PAGE = 30
    
    static let imageCompressionRation: CGFloat = 0.70
    static let gifCompressionRation: NSNumber = 0.3
    static let gifQuality = kKVNGifQualityMedium
    static let videoQuality = AVAssetExportPreset640x480
    
    static var isAnonymous: Bool = false
    
    static var maximumUserImageSize : CGSize {
        return CGSize(width: 840, height: 840)
    }
    
    static var maximumUserSignUpImageSize : CGSize {
        return CGSize(width: 640, height: 640)
    }
    
    static var maximumPostImageSize : CGSize {
        return CGSize(width: 840, height: 840)
    }
    
    static var maxmimumMessageImageSize: CGSize {
        return CGSize(width: 840, height: 840)
    }
    
    static var chatRoomColor = UIColor.HexToColor("#24BD40")
    static var eventColor = UIColor.HexToColor("#1BB9D5")
    
    static var AppEnterForegroundNotification = Notification.Name(rawValue: "AppEnterForegroundNotification")
}

struct Color {
    static let
    darkBlueColor = UIColor(red: 71/255.0, green: 103/255.0, blue: 141/255.0, alpha: 1.0),
    lightBlueColor = UIColor(red: 71/255.0, green: 103/255.0, blue: 141/255.0, alpha: 0.6),
    purpleColor = UIColor(red: 80/255.0, green: 227/255.0, blue: 194/255.0, alpha: 0.6)
    
}

struct Filter {
    static let
    skinSmoothing = "YUCIHighPassSkinSmoothing",
    toneCurve = "YUCIRGBToneCurve",
    histogram = "YUCIHistogramEqualization",
    noir = "CIPhotoEffectNoir",
    chrome = "CIPhotoEffectChrome",
    instant = "CIPhotoEffectInstant",
    process = "CIPhotoEffectProcess",
    transfer = "CIPhotoEffectTransfer"    
}

