//
//  ViewWithAttributes.swift
//  SalesApp
//
//  Created by Ismajl Marevci on 8/15/16.
//  Copyright © 2016 Tenton. All rights reserved.
//

import UIKit
import Kingfisher
import AVFoundation
import MBProgressHUD
import ImageIO

let months = [ "January", "February", "March", "April","May", "June", "July","August","September","October","November","December"]

extension UIView {
    
    static func load(fromNib nibName: String) -> UIView {
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    func bubble(scale transform: CGFloat = 1.15, with time: Double = 0.05) -> Void {
        delay(delay: 0) { 
            UIView.animate(withDuration: time, animations: {
                self.transform = CGAffineTransform(scaleX: transform, y: transform)
            }) { (completed) in
                if completed {
                    UIView.animate(withDuration: time, animations: {
                        self.transform = CGAffineTransform.identity
                    }, completion: nil)
                }
            }
        }
    }
}
@IBDesignable extension UIView {
    @IBInspectable var borderColor:UIColor? {
        set {
            layer.borderColor = newValue!.cgColor
        }
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor:color)
            }
            else {
                return nil
            }
        }
    }
    @IBInspectable var borderWidth:CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    @IBInspectable var cornerRadius:CGFloat {
        set {
            layer.cornerRadius = newValue
            clipsToBounds = newValue > 0
        }
        get {
            return layer.cornerRadius
        }
    }
    
    func roundCorners(_ corners:UIRectCorner, radius: CGFloat) {
        
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.frame.width, height: 2000), byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
        layoutIfNeeded()
    }
    @IBInspectable var shadowColor : UIColor? {
        set {
            layer.shadowColor = newValue!.cgColor
        }
        get{
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }else {
                return nil
            }
        }
    }
    
    @IBInspectable var shadowOpacity: Float {
        set {
            layer.shadowOpacity = newValue
            clipsToBounds = newValue > 0
            
        }get {
            return layer.shadowOpacity
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat {
        set {
            layer.shadowRadius = newValue
            clipsToBounds = newValue > 0
        }
        get {
            return layer.shadowRadius
        }
    }
    
    
    @IBInspectable var shadowOffset : CGSize {
        set {
            layer.shadowOffset = newValue
        }
        get {
            return layer.shadowOffset
        }
    }
    
    @IBInspectable var masksToBounds: Bool {
        set {
            layer.masksToBounds = newValue
        }
        get {
            return layer.masksToBounds
        }
    }
    
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
}
extension UIImageView{
    
    func makeBlurImage(_ targetImageView:UIImageView?)
    {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = targetImageView!.bounds
        blurEffectView.alpha = 1
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        targetImageView?.addSubview(blurEffectView)
    }
    
    func applyBlurEffect(_ targetImageView:UIImageView?, image: UIImage){
        let imageToBlur = CIImage(image: image)
        let blurfilter = CIFilter(name: "CIGaussianBlur")
        blurfilter!.setValue(6, forKey: kCIInputRadiusKey)
        blurfilter!.setValue(imageToBlur, forKey: "inputImage")
        let resultImage = blurfilter!.value(forKey: "outputImage") as! CIImage
        var blurredImage = UIImage(ciImage: resultImage)
        let cropped:CIImage=resultImage.cropping(to: CGRect(x: 0, y: 0,width: imageToBlur!.extent.size.width, height: imageToBlur!.extent.size.height))
        blurredImage = UIImage(ciImage: cropped)
        targetImageView!.image = blurredImage
    }
    func setTintImage(_ color: UIColor) {
        if(self.image == nil){
            return
        }
        self.tintColor = color
        self.image = self.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
    }
}

extension UIImage{
    class func colorForNavBar(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    convenience init(view: UIView) {
        
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: image!.cgImage!)
    }
    
    class func renderUIViewToImage(_ viewToBeRendered:UIView?) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions((viewToBeRendered?.bounds.size)!, false, 0.0)
        viewToBeRendered!.drawHierarchy(in: viewToBeRendered!.bounds, afterScreenUpdates: true)
        viewToBeRendered!.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return finalImage!
    }
    
    class func rotateCameraImageToProperOrientation(_ imageSource : UIImage, maxResolution : CGFloat) -> UIImage {
        
        let imgRef = imageSource.cgImage!
        
        let width = CGFloat(imgRef.width);
        let height = CGFloat(imgRef.height);
        
        var bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        var scaleRatio : CGFloat = 1
        if (width > maxResolution || height > maxResolution) {
            
            scaleRatio = min(maxResolution / bounds.size.width, maxResolution / bounds.size.height)
            bounds.size.height = bounds.size.height * scaleRatio
            bounds.size.width = bounds.size.width * scaleRatio
        }
        
        var transform = CGAffineTransform.identity
        let orient = imageSource.imageOrientation
        let imageSize = CGSize(width: CGFloat(imgRef.width), height: CGFloat(imgRef.height))
        
        
        switch(imageSource.imageOrientation) {
        case .up :
            transform = CGAffineTransform.identity
            
        case .upMirrored :
            transform = CGAffineTransform(translationX: imageSize.width, y: 0.0);
            transform = transform.scaledBy(x: -1.0, y: 1.0);
            
        case .down :
            transform = CGAffineTransform(translationX: imageSize.width, y: imageSize.height);
            transform = transform.rotated(by: CGFloat(Double.pi));
            
        case .downMirrored :
            transform = CGAffineTransform(translationX: 0.0, y: imageSize.height);
            transform = transform.scaledBy(x: 1.0, y: -1.0);
            
        case .left :
            let storedHeight = bounds.size.height
            bounds.size.height = bounds.size.width;
            bounds.size.width = storedHeight;
            transform = CGAffineTransform(translationX: 0.0, y: imageSize.width);
            transform = transform.rotated(by: 3.0 * CGFloat(Double.pi) / 2.0);
            
        case .leftMirrored :
            let storedHeight = bounds.size.height
            bounds.size.height = bounds.size.width;
            bounds.size.width = storedHeight;
            transform = CGAffineTransform(translationX: imageSize.height, y: imageSize.width);
            transform = transform.scaledBy(x: -1.0, y: 1.0);
            transform = transform.rotated(by: 3.0 * CGFloat(Double.pi) / 2.0);
            
        case .right :
            let storedHeight = bounds.size.height
            bounds.size.height = bounds.size.width;
            bounds.size.width = storedHeight;
            transform = CGAffineTransform(translationX: imageSize.height, y: 0.0);
            transform = transform.rotated(by: CGFloat(Double.pi) / 2.0);
            
        case .rightMirrored :
            let storedHeight = bounds.size.height
            bounds.size.height = bounds.size.width;
            bounds.size.width = storedHeight;
            transform = CGAffineTransform(scaleX: -1.0, y: 1.0);
            transform = transform.rotated(by: CGFloat(Double.pi) / 2.0);
        }
        
        UIGraphicsBeginImageContext(bounds.size)
        let context = UIGraphicsGetCurrentContext()
        
        if orient == .right || orient == .left {
            context!.scaleBy(x: -scaleRatio, y: scaleRatio);
            context!.translateBy(x: -height, y: 0);
        } else {
            context!.scaleBy(x: scaleRatio, y: -scaleRatio);
            context!.translateBy(x: 0, y: -height);
        }
        
        context!.concatenate(transform);
        UIGraphicsGetCurrentContext()!.draw(imgRef, in: CGRect(x: 0, y: 0, width: width, height: height));
        
        let imageCopy = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return imageCopy!;
    }
    func convertImage(_ rect : CGRect) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    func cropImage(toRect rect:CGRect) -> UIImage? {
        var rect = rect
        rect.origin.y = rect.origin.y * self.scale
        rect.origin.x = rect.origin.x * self.scale
        rect.size.width = rect.width * self.scale
        rect.size.height = rect.height * self.scale
        
        guard let imageRef = self.cgImage?.cropping(to: rect) else {
            return nil
        }
        
        let croppedImage = UIImage(cgImage:imageRef)
        return croppedImage
    }
    
    func cropToPreviewLayer(previewLayer: AVCaptureVideoPreviewLayer, rect: CGRect) -> UIImage {
        
        let outputRect = previewLayer.metadataOutputRectOfInterest(for: rect)
        var cgImage = self.cgImage!
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        let cropRect = CGRect(x: outputRect.origin.x * width, y: outputRect.origin.y * height, width: outputRect.size.width * width, height: outputRect.size.height * height)
        
        cgImage = cgImage.cropping(to: cropRect)!
        
        
        var orientation = self.imageOrientation
        
        if UIDevice.current.orientation == .landscapeLeft {
            orientation = .up
        } else if UIDevice.current.orientation == .landscapeRight {
            orientation = .downMirrored
        }
        
        let croppedUIImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: orientation)
        
        return croppedUIImage
    }
    class func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 0.5)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
}
extension CGSize {
    func getSizeByWidth(_ width: CGFloat, maxHeight: CGFloat = 1000) -> CGSize {
        var height = width / self.width * self.height
        height = height > maxHeight ? maxHeight : height
        return CGSize(width: width, height: height)
    }
    func getSizeByHeight(_ height: CGFloat, maxWidth: CGFloat = 1000) -> CGSize {
        var width = height / self.height * self.width
        width = width > maxWidth ? maxWidth : width
        return CGSize(width: width, height: height)
    }
    func getSizeByRatio(_ width: CGFloat) -> CGSize {
        if self.height / self.width >= 1.70 && self.height / self.width <= 1.90 {
            return CGSize(width: width, height: width * 1.77)
        }
        else{
            return CGSize(width: width, height: width * 1.33)
        }
    }
    func aspectRatio(width: CGFloat) -> CGSize {
        return CGSize(width: width, height: width / self.width * height)
    }
    
