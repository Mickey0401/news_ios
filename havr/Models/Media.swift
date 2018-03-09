//
//  Media.swift
//  havr
//
//  Created by Personal on 5/30/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON
import Kingfisher
import Alamofire

enum UploadStatus: Int {
    case created = 0
    case uploading
    case uploaded
    case failed
}

enum MediaType {
    case image
    case video
    case gif
}

class Media: Object {
    dynamic var name: String = ""
    dynamic var ext: String = ""
    fileprivate var status: Int = 0
    
    
    dynamic var height: Int = 320
    dynamic var width: Int = 320
    
    dynamic var videoLength: Double = 0
    
    var progress: CGFloat = 0
    
    fileprivate var downloadRequest: DownloadRequest?
    
    var uploadStatus: UploadStatus {
        get {
            return UploadStatus.init(rawValue: status) ?? UploadStatus.created
        }
        set {
            status = newValue.rawValue
        }
    }
    
    var type: MediaType = .image
    
    var isLandscape: Bool{
        return width > height
    }
    
    func getName() -> String {
        return name + "." + ext
    }
    
    func getType() -> MediaType{
        if isVideo(){
            return .video
        }else if isGif(){
            return .gif
        }
        return .image
    }
    
    func getVideoImageName() -> String {
        return name + ".jpg"
    }
    func isImage() -> Bool{
        return ext == "jpg"
    }
    
    func isVideo() -> Bool {
        return ext == "mp4" || ext == "mov"
    }
    
    func isGif() -> Bool {
        return ext == "gif"
    }
    
    func isAudio() -> Bool {
        return ext == "m4a"
    }
    
    func getUrl() -> URL {
        let u = URL(string: Constants.resourceUrl.appending(getName()))!
        return u
    }
    
    func getImageUrl() -> URL {
        if isVideo() {
            let u = URL(string: Constants.resourceUrl.appending(getVideoImageName()))!
            return u
        } else {
            return getUrl()
        }
    }
    
    func getMimeType() -> String {
        return MimeType.get(extension: ext)
    }
    
    func getAbsolute() -> String {
        return getUrl().absoluteString
    }
    
    func getAssetUrl() -> URL {
        return OfflineFileManager.getResourceUrl(with: getName())
    }
    
    func getImageAssetUrl() -> URL {
        return OfflineFileManager.getResourceUrl(with: getVideoImageName())
    }
    
    func getAssetData() -> Data? {
        return OfflineFileManager.getResourceData(with: getAssetUrl())
    }
    
    func getSize() -> CGSize {
        return CGSize(width: width, height: height)
    }
    
    var existsInAssets: Bool {
        return getAssetData() != nil
    }
    
    func upload(deleteOnUpload: Bool = false, completion: @escaping ((Media,Bool,ErrorMessage?) -> Void), progress: ((CGFloat)-> Void)? = nil) {
        
        if uploadStatus == .uploading {
            return
        }
        
        self.uploadStatus = .uploading
        
        if isVideo() {
            UploadManager.uploadVideoImage(media: self, completion: { (media, success, error) in
                if success {
                    print("Video image is uploaded")
                } else {
                    print("Video image failed")
                }
            })
        }
        
        UploadManager.upload(media: self, completion: { (media, success, error) in
            if success {
                media.uploadStatus = .uploaded
                completion(media,true,nil)
                
                if deleteOnUpload {
                    OfflineFileManager.remove(with: media.getAssetUrl())
                }
                
            } else {
                media.uploadStatus = .failed
                completion(media,false,error?.message)
            }
        }) { (uploadedProgress) in
            self.progress = uploadedProgress
            progress?(uploadedProgress)
        }
    }
    
    func download(completion: @escaping ((Success, Error?) -> Void), progress: ((Double) -> Void)? = nil) {
        
        if existsInAssets {
            completion(true, nil)
            return
        }
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            return (self.getAssetUrl(), [.removePreviousFile, .createIntermediateDirectories])
        }
        
