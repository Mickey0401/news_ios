//
//  Helper.swift
//  SalesApp
//
//  Created by Arben Pnishi on 9/28/16.
//  Copyright © 2016 Tenton. All rights reserved.
//

import UIKit
import AVFoundation

func console(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
        print(items[0], separator: separator, terminator: terminator)
    #endif
}

func delay(delay:Double, closure: @escaping ()->()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        closure()
    }
}

func dispatch(_ closure: @escaping ()->()) {
    delay(delay: 0.0, closure: closure)
}

class Helper: NSObject {
    static func size(from string: String) -> CGSize? {
        let split = string.components(separatedBy: "x")
        
        if split.count == 2 {
            if let width = Int(split[0]), let height = Int(split[1]) {
                return CGSize(width: width, height: height)
            }
        }
        
        return nil
    }
    static func generateString(length: Int = 48) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    
    static func createIndexes(offset: Int = 0, count: Int = 0, section: Int = 0) -> [IndexPath] {
        var indexs = [IndexPath]()
        
        for i in offset ..< offset + count {
            let index = IndexPath(item: i, section: section)
            indexs.append(index)
        }
        
        return indexs
    }
    
    static func background(closure: @escaping (()->Void)) {
        DispatchQueue.global(qos: .background).async {
            closure()
        }
    }
    
    static func show(alert message: String, title: String? = nil, doneButton text: String = "OK", completion: (()->Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let doneAction = UIAlertAction(title: text, style: .default) { (action) in
            completion?()
        }
        
        alertController.addAction(doneAction)
        alertController.modalPresentationStyle = .overCurrentContext
        alertController.modalPresentationCapturesStatusBarAppearance = true
        alertController.view.tintColor = Apperance.appBlueColor
        UIApplication.shared.presentedController()?.present(alertController, animated: true, completion: nil)
        alertController.view.tintColor = Apperance.appBlueColor
        
    }
    
    
    static func horizontalBarAnimation(view: UIView) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            view.layoutIfNeeded()
        }, completion: nil)
    }
    
    
    static func setupTransparentNavigationBar(nav: UINavigationController) {
        let image = UIImage.imageWithColor(color: Apperance.navTintColor)
        nav.navigationBar.setBackgroundImage(image, for: .default)
        nav.navigationBar.shadowImage = image
        nav.navigationBar.isTranslucent = false
        nav.navigationBar.backgroundColor = Apperance.navTintColor
        //nav.setStatusBarBackgroundColor(color: Apperance.navTintColor)
    }
    
    
    static func setupLightNavigationBar(navBar: UINavigationBar) {
        navBar.barTintColor = UIColor(red255: 255, green255: 255, blue255: 255)
        navBar.tintColor = UIColor(red255: 192, green255: 197, blue255: 204)
        navBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.black]
        UIApplication.shared.statusBarStyle = .default
    }
    