    func aspectRatio(height: CGFloat) -> CGSize {
        return CGSize(width: height / self.height * width, height: height)
    }
}

extension Double {
    var toPercentage : String {
        let v = String(format: "%.0f", self)
        
        return v + " %"
    }
    
    func toCurrency(symbol: String) -> String {
        let v = String(format: "%.2f", self)
        
        return v + " " + symbol
    }
    
    /// Rounds the double to decimal places value
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    func toTimeLeftVideo(currentSeconds: Double) -> String{
        let currentSeconds = self - currentSeconds
        let mins: Int = Int(currentSeconds / 60.0)
        let secs = fmodf(Float(currentSeconds), 60.0);
        let minsString = mins < 10 ? "0\(mins)" : "\(mins)"
        let secsString = secs < 10 ? "0\(Int(secs))" : "\(Int(secs))"
        return minsString + ":" + secsString
    }
}

public extension String {
    
    func stringByReplacingFirstOccurrenceOfString(_ target: String, withString replaceString: String) -> String {
        if let range = self.range(of: target) {
            return self.replacingCharacters(in: range, with: replaceString)
        }
        return self
    }
    func toDouble() -> Double? {
        let s = self.replacingOccurrences(of: ",", with: ".")
        let string = NSString(string: s)
        return string.doubleValue
    }
    static func localized(_ key: String?) -> String{
        var localizedString = ""
        
        if (key == nil) {
            return localizedString
        }
        if key!.isEmpty {
            return localizedString
        }
        localizedString = NSLocalizedString(key!, comment: "")
        if !localizedString.isEmpty{
            return localizedString
        }
        return localizedString
    }
    var trim : String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    var isEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
}
extension UIImageView {
    
