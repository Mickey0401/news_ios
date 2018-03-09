//
//  VideoEditor.swift
//  havr
//
//  Created by Personal on 7/16/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation


class VideoEditor: NSObject {
    
    fileprivate var recorded: Media
    
    init(recorded media: Media) {
        self.recorded = media
        super.init()
    }
    
    fileprivate var thumbnailAsset: AVAsset!
    fileprivate var backgroundAsset: AVAsset!
    
    func create(image media: Media, completion: @escaping ((Media?) -> Void)) {
        thumbnailAsset = AVAsset(url: recorded.getAssetUrl())
        self.thumbnailAsset.loadValuesAsynchronously(forKeys: ["playable", "tracks","duration"]) {
            if self.thumbnailAsset.tracks.count >= 2 {
                print("Tracks Completed for Thumbnail Asset")
                self.generate(image: media, completion: completion)
            } else {
                completion(nil)
            }
        }
    }
    
    func create(video media: Media, completion: @escaping ((Media?) -> Void)) {
        
        thumbnailAsset = AVAsset(url: recorded.getAssetUrl())
        backgroundAsset = AVAsset(url: media.getAssetUrl())
        
        backgroundAsset.loadValuesAsynchronously(forKeys: ["playable", "tracks","duration"]) {
            
            if self.backgroundAsset.tracks.count >= 1 {
                print("Tracks Completed for Background Asset")
                self.thumbnailAsset.loadValuesAsynchronously(forKeys: ["playable", "tracks","duration"]) {
                    if self.thumbnailAsset.tracks.count >= 2 {
                        print("Tracks Completed for Thumbnail Asset")
                        self.video(video: media, completion: completion)
                    } else {
                        completion(nil)
                    }
                }
            } else {
                completion(nil)
            }
        }
        
    }
    
    fileprivate func generate(image media: Media, completion: @escaping ((Media?) -> Void)) {
        let thumbnailSize = thumbnailAsset.tracks(withMediaType: AVMediaTypeVideo).first!.naturalSize
        
        let videoDuration = thumbnailAsset.duration
        
        let videoSize = media.getSize()
        
        let mix: AVMutableComposition = .init()
        
        let thumbnailVideoTrack: AVMutableCompositionTrack = mix.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        try! thumbnailVideoTrack.insertTimeRange(CMTimeRange(start: kCMTimeZero, duration: videoDuration), of: thumbnailAsset.tracks(withMediaType: AVMediaTypeVideo).first!, at: kCMTimeZero)
        
        if let audioTrack = thumbnailAsset.tracks(withMediaType: AVMediaTypeAudio).first {
            let thumbnailAudioTrack: AVMutableCompositionTrack = mix.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
            try! thumbnailAudioTrack.insertTimeRange(CMTimeRange(start: kCMTimeZero, duration: videoDuration), of: audioTrack, at: kCMTimeZero)
        }
        
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRange(start: kCMTimeZero, duration: videoDuration)
        
        let firstlayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: thumbnailVideoTrack)
        
        if thumbnailSize.width > thumbnailSize.height {
            let rotate = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
            let translate = CGAffineTransform(translationX: videoSize.width, y: 0)
            let scale = thumbnailSize.scaledTo250()
            
            let transform = rotate.concatenating(scale).concatenating(translate)
            firstlayerInstruction.setTransform(transform, at: kCMTimeZero)
        }
        
        let myImage: UIImage? = UIImage(data: media.getAssetData()!)
        let layerCa = CALayer()
        layerCa.contents = myImage?.cgImage
        layerCa.frame = CGRect(x: 0, y: 0, width: videoSize.width, height: videoSize.height)
        layerCa.opacity = 1.0
        let parentLayer = CALayer()
        let videoLayer = CALayer()
        parentLayer.frame = CGRect(x: 0, y: 0, width: videoSize.width, height: videoSize.height)
        videoLayer.frame = CGRect(x: 0, y: 0, width: videoSize.width, height: videoSize.height)
        videoLayer.backgroundColor = UIColor.red.cgColor
        
