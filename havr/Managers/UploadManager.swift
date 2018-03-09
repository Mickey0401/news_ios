//
//  UploadManager.swift
//  havr
//
//  Created by Personal on 5/30/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import Foundation
import AWSS3
import SwiftyJSON
class UploadManager: NSObject {
    
    fileprivate static var aws : AWSS3TransferManager = {
        let region = AWSRegionType.CACentral1
        let provider = AWSStaticCredentialsProvider(accessKey: Constants.AWS_ACCESS_KEY_ID, secretKey: Constants.AWS_SECRET_ACCESS_KEY)
        
        let a = AWSServiceConfiguration(region: region, credentialsProvider: provider)
        
        AWSServiceManager.default().defaultServiceConfiguration = a
        
        return AWSS3TransferManager.default()
    }()
    
    fileprivate static var bucketName: String = Constants.AWS_S3_BUCKET_NAME
    
    static func upload(media: Media, completion: @escaping ((Media, Bool, HSError?) -> Void), progress: ((CGFloat)-> Void)? = nil) {
        
        let request: AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest()
        request.body = media.getAssetUrl()
        request.key = media.getName()
        request.contentType = media.getMimeType()
        request.bucket = bucketName
        
        request.uploadProgress = { unit, uploaded, total in
            let value: CGFloat = CGFloat(uploaded) / CGFloat(total)
            progress?(value)
        }
        
        print("Media UPLOADING: \(media.getName()) Length: \(OfflineFileManager.getResourceData(with: media.getAssetUrl())?.count ?? 0 ) bytes")
        aws.upload(request).continueWith { (task) -> Any? in
            if let error = task.error {
                print("Media FAILED: \(media.getName())")
                completion(media, false, HSError(message: error.localizedDescription, code: 400))
            } else {
                print("Media SUCCESS: \(media.getName())")
                completion(media, true, nil)
            }
            
            return nil
        }
    }
    
    static func uploadVideoImage(media: Media, completion: @escaping ((Media, Bool, HSError?) -> Void), progress: ((CGFloat)-> Void)? = nil) {
        
        let request: AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest()
        request.body = media.getImageAssetUrl()
        request.key = media.getVideoImageName()
        request.contentType = MimeType.get(extension: media.getImageAssetUrl().pathExtension)
        request.bucket = bucketName
        
        request.uploadProgress = { unit, uploaded, total in
            let value: CGFloat = CGFloat(uploaded) / CGFloat(total)
            progress?(value)
        }
        
        
        print("Media UPLOADING: \(media.getName()) Length: \(OfflineFileManager.getResourceData(with: media.getImageAssetUrl())?.count ?? 0 ) bytes")
        aws.upload(request).continueWith { (task) -> Any? in
            if let error = task.error {
                print("Media FAILED: \(media.getVideoImageName())")
                completion(media, false, HSError(message: error.localizedDescription, code: 400))
            } else {
                print("Media SUCCESS: \(media.getVideoImageName())")
                completion(media, true, nil)
            }
            
            return nil
        }
    }
    
    
}