    public func loadGif(name: String) {
        DispatchQueue.global().async {
            let image = UIImage.gif(name: name)
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }
}

extension UIImage {
    
    public class func gif(data: Data) -> UIImage? {
        // Create source from data
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            print("SwiftGif: Source for the image does not exist")
            return nil
        }
        
        return UIImage.animatedImageWithSource(source)
    }
    
    public class func gif(url: String) -> UIImage? {
        // Validate URL
        guard let bundleURL = URL(string: url) else {
            print("SwiftGif: This image named \"\(url)\" does not exist")
            return nil
        }
        
        // Validate data
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(url)\" into NSData")
            return nil
        }
        
        return gif(data: imageData)
    }
    
    public class func gif(name: String) -> UIImage? {
        // Check for existance of gif
        guard let bundleURL = Bundle.main
            .url(forResource: name, withExtension: "gif") else {
                print("SwiftGif: This image named \"\(name)\" does not exist")
                return nil
        }
        
        // Validate data
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
            return nil
        }
        
        return gif(data: imageData)
    }
    
    internal class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1
        
        // Get dictionaries
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifPropertiesPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 0)
        if CFDictionaryGetValueIfPresent(cfProperties, Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque(), gifPropertiesPointer) == false {
            return delay
        }
        
        let gifProperties:CFDictionary = unsafeBitCast(gifPropertiesPointer.pointee, to: CFDictionary.self)
        
        // Get delay time
        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties,
                                 Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                                                             Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }
        
        delay = delayObject as? Double ?? 0
        
        if delay < 0.1 {
            delay = 0.1 // Make sure they're not too fast
        }
        
        return delay
    }
    
    internal class func gcdForPair(_ a: Int?, _ b: Int?) -> Int {
        var a = a
        var b = b
        // Check if one of them is nil
        if b == nil || a == nil {
            if b != nil {
                return b!
            } else if a != nil {
                return a!
            } else {
                return 0
            }
        }
        
        // Swap for modulo
        if a! < b! {
            let c = a
            a = b
            b = c
        }
        
        // Get greatest common divisor
        var rest: Int
        while true {
            rest = a! % b!
            
            if rest == 0 {
                return b! // Found it
            } else {
                a = b
                b = rest
            }
        }
    }
    
    internal class func gcdForArray(_ array: Array<Int>) -> Int {
        if array.isEmpty {
            return 1
        }
        
        var gcd = array[0]
        
        for val in array {
            gcd = UIImage.gcdForPair(val, gcd)
        }
        
        return gcd
    }
    
    internal class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()
        
        // Fill arrays
        for i in 0..<count {
            // Add image
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(image)
            }
            
            // At it's delay in cs
            let delaySeconds = UIImage.delayForImageAtIndex(Int(i),
                                                            source: source)
            delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
        }
        
        // Calculate full duration
        let duration: Int = {
            var sum = 0
            
            for val: Int in delays {
                sum += val
            }
            
            return sum
        }()
        
        // Get frames
        let gcd = gcdForArray(delays)
        var frames = [UIImage]()
        
        var frame: UIImage
        var frameCount: Int
        for i in 0..<count {
            frame = UIImage(cgImage: images[Int(i)])
            frameCount = Int(delays[Int(i)] / gcd)
            
            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }
        
        // Heyhey
        let animation = UIImage.animatedImage(with: frames,
                                              duration: Double(duration) / 1000.0)
        
        return animation
    }
}

