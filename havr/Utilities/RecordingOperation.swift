//
//  RecordingOperation.swift
//  havr
//
//  Created by Personal on 8/23/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import Foundation
import SwiftyTimer
import AVFoundation

protocol RecordingOperationDelegate : class {
    func recordingOperation(sender: RecordingOperation, willStartRecording url: URL)
    func recordingOperation(sender: RecordingOperation, isRecordingAt time: TimeInterval )
    func recordingOperation(sender: RecordingOperation, didFinishRecordingAt url: URL )
    func recordingOperation(sender: RecordingOperation, recordingAborted error: ErrorMessage, canceled: Bool)
}

class RecordingOperation: NSObject {
    enum RecordingOperationStatus {
        case none
        case start
        case recording
        case end
    }
    
    fileprivate var buttonTimer : SwiftyTimer.Timer?
    fileprivate var repeatingTimer : SwiftyTimer.Timer?
    
    fileprivate let SPAN : TimeInterval
    fileprivate let REPEATSPAN : TimeInterval
    fileprivate let RECORDINGTIME : TimeInterval
    
    fileprivate var status : RecordingOperationStatus = .none
    
    weak var delegate : RecordingOperationDelegate?
    
    private var recordingStartTime : Date!
    private var elapsedButtonTimer : Bool = false
    fileprivate var canceled: Bool = false
    
    fileprivate var url: URL!
    
    private var recordingSession: AVAudioSession!
    private var audioRecorder: AVAudioRecorder!
    
    var recordingStatus: RecordingOperationStatus {
        return status
    }
    
    /// span: time after recording should start
    /// refreshRate: period that operation should track
    /// recordingTime: maxmimum recording time
    init(span period: TimeInterval = 0.3, refreshRate: TimeInterval = 0.1, recordingTime : TimeInterval = 15) {
        SPAN = period
        REPEATSPAN = refreshRate
        RECORDINGTIME = recordingTime
        
        recordingSession = AVAudioSession.sharedInstance()
    }
    
    open func start()  {
        
        let permission = recordingSession.recordPermission()
        
        if permission == .denied {
            _resetVars()
            self.delegate?.recordingOperation(sender: self, recordingAborted: "We dont have permissions to use your microphone.", canceled: true)
            return
        }
        
        if permission == .undetermined {
            _resetVars()
            self.requestPermissions()
            self.delegate?.recordingOperation(sender: self, recordingAborted: "", canceled: false)

            return
        }
        
        _resetVars()
        
        let fileName = Helper.generateString(length: 48).appending(".m4a")
        self.url = OfflineFileManager.getResourceUrl(with: fileName)
        
        //setup timer
        buttonTimer = SwiftyTimer.Timer.after(SPAN, { [weak self] in
            self?.elapsedButtonTimer = true
            if self?.status == .start {
                self?.delegate?.recordingOperation(sender: self!, willStartRecording: self!.url)
                self?.status = .recording
                
                self?.startRecording()
                
                self?.recordingStartTime = Date() //set recording date start
                self?.repeatingTimer = SwiftyTimer.Timer.every(self?.REPEATSPAN ?? 0.5, { [weak self] in
                    if let me = self {
                        if me.status == .recording {
                            let recordedTime = me._timeElapsed(from: me.recordingStartTime)
                            if recordedTime >= me.RECORDINGTIME {
                                //fnish recording
                                me.status = .end
                                me.endRecording(canceled: false)
                                me.delegate?.recordingOperation(sender: me, isRecordingAt: me._timeElapsed(from: me.recordingStartTime))
                                me._resetVars()
                            }
                            else {
                                me.delegate?.recordingOperation(sender: me, isRecordingAt: me._timeElapsed(from: me.recordingStartTime))
                            }
                        }
                    }
                })
            }
        })
        
        status = .start
    }
    
    open func end() {
        if !elapsedButtonTimer && self.status != .end { //if is for image
            self.status = .end
//            self.delegate?.recordingOperation(sender: self, recordingAborted: true)
            self.delegate?.recordingOperation(sender: self, recordingAborted: "", canceled: true)
            self._resetVars()
            return
        }
        
        //stop recording
        if status == .recording {
            self.status = .end
            self.endRecording(canceled: false)
            _resetVars()
            return
        }
        
        if status != .end {
            self.delegate?.recordingOperation(sender: self, recordingAborted: "", canceled: true)
        }
    }
    
    private func _timeElapsed(from date: Date) -> TimeInterval {
        return Date().timeIntervalSince(date)
    }
    
    private func _resetVars () {
        self.repeatingTimer?.invalidate()
        self.repeatingTimer = nil
        self.buttonTimer?.invalidate()
        self.buttonTimer = nil
        elapsedButtonTimer = false
        self.canceled = false
    }
    
    func cancel() {
        _resetVars()
        endRecording(canceled: true)
    }
    
    fileprivate func requestPermissions() {
        do {
            //try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)

            try recordingSession.setActive(true)
            
            recordingSession.requestRecordPermission({ (allowed) in
                print(allowed)
            })
        } catch {
            // failed to record!
        }
    }
    
    fileprivate func startRecording() {
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            //try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
            try recordingSession.setActive(true)
            
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
        } catch {
//            finishRecording(success: false)
        }
    }
    
    fileprivate func endRecording(canceled: Bool) {
        
        self.canceled = canceled
        
        guard let audioRecorder = self.audioRecorder else { return  }
        
        if audioRecorder.isRecording {
            audioRecorder.stop()
        }
        
        self.audioRecorder = nil
    }
}

//MARK: - Audio Record Delegate
extension RecordingOperation: AVAudioRecorderDelegate {
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        self.cancel()
        self.delegate?.recordingOperation(sender: self, recordingAborted: error?.localizedDescription ?? "Something went wrong while recording audio.", canceled: self.canceled)
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag && !canceled {
            self.delegate?.recordingOperation(sender: self, didFinishRecordingAt: self.url)
        } else {
            OfflineFileManager.remove(with: self.url)
            self.delegate?.recordingOperation(sender: self, recordingAborted: "Something went wrong while recording audio.", canceled: self.canceled)
        }
    }
}