        parentLayer.addSublayer(layerCa)
        parentLayer.addSublayer(videoLayer)
        
        mainInstruction.layerInstructions = [firstlayerInstruction]
        
        let mainComposition = AVMutableVideoComposition()
        mainComposition.instructions = [mainInstruction]
        mainComposition.frameDuration = CMTimeMake(1, 30)
        mainComposition.renderSize = videoSize
        mainComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
        
        let mediaUrl = OfflineFileManager.getResourceUrl(with: Helper.generateString().appending(".mov"))
        if let export = AVAssetExportSession(asset: mix, presetName: AVAssetExportPresetMediumQuality) {
            export.outputFileType = AVFileTypeQuickTimeMovie
            export.outputURL = mediaUrl
            export.videoComposition = mainComposition
            export.timeRange = CMTimeRange(start: kCMTimeZero, duration: videoDuration)
            
            export.exportAsynchronously(completionHandler: {
                if export.status == .completed, let media = Media.create(video: mediaUrl) {
                    OfflineFileManager.remove(with: mediaUrl)
                    
                    completion(media)
                } else {
                    completion(nil)
                }
            })
        }
    }
    
    fileprivate func video(video: Media, completion: @escaping ((Media?) -> Void)) {
        
        let thumbnailSize = thumbnailAsset.tracks(withMediaType: AVMediaTypeVideo).first!.naturalSize
        let backgroundSize = backgroundAsset.tracks(withMediaType: AVMediaTypeVideo).first!.naturalSize
        
        let videoDuration = thumbnailAsset.duration
        
        let videoSize = backgroundSize
        
        let mix: AVMutableComposition = .init()
        
        let thumbnailVideoTrack: AVMutableCompositionTrack = mix.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        try! thumbnailVideoTrack.insertTimeRange(CMTimeRange(start: kCMTimeZero, duration: videoDuration), of: thumbnailAsset.tracks(withMediaType: AVMediaTypeVideo).first!, at: kCMTimeZero)
        
        if let audioTrack = thumbnailAsset.tracks(withMediaType: AVMediaTypeAudio).first {
            let thumbnailAudioTrack: AVMutableCompositionTrack = mix.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
            try! thumbnailAudioTrack.insertTimeRange(CMTimeRange(start: kCMTimeZero, duration: videoDuration), of: audioTrack, at: kCMTimeZero)
        }
        
        let backgroundVideoTrack: AVMutableCompositionTrack = mix.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        try! backgroundVideoTrack.insertTimeRange(CMTimeRange(start: kCMTimeZero, duration: videoDuration), of: backgroundAsset.tracks(withMediaType: AVMediaTypeVideo).first!, at: kCMTimeZero)
        
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRange(start: kCMTimeZero, duration: videoDuration)
        
        let firstInstruction = videoThumbnailComposition(track: thumbnailVideoTrack, asset: thumbnailAsset, videoSize: videoSize, at: kCMTimeZero)
        let secondInstruction = videoCompositionInstructionForTrack(track: backgroundVideoTrack, asset: backgroundAsset, at: kCMTimeZero, video: videoSize)
        
        mainInstruction.layerInstructions = [firstInstruction,secondInstruction]
        
        if thumbnailAsset.duration > backgroundAsset.duration {
            let _ = videoCompositionInstructionForTrack(track: thumbnailVideoTrack, asset: thumbnailAsset, at: backgroundAsset.duration, video: videoSize, instruction: firstInstruction)
        }
        
        let mainComposition = AVMutableVideoComposition()
        mainComposition.instructions = [mainInstruction]
        mainComposition.frameDuration = CMTimeMake(1, 30)
        mainComposition.renderSize = videoSize
        
        let mediaUrl = OfflineFileManager.getResourceUrl(with: Helper.generateString().appending(".mov"))
        if let export = AVAssetExportSession(asset: mix, presetName: Constants.videoQuality) {
            export.outputFileType = AVFileTypeQuickTimeMovie
            export.outputURL = mediaUrl
            export.videoComposition = mainComposition
            export.timeRange = CMTimeRange(start: kCMTimeZero, duration: videoDuration)
            
            export.exportAsynchronously(completionHandler: {
                if export.status == .completed, let media = Media.create(video: mediaUrl) {
                    OfflineFileManager.remove(with: mediaUrl)
                    
                    completion(media)
                } else {
                    completion(nil)
                }
            })
        }
    }
    
    fileprivate func orientationFromTransform(transform: CGAffineTransform) -> (orientation: UIImageOrientation, isPortrait: Bool) {
        var assetOrientation = UIImageOrientation.up
        var isPortrait = false
        if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
            assetOrientation = .right
            isPortrait = true
        } else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
            assetOrientation = .left
            isPortrait = true
        } else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
            assetOrientation = .up
        } else if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
            assetOrientation = .down
        }
        return (assetOrientation, isPortrait)
    }
    
    fileprivate func videoCompositionInstructionForTrack(track: AVCompositionTrack, asset: AVAsset, at time: CMTime, video size: CGSize, instruction: AVMutableVideoCompositionLayerInstruction? = nil) -> AVMutableVideoCompositionLayerInstruction {
        let instruction = instruction ?? AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        let assetTrack = asset.tracks(withMediaType: AVMediaTypeVideo).first!
        
        let transform = assetTrack.preferredTransform
        let assetInfo = orientationFromTransform(transform: transform)
        
        if assetInfo.isPortrait {
            let scaleToFitRatio = assetTrack.naturalSize.height / assetTrack.naturalSize.width
            let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)
            instruction.setTransform(assetTrack.preferredTransform.concatenating(scaleFactor), at: time)
        } else {
            let naturalSize = assetTrack.naturalSize
            let scale = naturalSize.scaleToSize(size: size)
            instruction.setTransform(assetTrack.preferredTransform.concatenating(scale), at: time)
        }
        
        return instruction
    }
    
    func videoThumbnailComposition(track: AVCompositionTrack, asset: AVAsset, videoSize: CGSize, at time: CMTime) -> AVMutableVideoCompositionLayerInstruction {
        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        let assetTrack = asset.tracks(withMediaType: AVMediaTypeVideo).first!
        
        let transform = assetTrack.preferredTransform
        let assetInfo = orientationFromTransform(transform: transform)

        if assetInfo.isPortrait {
            let size = assetTrack.naturalSize.resizeToThumb()
            let translate = CGAffineTransform(translationX: videoSize.width - size.height, y: 0)
            let scale = assetTrack.naturalSize.scaledTo250()
            
            instruction.setTransform(assetTrack.preferredTransform.concatenating(scale).concatenating(translate), at: time)
        } else {
            let size = assetTrack.naturalSize.resizeToThumb()
            let translate = CGAffineTransform(translationX: videoSize.width - size.width, y: 0)
            let scale = assetTrack.naturalSize.scaledTo250()
            
            instruction.setTransform(assetTrack.preferredTransform.concatenating(scale).concatenating(translate), at: time)
        }
        
        return instruction
    }
    
}

fileprivate extension CGSize {
    var thumbSize: CGFloat {
        return max(UIScreen.main.bounds.height * 0.20,200)
    }
    
    func resizeToThumb() -> CGSize {
        if width > height {
            return CGSize(width: thumbSize, height: (height / width) * thumbSize)
        } else {
            return CGSize(width: (height / width) * thumbSize, height: thumbSize)
        }
    }
    
    func scaledTo250() -> CGAffineTransform {
        return CGAffineTransform(scaleX: resizeToThumb().width / width, y: resizeToThumb().height / height )
    }
    
    func scaleToSize(size: CGSize) -> CGAffineTransform {
        return CGAffineTransform(scaleX: size.width / width, y: size.height / height )
    }
}