extension UIColor{
    static func HexToColor(_ hexString: String, alpha:CGFloat? = 1.0) -> UIColor {
        // Convert hex string to an integer
        let hexint = Int(self.intFromHexString(hexString))
        let red = CGFloat((hexint & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hexint & 0xff00) >> 8) / 255.0
        let blue = CGFloat((hexint & 0xff) >> 0) / 255.0
        let alpha = alpha!
        // Create color object, specifying alpha as well
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }
    
    static func intFromHexString(_ hexStr: String) -> UInt32 {
        var hexInt: UInt32 = 0
        // Create scanner
        let scanner: Scanner = Scanner(string: hexStr)
        // Tell scanner to skip the # character
        scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
        // Scan hex value
        scanner.scanHexInt32(&hexInt)
        return hexInt
    }
    
    convenience init(red255: CGFloat, green255: CGFloat, blue255: CGFloat, alpha255 : CGFloat = 255) {
        self.init(red: red255 / 255, green: green255 / 255, blue: blue255 / 255, alpha: alpha255 / 255)
    }
    
    convenience init(hex:Int, alpha: CGFloat = 1.0) {
        self.init(red:CGFloat((hex >> 16) & 0xff), green:CGFloat((hex >> 8) & 0xff), blue:CGFloat(hex & 0xff), alpha: alpha)
    }
}