//    static func setupBlueNavigationBar(navBar: UINavigationBar) {
//
//        navBar.barTintColor = Apperance.appBlueColor
//        navBar.tintColor = UIColor.white
//        navBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
////        UIApplication.shared.statusBarStyle = .lightContent
//
//    }
    
    static func setupNavSearchBar(searchBar: UISearchBar) {
        searchBar.subviews.last?.subviews[1].backgroundColor = UIColor.HexToColor("#EFEFF4")
        searchBar.subviews.last?.subviews[1].layer.cornerRadius = 15.0
        searchBar.subviews.last?.subviews[1].layer.masksToBounds = true
    }
    
    static func configureSearchBar(searchBar: UISearchBar) {
        searchBar.placeholder = "Search"
        searchBar.tintColor = .black
        searchBar.barStyle = .default
        searchBar.searchBarStyle = .default
        searchBar.backgroundColor = UIColor.clear
        searchBar.backgroundImage = UIImage()
        searchBar.isTranslucent = true
        searchBar.clipsToBounds = true
        searchBar.barTintColor = UIColor(red255: 239, green255: 239, blue255: 244)
        searchBar.setTextFieldColor(color: UIColor(red255: 239, green255: 239, blue255: 244))
        searchBar.change(textFont: UIFont.helveticaRegualr(14))
        searchBar.barTintColor = UIColor.lightGray.withAlphaComponent(0.4)
        searchBar.cornerRadius = 15.0
        
        if let searchField = searchBar.value(forKey: "_searchField") as? UITextField  {
            searchField.textColor = UIColor(red255: 141, green255: 141, blue255: 142)
            if searchField.responds(to: #selector(setter: UITextField.attributedPlaceholder)) {
                let placeholder = "Search"
                let attributedString = NSMutableAttributedString(string: placeholder)
                let range = NSRange(location: 0, length: placeholder.count)
                let color = UIColor(red255: 141, green255: 141, blue255: 142)
                attributedString.addAttribute(NSForegroundColorAttributeName, value: color, range: range)
                searchField.attributedPlaceholder = attributedString
            }
        }
    }
    
    static func showSearchBar(searchBar: UISearchBar, navigationItem: UINavigationItem, newFrameWidth: CGFloat = 0) {
        navigationItem.setLeftBarButton(nil, animated: true)
        navigationItem.setRightBarButton(nil, animated: true)
        navigationItem.setHidesBackButton(true, animated: false)
        if (newFrameWidth != 0) {
            navigationItem.titleView?.frame = CGRect.init(x: (navigationItem.titleView?.frame.origin.x)!, y: (navigationItem.titleView?.frame.origin.y)!, width: newFrameWidth, height: (navigationItem.titleView?.frame.size.height)!)
        }
        
        UIView.animate(withDuration: 0.5, animations: {
            searchBar.showsCancelButton = true
        }, completion: { finished in
            searchBar.becomeFirstResponder()
        })
    }
    
    static func hideSearchBar(searchBar: UISearchBar, navigationItem: UINavigationItem, leftBar: UIBarButtonItem?, rightBar: UIBarButtonItem?) {
        
        UIView.animate(withDuration: 0.5, animations: {
            searchBar.showsCancelButton = false
        }, completion: { finished in
            searchBar.resignFirstResponder()
            if let left = leftBar{
                navigationItem.setLeftBarButton(left, animated: true)
            }
            if let right = rightBar{
                navigationItem.setRightBarButton(right, animated: true)
            }
        })
    }
    
    static func exploreStatusBar(placeholder: String) -> UISearchBar{
        let s = RoundedSearchBar()
        s.sizeToFit()
        s.translatesAutoresizingMaskIntoConstraints = true
        s.placeholder = placeholder
        s.tintColor = UIColor.HexToColor("#47678D")
        s.barStyle = .default
        s.searchBarStyle = .default
        s.clipsToBounds = true
        s.barTintColor = UIColor(red255: 239, green255: 239, blue255: 244)
        s.setTextFieldColor(color: UIColor(red255: 239, green255: 239, blue255: 244))
        s.change(textFont: UIFont.helveticaRegualr(14))
        s.barTintColor = UIColor.lightGray.withAlphaComponent(0.4)
        UIApplication.shared.statusBarStyle = .default
    
        //         Edit search field properties
        if let searchField = s.value(forKey: "_searchField") as? UITextField  {
            searchField.textColor = UIColor.black //UIColor(red255: 141, green255: 141, blue255: 142)
            if searchField.responds(to: #selector(setter: UITextField.attributedPlaceholder)) {
                let placeholder = placeholder
                let attributedString = NSMutableAttributedString(string: placeholder)
                let range = NSRange(location: 0, length: placeholder.characters.count)
                let color = UIColor(red255: 141, green255: 141, blue255: 142)
                attributedString.addAttribute(NSForegroundColorAttributeName, value: color, range: range)
                searchField.attributedPlaceholder = attributedString
            }
        }
        s.sizeToFit()
        return s
    }
    
    static func broadcastStatusBar(placeholder: String) -> UISearchBar{
        
        let lightColor = UIColor.white
        let textColor = Apperance.textGrayColor
        
        
        let s = UISearchBar()
        s.sizeToFit()
        s.placeholder = placeholder
        s.tintColor = lightColor
        s.barStyle = .default
        s.isTranslucent = true
        s.searchBarStyle = .minimal
        s.cornerRadius = 6
        s.clipsToBounds = true
        s.change(textFont: UIFont.robotoRegularFont(13))
        s.setTextFieldColor(color: lightColor)
        s.barTintColor = lightColor
        //         Edit search field properties
        if let searchField = s.value(forKey: "_searchField") as? UITextField  {
            searchField.textColor = textColor
            
            if searchField.responds(to: #selector(setter: UITextField.attributedPlaceholder)) {
                let placeholder = placeholder
                let attributedString = NSMutableAttributedString(string: placeholder)
                let range = NSRange(location: 0, length: placeholder.characters.count)
                let color = textColor.withAlphaComponent(0.5)
                attributedString.addAttribute(NSForegroundColorAttributeName, value: color, range: range)
                searchField.attributedPlaceholder = attributedString
            }
        }
        
        if #available(iOS 11.0, *){
            s.heightAnchor.constraint(equalToConstant: 44).isActive = true
        }
        return s
    }
    
    static func generateSnapShot(for videoUrl: URL) -> UIImage? {
        let asset = AVURLAsset(url: videoUrl)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        do {
            let imageRef = try generator.copyCGImage(at: kCMTimeZero, actualTime: nil)
            return UIImage(cgImage: imageRef)
        }
        catch let error as NSError
        {
            print("Image generation failed with error \(error)")
            return nil
        }
    }
    
    static func exportVideo(sourceUrl url: URL, completion: @escaping ((Media?) -> Void)) {
        let asset = AVAsset(url: url)
        
        let outputUrl = URL(fileURLWithPath: NSTemporaryDirectory().appending(Helper.generateString().appending("." + url.pathExtension)))
//
//        if let export = AVAssetExportSession(asset: asset, presetName: Constants.videoQuality) {
//            export.outputFileType = AVFileTypeMPEG4
//            export.shouldOptimizeForNetworkUse = true
//            export.outputURL = outputUrl
//            
//            
//            export.exportAsynchronously(completionHandler: {
//                if export.status == .completed, let media = Media.create(video: outputUrl) {
//                    completion(media)
//                } else {
//                    completion(nil)
//                }
//            })
//        }
        
        guard let encoder = SDAVAssetExportSession(asset: asset) else { completion(nil); return }
        
        guard let image = Helper.generateSnapShot(for: url) else { completion(nil); return }
        
        var size = image.size.aspectRatio(height: 640)
        if image.size.width > image.size.height {
            size = image.size.aspectRatio(width: 640)
        }
        
        encoder.outputFileType = AVFileTypeMPEG4
        encoder.outputURL = outputUrl
        encoder.videoSettings = [
            AVVideoCodecKey: AVVideoCodecH264,
            AVVideoWidthKey: size.width,
            AVVideoHeightKey: size.height,
            AVVideoCompressionPropertiesKey : [
                AVVideoAverageBitRateKey: 1200000,
                AVVideoProfileLevelKey: AVVideoProfileLevelH264High40
            ]
        ]
        
        encoder.audioSettings = [
            AVFormatIDKey: (kAudioFormatMPEG4AAC),
            AVNumberOfChannelsKey: 1,
            AVSampleRateKey: 44100,
            AVEncoderBitRateKey: 64000
        ]
        
        encoder.exportAsynchronously(completionHandler: {() -> Void in
            if encoder.status == .completed {
                if encoder.status == .completed, let media = Media.create(video: outputUrl) {
                    completion(media)
                } else {
                    completion(nil)
                }
            }
            else {
                completion(nil)
            }
            
        })
    }
    
    static func getVideoDuration(for videoUrl: URL) -> Double {
        let asset = AVAsset(url: videoUrl)
        
        return CMTimeGetSeconds(asset.duration)
    }
    
    static func alertAppearance(text: String) -> NSAttributedString {
        let attributedString = NSAttributedString(string: text, attributes: [
            NSFontAttributeName : UIFont.robotoMediumFont(15),
            NSForegroundColorAttributeName : UIColor(red255: 71, green255: 103, blue255: 141)
            ])
        
        return attributedString
    }
    
    static func getNormalFilter (_ filterName: String) -> CIFilter? {
        let filter = CIFilter(name: filterName )
        filter!.setDefaults()
        
        return filter
    }
    
    static func getVIVIDFilter(_ filterName: String) -> CIFilter? {
        var filter: CIFilter
        
        if filterName == Filter.toneCurve {
            filter = CIFilter(
                name: Filter.toneCurve,
                withInputParameters:[
                    "inputRGBCompositeControlPoints": [CIVector(x: 0, y: 0),CIVector(x: 0.5, y: 0.7), CIVector(x: 1, y: 1)]
                ])!
        } else {
            filter = CIFilter(name: filterName)!
        }
        
        return filter
    }
    
    static func getSkinFilter(_ filterName: String) -> CIFilter? {
        let filter = CIFilter(name: filterName)!
        filter.setValue(0.7, forKey: "inputAmount")
        
        return filter
    }
    
    static func secondsToMinutesSeconds (seconds : Int) -> (Int, Int) {
        return (seconds / 60, seconds % 60)
    }
}