        downloadRequest = Alamofire.download(getUrl(), to: destination)
            .downloadProgress(closure: { (progressF) in
                progress?(progressF.fractionCompleted)
            })
            .response(completionHandler: { (response) in
                if let videoUrl = response.destinationURL {
                    completion(true, nil)
                } else {
                    completion(false, response.error)
                }
            })
    }
    
    func cancelDownload() {
        downloadRequest?.cancel()
    }
    
    static func create(fromEvent json: JSON) -> Media? {
        if let photo = json["photo"].string, let url = URL(string: photo) {
            let lastPath = url.lastPathComponent
            let ext = url.pathExtension
            
            let name = lastPath.replacingOccurrences(of: "." + ext, with: "")
            
            let media = Media()
            media.name = name
            media.ext = ext
            
            media.width = 640
            media.height = 640
            media.uploadStatus = .uploaded
            
            if media.isVideo() {
                media.videoLength = json["length"].double ?? 0
            }
            
            return media
        }
        
        return nil
    }
    
    static func create(fromComment json: JSON) -> Media? {
        if let photo = json["photo"].string, let url = URL(string: photo) {
            let lastPath = url.lastPathComponent
            let ext = url.pathExtension
            
            let name = lastPath.replacingOccurrences(of: "." + ext, with: "")
            
            let media = Media()
            media.name = name
            media.ext = ext
            
            media.width = 640
            media.height = 640
            media.uploadStatus = .uploaded
            
            if media.isVideo() {
                media.videoLength = json["length"].double ?? 0
            }
            
            return media
        }
        
        return nil
    }
    
    static func create(from jsonPost: JSON) -> Media? {
        if let content = jsonPost["content"].string, let url = URL(string: content) {
            let lastPath = url.lastPathComponent
            let ext = url.pathExtension
            
            let name = lastPath.replacingOccurrences(of: "." + ext, with: "")
            
            let media = Media()
            media.name = name
            media.ext = ext
            
            media.width = jsonPost["width"].int ?? 640
            media.height = jsonPost["height"].int ?? 640
            
            media.videoLength = jsonPost["length"].double ?? 0
            
            media.uploadStatus = .uploaded
            
            return media
        }
        
        return nil
    }
    static func create(fromPostEvent json: JSON) -> Media? {
        if let content = json["url"].string, let url = URL(string: content) {
            let lastPath = url.lastPathComponent
            let ext = url.pathExtension
            
            let name = lastPath.replacingOccurrences(of: "." + ext, with: "")
            
            let media = Media()
            media.name = name
            media.ext = ext
            
            media.width = json["width"].int ?? 640
            media.height = json["height"].int ?? 640
            
            if media.isVideo() {
                media.videoLength = json["length"].double ?? 0
            }
            
            media.uploadStatus = .uploaded
            
            return media
        }
        
        return nil
    }
    
    
    static func create(for image: UIImage, with ext: String = "jpg") -> Media {
        let m = Media()
        m.name = Helper.generateString()
        m.ext = ext
        m.width = Int(image.size.width)
        m.height = Int(image.size.height)
        
        let imageData = image.kf.jpegRepresentation(compressionQuality: Constants.imageCompressionRation)!
        
        OfflineFileManager.store(object: imageData, at: m.getAssetUrl())
        
        let imageCache = ImageCache.default
        imageCache.store(image, forKey: m.getAbsolute())
        
        return m
    }
    
    static func create(video tempUrl: URL) -> Media? {
        let m = Media()
        m.name = Helper.generateString()
        
        let ext = tempUrl.pathExtension
        m.ext = ext
        
        if let image = Helper.generateSnapShot(for: tempUrl) {
            print("Video Image Generated: \(m.getImageAssetUrl())")
            
            let resizedImage = image.resizePostImage()
            let imageData = resizedImage.kf.jpegRepresentation(compressionQuality: Constants.imageCompressionRation)!
            
            OfflineFileManager.store(object: imageData, at: m.getImageAssetUrl())
            m.width = Int(image.size.width)
            m.height = Int(image.size.height)
        }
        
        m.videoLength = Helper.getVideoDuration(for: tempUrl)
        
        if let videoData = OfflineFileManager.getResourceData(with: tempUrl) {
            if OfflineFileManager.store(object: videoData, at: m.getAssetUrl()) {
                print("Video Generated: \(m.getAssetUrl())")
                return m
            }
        }
        return m
    }
    
    static func create(gif: URL, with ext: String = "gif") -> Media? {
        let m = Media()
        m.name = Helper.generateString()
        
        let ext = gif.pathExtension
        m.ext = ext
    
        if let image = Helper.generateSnapShot(for: gif) {
            print("Gif Image Generated: \(m.getImageAssetUrl())")
            
            let resizedImage = image.resizePostImage()
            let imageData = resizedImage.kf.jpegRepresentation(compressionQuality: Constants.imageCompressionRation)!
            
            OfflineFileManager.store(object: imageData, at: m.getImageAssetUrl())
//            m.width = Int(image.size.width)
//            m.height = Int(image.size.height)
        }
        m.width = 640//Int(image.size.width)
        m.height = 640//Int(image.size.height)
        
        if let videoData = OfflineFileManager.getResourceData(with: gif) {
            if OfflineFileManager.store(object: videoData, at: m.getAssetUrl()) {
                print("Gif Generated: \(m.getAssetUrl())")
                return m
            }
        }
        return m
    }
    
    static func create(audioUrl url: URL) -> Media? {
        let m = Media()
        m.name = Helper.generateString()
        
        let ext = url.pathExtension
        m.ext = ext
        
        
        let asset = AVURLAsset(url: url)
        m.videoLength = Double(CMTimeGetSeconds(asset.duration))
        
        if let videoData = OfflineFileManager.getResourceData(with: url) {
            if OfflineFileManager.store(object: videoData, at: m.getAssetUrl()) {
                print("Audio Generated: \(m.getAssetUrl())")
                return m
            }
        }
        return m
    }
    
}