extension UIColor {
    static var lightGrayBorder: UIColor {
        return UIColor(red255: 241, green255: 241, blue255: 243, alpha255: 200)
    }
    
    static var facebookButton: UIColor {
        return UIColor(red255: 61, green255: 89, blue255: 155)
    }
    
    static var gray70: UIColor {
        return UIColor(red255: 70, green255: 70, blue255: 70)
    }
}

extension UINavigationBar {
    
    func setBottomBorderColor(color: UIColor, height: CGFloat) {
        let bottomBorderRect = CGRect(x: 0, y: frame.height - 2, width: frame.width - 100, height: height)
        let bottomBorderView = UIView(frame: bottomBorderRect)
        bottomBorderView.backgroundColor = color
        addSubview(bottomBorderView)
    }
}

struct Number {
    static let formatterWithSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ","
        formatter.numberStyle = .decimal
        return formatter
    }()
}
extension Integer {
    var stringFormattedWithSeparator: String {
        return Number.formatterWithSeparator.string(from: self as! NSNumber) ?? ""
    }
}
extension Int {
    var abbreviated: String {
        let abbrev = "KMBTPE"
        return abbrev.characters.enumerated().reversed().reduce(nil as String?) { accum, tuple in
            let factor = Double(self) / pow(10, Double(tuple.0 + 1) * 3)
            let format = (factor.truncatingRemainder(dividingBy: 1)  == 0 ? "%.0f%@" : "%.1f%@")
            return accum ?? (factor > 1 ? String(format: format, factor, String(tuple.1)) : nil)
            } ?? String(self)
    }
    var toString : String? {
        get{
            return String(self)
        }
    }
    
    var toBool : Bool? {
        get{
            if(self == 0){
                return false
            }else if(self == 1){
                return true
            }else{
                return nil
            }
        }
    }
}

extension UIScrollView {
    var currentPage:Int{
        return Int((self.contentOffset.x+(0.5*self.frame.size.width))/self.frame.width)
    }
}

extension UINavigationItem {
    func setNavBarWithBlack(title: String, subTitle: String?) {
        setNavBar(isWhite: false, title: title, subTitle: subTitle)
    }
    func setNavBarWithWhite(title: String, subTitle: String?) {
        setNavBar(isWhite: true, title: title, subTitle: subTitle)
    }
    private func setNavBar(isWhite: Bool, title: String, subTitle: String?){
        let color = isWhite ? .white : UIColor.black
        if let subTitle = subTitle {
            
            let titleName: String  = ("\(title)\n\(subTitle)")
            var attributedString = NSMutableAttributedString()
            
            let titleRange = NSRange.init(location: 0, length: title.characters.count)
            let subtitleRange = NSRange.init(location: title.characters.count, length: titleName.characters.count - title.characters.count)
            
            attributedString = NSMutableAttributedString(string: titleName)
            attributedString.addAttribute(NSFontAttributeName, value: UIFont.navigationTitleFont, range: NSRange(location: 0, length: title.characters.count))
            attributedString.addAttribute(NSFontAttributeName, value: UIFont.sfProDisplayMediumFont(12.0), range: NSRange(location:title.characters.count, length: titleName.characters.count - title.characters.count))
            
            attributedString.addAttribute(NSForegroundColorAttributeName, value: color, range: titleRange)
            attributedString.addAttribute(NSForegroundColorAttributeName, value: color.withAlphaComponent(0.3), range: subtitleRange)
            
            let label = UILabel()
            label.backgroundColor = UIColor.clear
            label.numberOfLines = 2
            label.textAlignment = .center
            label.attributedText = attributedString
            label.sizeToFit()
            label.layoutIfNeeded()
            self.titleView = label
        } else {
            self.title = title
        }
    }
}
extension UILabel {
    func setComment(title: String, subTitle: String) {
        
        let titleName: String  = ("\(title)  \(subTitle)")
        var titleChange = NSMutableAttributedString()
        
        titleChange = NSMutableAttributedString(string: titleName)
        titleChange.addAttribute(NSFontAttributeName, value: UIFont.sfProDisplayMediumFont(14.0), range: NSRange(location: 0, length: title.count))
        titleChange.addAttribute(NSFontAttributeName, value: UIFont.sfProDisplayMediumFont(14.0), range: NSRange(location:title.count, length: titleName.characters.count - title.characters.count))
        
        self.attributedText = titleChange
    }
    
    func setChatRoomPost(title: String?, subTitle: String?) {
        var titleChange = NSMutableAttributedString()

        var titleName: String = title ?? ""
        if let sub = subTitle{
            if title != "" {
                if sub != "" {
                    titleName.append("\n\n")
                }
            }
            titleName.append("\(sub)")
        }
        
        let count = title?.count ?? 0
        
        titleChange = NSMutableAttributedString(string: titleName)
        titleChange.addAttribute(NSFontAttributeName, value: UIFont.sfProDisplayMediumFont(14.0), range: NSRange(location: 0, length: count))
        titleChange.addAttribute(NSFontAttributeName, value: UIFont.sfProDisplayMediumFont(14.0), range: NSRange(location: count, length: titleName.characters.count - count))
        
        self.attributedText = titleChange
    }
    
    func notificationTitle(title: String, subTitle: String) {
        
        let titleName: String  = ("\(title) \(subTitle)")
        var titleChange = NSMutableAttributedString()
        
        titleChange = NSMutableAttributedString(string: titleName)
        titleChange.addAttribute(NSFontAttributeName, value: UIFont.sfProDisplayMediumFont(14.0), range: NSRange(location: 0, length: title.characters.count))
        titleChange.addAttribute(NSFontAttributeName, value: UIFont.sfProDisplayMediumFont(14.0), range: NSRange(location:title.characters.count, length: titleName.characters.count - title.characters.count))
        
        self.attributedText = titleChange
    }
    
    func notificationTitleRegular(title: String, subTitle: String) {
        
        let titleName: String  = ("\(title) \(subTitle)")
        var titleChange = NSMutableAttributedString()
        
        titleChange = NSMutableAttributedString(string: titleName)
        titleChange.addAttribute(NSFontAttributeName, value: UIFont.sfProDisplayMediumFont(14.0), range: NSRange(location: 0, length: title.characters.count))
        titleChange.addAttribute(NSFontAttributeName, value: UIFont.sfProDisplayMediumFont(14.0), range: NSRange(location:title.characters.count, length: titleName.characters.count - title.characters.count))
        
        self.attributedText = titleChange
    }
}

extension UIWindow {
    func set(root: UIViewController)  {
        //        let root = StoryboardManager.get(storyboard: root).instantiateInitialViewController()
        let transition = CATransition()
        transition.type = kCATransitionFade
        self.setRootViewController(newRootViewController: root, transition: transition)
        self.makeKeyAndVisible()
    }
    
    private func setRootViewController(newRootViewController: UIViewController, transition: CATransition? = nil) {
        let previousViewController = rootViewController
        
        if let transition = transition {
            // Add the transition
            layer.add(transition, forKey: kCATransition)
        }
        
        rootViewController = newRootViewController
        
        // Update status bar appearance using the new view controllers appearance - animate if needed
        if UIView.areAnimationsEnabled {
            UIView.animate(withDuration: CATransaction.animationDuration()) {
                newRootViewController.setNeedsStatusBarAppearanceUpdate()
            }
        } else {
            newRootViewController.setNeedsStatusBarAppearanceUpdate()
        }
        
        /// The presenting view controllers view doesn't get removed from the window as its currently transistioning and presenting a view controller
        if let transitionViewClass = NSClassFromString("UITransitionView") {
            for subview in subviews where subview.isKind(of: transitionViewClass) {
                subview.removeFromSuperview()
            }
        }
        if let previousViewController = previousViewController {
            // Allow the view controller to be deallocated
            previousViewController.dismiss(animated: false) {
                // Remove the root view in case its still showing
                previousViewController.view.removeFromSuperview()
            }
        }
    }
}
extension UIApplication {
    func presentedController() -> UIViewController? {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            // topController should now be your topmost view controller
            
            return topController
        }
        
        return nil
    }
}

extension MBProgressHUD {
    static func showToView(_ view: UIView, animated: Bool) -> MBProgressHUD{
        let hud = MBProgressHUD.showAdded(to: view, animated: animated)
        hud.bezelView.backgroundColor = UIColor.clear
        //hud.activityIndicatorColor = Constants.loaderActivityIndicatorColor
        
        return hud
    }
    
    static func showAlert(view: UIView, text: String = "Done", image: UIImage = #imageLiteral(resourceName: "check-mark"), hideAfter: Double = 1.5) {
        let doneHUD =  MBProgressHUD.showAdded(to: view, animated: true)
        let doneImageView = UIImageView(image: image)
        doneHUD.customView = doneImageView
        doneHUD.label.text = text
        doneHUD.label.numberOfLines = 3
        doneHUD.mode = .customView
        doneHUD.hide(animated: true, afterDelay: hideAfter)
    }
    
    static func showWithStatus(view: UIView, text: String, image: UIImage, hideAfter: Double = 1.0) {
        let doneHUD =  MBProgressHUD.showAdded(to: view, animated: true)
        let doneImageView = UIImageView(image: image)
        doneHUD.customView = doneImageView
        doneHUD.label.text = text
        doneHUD.label.textColor = UIColor.white
        doneHUD.label.numberOfLines = 3
        doneHUD.mode = .customView
        doneHUD.hide(animated: true, afterDelay: hideAfter)
    }
    
    static func showIndicator(view: UIView) -> MBProgressHUD {
        let hud = MBProgressHUD.showToView(view, animated: true)
        hud.backgroundView.color = UIColor.black.withAlphaComponent(0.7)
        hud.bezelView.style = .solidColor
        hud.bezelView.color = UIColor.clear
        hud.contentColor = UIColor.white
        return hud
    }
}

extension UISearchBar {
    
    private func getViewElement<T>(type: T.Type) -> T? {
        
        let svs = subviews.flatMap { $0.subviews }
        guard let element = (svs.filter { $0 is T }).first as? T else { return nil }
        return element
    }
    
    func setTextFieldColor(color: UIColor) {
        
        if let textField = getViewElement(type: UITextField.self) {
            switch searchBarStyle {
            case .minimal:
                textField.layer.backgroundColor = color.cgColor
//                textField.layer.cornerRadius = 15

                
            case .prominent, .default:
                textField.backgroundColor = color
            }
        }
    }
    func change(textFont : UIFont?) {
        
        for view : UIView in (self.subviews[0]).subviews {
            
            if let textField = view as? UITextField {
                textField.font = textFont
            }
        }
    }
    
    func setAligment(aligment: NSTextAlignment) {
        for view : UIView in (self.subviews[0]).subviews {
            
            if let textField = view as? UITextField {
                textField.textAlignment = aligment
            }
        }
    }
}

extension Array{
    mutating func delete<U: Equatable>(_ element: U) -> Bool {
        for (idx, objectToCompare) in self.enumerated() {
            if let to = objectToCompare as? U {
                if element == to {
                    remove(at: idx)
                    return true
                }
            }
        }
        return false
    }
}

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}

extension CMTime{
    func getStringValue() -> String {
        let currentSeconds = CMTimeGetSeconds(self)
        let mins: Int = Int(currentSeconds / 60.0)
        let secs = fmodf(Float(currentSeconds), 60.0);
        let minsString = mins < 10 ? "0\(mins)" : "\(mins)"
        let secsString = secs < 10 ? "0\(Int(secs))" : "\(Int(secs))"
        return minsString + ":" + secsString
    }
}

extension UIActivityIndicatorView {
    func hide() {
        self.isHidden = true
        self.stopAnimating()
    }
    func show() {
        self.isHidden = false
        self.startAnimating()
    }
}

extension UIApplication {
    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }
}
