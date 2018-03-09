//
//  CamViewController.swift
//  havr
//
//  Created by Yuriy G. on 1/17/18.
//  Copyright © 2018 Tenton LLC. All rights reserved.
//

import UIKit
import AVFoundation


open class CamViewController: UIViewController {

	// MARK: Enumeration Declaration
	/// Enumeration for Camera Selection
	public enum CameraSelection {
		/// Camera on the back of the device
		case rear
		/// Camera on the front of the device
		case front
	}

	public enum VideoQuality {
		case high
		case medium
		case low
		case resolution352x288
		case resolution640x480
		case resolution1280x720
		case resolution1920x1080
		case resolution3840x2160
		case iframe960x540
		case iframe1280x720
	}

	fileprivate enum SessionSetupResult {
		case success
		case notAuthorized
		case configurationFailed
	}

	public weak var cameraDelegate: CamViewControllerDelegate?
	public var maximumVideoDuration : Double     = 0.0
	public var videoQuality : VideoQuality       = .high
	public var flashEnabled                      = false
    public var switchedFrontCamera               = false
	public var pinchToZoom                       = true
	public var maxZoomScale				         = CGFloat.greatestFiniteMagnitude
	public var tapToFocus                        = true
	public var lowLightBoost                     = true
	public var allowBackgroundAudio              = true
	public var doubleTapCameraSwitch             = false
    public var swipeToZoom                       = true
    public var swipeToZoomInverted               = false
	/// Set default launch camera
	public var defaultCamera                     = CameraSelection.rear
	public var shouldUseDeviceOrientation        = true
    public var allowAutoRotate                   = false
    public var videoGravity                      : CamVideoGravity = .resizeAspectFill
    public var audioEnabled                      = true
    
    /// Sets custom width and height to resize and crop
    public var customWidth                       : CGFloat = 0.0
    public var customHeight                      : CGFloat = 0.0
    
    /// Container to add preview
    fileprivate var camContainer                 : UIView?

    fileprivate(set) public var pinchGesture     : UIPinchGestureRecognizer!
    fileprivate(set) public var panGesture       : UIPanGestureRecognizer!

	private(set) public var isVideoRecording     = false
	private(set) public var isSessionRunning     = false

	private(set) public var currentCamera        = CameraSelection.rear

	// MARK: Private Constant Declarations
	public let session                           = AVCaptureSession()
	fileprivate let sessionQueue                 = DispatchQueue(label: "session queue", attributes: [])

	// MARK: Private Variable Declarations
	fileprivate var zoomScale                    = CGFloat(1.0)
	fileprivate var beginZoomScale               = CGFloat(1.0)
	fileprivate var isCameraTorchOn              = false
	fileprivate var setupResult                  = SessionSetupResult.success
	fileprivate var backgroundRecordingID        : UIBackgroundTaskIdentifier? = nil
	fileprivate var videoDeviceInput             : AVCaptureDeviceInput!

	/// Movie File Output variable
	fileprivate var movieFileOutput              : AVCaptureMovieFileOutput?
	/// Photo File Output variable
	fileprivate var photoFileOutput              : AVCaptureStillImageOutput?
	/// Video Device variable
	fileprivate var videoDevice                  : AVCaptureDevice?
	/// PreviewView for the capture session
	fileprivate var previewLayer                 : PreviewView!
	/// UIView for front facing flash
	fileprivate var flashView                    : UIView?
    
    fileprivate var previousPanTranslation       : CGFloat = 0.0
	fileprivate var deviceOrientation            : UIDeviceOrientation?

	override open var shouldAutorotate: Bool {
		return allowAutoRotate
	}

	override open func viewDidLoad() {
		super.viewDidLoad()        
        
	}

    override open var prefersStatusBarHidden: Bool {
        return true
    }
    
    public func setPreviewContainer(_ container: UIView) {
        camContainer = container
        
        if let container = camContainer {
            previewLayer = PreviewView(frame: container.bounds, videoGravity: videoGravity)
            container.addSubview(previewLayer)
            container.sendSubview(toBack: previewLayer)
        } else {
            previewLayer = PreviewView(frame: view.bounds, videoGravity: videoGravity)
            view.addSubview(previewLayer)
            view.sendSubview(toBack: previewLayer)
        }
        
        addGestureRecognizers()
        
        previewLayer.session = session
        
        switch AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo){
        case .authorized:
            
            break
        case .notDetermined:
            
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { [unowned self] granted in
                if !granted {
                    self.setupResult = .notAuthorized
                }
                self.sessionQueue.resume()
            })
        default:
            
            setupResult = .notAuthorized
        }
        sessionQueue.async { [unowned self] in
            self.configureSession()
        }
    }

    private func updatePreviewLayer(layer: AVCaptureConnection, orientation: AVCaptureVideoOrientation) {
        
        layer.videoOrientation = orientation
        
        if let container = camContainer {
            previewLayer.frame = container.bounds
        } else {
            previewLayer.frame = self.view.bounds
        }
        
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let connection =  self.previewLayer?.videoPreviewLayer.connection  {
            
            let currentDevice: UIDevice = UIDevice.current
            
            let orientation: UIDeviceOrientation = currentDevice.orientation
            
            let previewLayerConnection : AVCaptureConnection = connection
            
            if previewLayerConnection.isVideoOrientationSupported {
                
                switch (orientation) {
                case .portrait: updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                
                    break
                    
                case .landscapeRight: updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeLeft)
                
                    break
                    
                case .landscapeLeft: updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeRight)
                
                    break
                    
                case .portraitUpsideDown: updatePreviewLayer(layer: previewLayerConnection, orientation: .portraitUpsideDown)
                
                    break
                    
                default: updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                
                    break
                }
            }
        } else {
            if let container = camContainer {
                previewLayer.frame = container.bounds
            } else {
                previewLayer.frame = self.view.bounds
            }
        }
    }

	override open func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		if shouldUseDeviceOrientation {
			subscribeToDeviceOrientationChangeNotifications()
		}

		setBackgroundAudioPreference()

		sessionQueue.async {
			switch self.setupResult {
			case .success:
				self.session.startRunning()
				self.isSessionRunning = self.session.isRunning
                
                DispatchQueue.main.async {
                    self.previewLayer.videoPreviewLayer.connection?.videoOrientation = self.getPreviewLayerOrientation()
                }
                
			case .notAuthorized:
				self.promptToAppSettings()
			case .configurationFailed:
				
				DispatchQueue.main.async(execute: { [unowned self] in
					let message = NSLocalizedString("Unable to capture media", comment: "Alert message when something goes wrong during capture session configuration")
					let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
					alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
					self.present(alertController, animated: true, completion: nil)
				})
			}
		}
	}

	override open func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)

		if self.isSessionRunning == true {
			self.session.stopRunning()
			self.isSessionRunning = false
		}

		disableFlash()

		if shouldUseDeviceOrientation {
			unsubscribeFromDeviceOrientationChangeNotifications()
		}
	}

	public func takePhoto() {

		guard let device = videoDevice else {
			return
		}

		if device.hasFlash == true && flashEnabled == true /* TODO: Add Support for Retina Flash and add front flash */ {
			changeFlashSettings(device: device, mode: .on)
			capturePhotoAsyncronously(completionHandler: { (_) in })

		} else if device.hasFlash == false && flashEnabled == true && currentCamera == .front {
			flashView = UIView(frame: previewLayer.frame)
			flashView?.alpha = 0.0
			flashView?.backgroundColor = UIColor.white
			previewLayer.addSubview(flashView!)

			UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseInOut, animations: {
				self.flashView?.alpha = 1.0

			}, completion: { (_) in
				self.capturePhotoAsyncronously(completionHandler: { (success) in
					UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseInOut, animations: {
						self.flashView?.alpha = 0.0
					}, completion: { (_) in
						self.flashView?.removeFromSuperview()
					})
				})
			})
		} else {
			if device.isFlashActive == true {
				changeFlashSettings(device: device, mode: .off)
			}
			capturePhotoAsyncronously(completionHandler: { (_) in })
		}
	}

	public func startVideoRecording() {
		guard let movieFileOutput = self.movieFileOutput else {
			return
		}

		if currentCamera == .rear && flashEnabled == true {
			enableFlash()
		}

		if currentCamera == .front && flashEnabled == true {
			flashView = UIView(frame: previewLayer.frame)
			flashView?.backgroundColor = UIColor.white
			flashView?.alpha = 0.85
			previewLayer.addSubview(flashView!)
		}

		sessionQueue.async { [unowned self] in
			if !movieFileOutput.isRecording {
				if UIDevice.current.isMultitaskingSupported {
					self.backgroundRecordingID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
				}

				let movieFileOutputConnection = self.movieFileOutput?.connection(withMediaType: AVMediaTypeVideo)

				if self.currentCamera == .front {
					movieFileOutputConnection?.isVideoMirrored = true
				}

				movieFileOutputConnection?.videoOrientation = self.getVideoOrientation()

				let outputFileName = UUID().uuidString
				let outputFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((outputFileName as NSString).appendingPathExtension("mov")!)
				movieFileOutput.startRecording(toOutputFileURL: URL(fileURLWithPath: outputFilePath), recordingDelegate: self)
				self.isVideoRecording = true
				DispatchQueue.main.async {
					self.cameraDelegate?.camViewController(self, didBeginRecordingVideo: self.currentCamera)
				}
			}
			else {
				movieFileOutput.stopRecording()
			}
		}
	}

	public func stopVideoRecording() {
		if self.movieFileOutput?.isRecording == true {
			self.isVideoRecording = false
			movieFileOutput!.stopRecording()
			disableFlash()

			if currentCamera == .front && flashEnabled == true && flashView != nil {
				UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseInOut, animations: {
					self.flashView?.alpha = 0.0
				}, completion: { (_) in
					self.flashView?.removeFromSuperview()
				})
			}
			DispatchQueue.main.async {
				self.cameraDelegate?.camViewController(self, didFinishRecordingVideo: self.currentCamera)
			}
		}
	}

    public func updateRecordingTime(_ seconds: Int) {
        DispatchQueue.main.async {
            self.cameraDelegate?.camViewController(self, didChangeRecordingTime: seconds)
        }
    }
    
	public func switchCamera() {
		guard isVideoRecording != true else {
			print("[Cam]: Switching between cameras while recording video is not supported")
			return
		}
        
        guard session.isRunning == true else {
            return
        }
        
		switch currentCamera {
		case .front:
			currentCamera = .rear
            switchedFrontCamera = false
		case .rear:
			currentCamera = .front
            switchedFrontCamera = true
		}

		session.stopRunning()

		sessionQueue.async { [unowned self] in

			for input in self.session.inputs {
				self.session.removeInput(input as! AVCaptureInput)
			}

			self.addInputs()
			DispatchQueue.main.async {
				self.cameraDelegate?.camViewController(self, didSwitchCameras: self.currentCamera)
			}

			self.session.startRunning()
		}

		disableFlash()
	}

	fileprivate func configureSession() {
		guard setupResult == .success else {
			return
		}

		// Set default camera
		currentCamera = defaultCamera
		// begin configuring session

		session.beginConfiguration()
		configureVideoPreset()
		addVideoInput()
		addAudioInput()
		configureVideoOutput()
		configurePhotoOutput()

		session.commitConfiguration()
	}

	fileprivate func addInputs() {
		session.beginConfiguration()
		configureVideoPreset()
		addVideoInput()
		addAudioInput()
		session.commitConfiguration()
	}

	fileprivate func configureVideoPreset() {
		if currentCamera == .front {
			session.sessionPreset = videoInputPresetFromVideoQuality(quality: .resolution640x480)
		} else {
			if session.canSetSessionPreset(videoInputPresetFromVideoQuality(quality: .resolution640x480)) {
				session.sessionPreset = videoInputPresetFromVideoQuality(quality: .resolution640x480)
			} else {
				session.sessionPreset = videoInputPresetFromVideoQuality(quality: .resolution640x480)
			}
		}
	}

	fileprivate func addVideoInput() {
		switch currentCamera {
		case .front:
			videoDevice = CamViewController.deviceWithMediaType(AVMediaTypeVideo, preferringPosition: .front)
		case .rear:
			videoDevice = CamViewController.deviceWithMediaType(AVMediaTypeVideo, preferringPosition: .back)
		}

		if let device = videoDevice {
			do {
				try device.lockForConfiguration()
				if device.isFocusModeSupported(.continuousAutoFocus) {
					device.focusMode = .continuousAutoFocus
					if device.isSmoothAutoFocusSupported {
						device.isSmoothAutoFocusEnabled = true
					}
				}

				if device.isExposureModeSupported(.continuousAutoExposure) {
					device.exposureMode = .continuousAutoExposure
				}

				if device.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) {
					device.whiteBalanceMode = .continuousAutoWhiteBalance
				}

				if device.isLowLightBoostSupported && lowLightBoost == true {
					device.automaticallyEnablesLowLightBoostWhenAvailable = true
				}

				device.unlockForConfiguration()
			} catch {
				print("[Cam]: Error locking configuration")
			}
		}

		do {
			let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)

			if session.canAddInput(videoDeviceInput) {
				session.addInput(videoDeviceInput)
				self.videoDeviceInput = videoDeviceInput
			} else {
				print("[Cam]: Could not add video device input to the session")
				print(session.canSetSessionPreset(videoInputPresetFromVideoQuality(quality: videoQuality)))
				setupResult = .configurationFailed
				session.commitConfiguration()
				return
			}
		} catch {
			print("[Cam]: Could not create video device input: \(error)")
			setupResult = .configurationFailed
			return
		}
	}

	fileprivate func addAudioInput() {
        guard audioEnabled == true else {
            return
        }
		do {
			let audioDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
			let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice)

			if session.canAddInput(audioDeviceInput) {
				session.addInput(audioDeviceInput)
			}
			else {
				print("[Cam]: Could not add audio device input to the session")
			}
		}
		catch {
			print("[Cam]: Could not create audio device input: \(error)")
		}
	}
	/// Configure Movie Output
	fileprivate func configureVideoOutput() {
		let movieFileOutput = AVCaptureMovieFileOutput()

		if self.session.canAddOutput(movieFileOutput) {
			self.session.addOutput(movieFileOutput)
			if let connection = movieFileOutput.connection(withMediaType: AVMediaTypeVideo) {
				if connection.isVideoStabilizationSupported {
					connection.preferredVideoStabilizationMode = .auto
				}
			}
			self.movieFileOutput = movieFileOutput
		}
	}
	/// Configure Photo Output
	fileprivate func configurePhotoOutput() {
		let photoFileOutput = AVCaptureStillImageOutput()

		if self.session.canAddOutput(photoFileOutput) {
			photoFileOutput.outputSettings  = [AVVideoCodecKey: AVVideoCodecJPEG]
			self.session.addOutput(photoFileOutput)
			self.photoFileOutput = photoFileOutput
		}
	}

	/// Orientation management
	fileprivate func subscribeToDeviceOrientationChangeNotifications() {
		self.deviceOrientation = UIDevice.current.orientation
		NotificationCenter.default.addObserver(self, selector: #selector(deviceDidRotate), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
	}

	fileprivate func unsubscribeFromDeviceOrientationChangeNotifications() {
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
		self.deviceOrientation = nil
	}

	@objc fileprivate func deviceDidRotate() {
		if !UIDevice.current.orientation.isFlat {
			self.deviceOrientation = UIDevice.current.orientation
		}
	}
    
    fileprivate func getPreviewLayerOrientation() -> AVCaptureVideoOrientation {
        switch UIApplication.shared.statusBarOrientation {
        case .portrait, .unknown:
            return AVCaptureVideoOrientation.portrait
        case .landscapeLeft:
            return AVCaptureVideoOrientation.landscapeLeft
        case .landscapeRight:
            return AVCaptureVideoOrientation.landscapeRight
        case .portraitUpsideDown:
            return AVCaptureVideoOrientation.portraitUpsideDown
        }
    }

	fileprivate func getVideoOrientation() -> AVCaptureVideoOrientation {
		guard shouldUseDeviceOrientation, let deviceOrientation = self.deviceOrientation else { return previewLayer!.videoPreviewLayer.connection.videoOrientation }

		switch deviceOrientation {
		case .landscapeLeft:
			return .landscapeRight
		case .landscapeRight:
			return .landscapeLeft
		case .portraitUpsideDown:
			return .portraitUpsideDown
		default:
			return .portrait
		}
	}

	fileprivate func getImageOrientation(forCamera: CameraSelection) -> UIImageOrientation {
		guard shouldUseDeviceOrientation, let deviceOrientation = self.deviceOrientation else { return forCamera == .rear ? .up : .leftMirrored }

		switch deviceOrientation {
		case .landscapeLeft:
			return forCamera == .rear ? .up : .downMirrored
		case .landscapeRight:
			return forCamera == .rear ? .down : .upMirrored
		case .portraitUpsideDown:
			return forCamera == .rear ? .left : .rightMirrored
		default:
			return forCamera == .rear ? .right : .leftMirrored
		}
	}
	
    fileprivate func resizeImage(image: UIImage, newWidth: CGFloat, newHeight: CGFloat) -> UIImage? {
        var oldWidth = image.size.width
        var oldHeight = image.size.height
        var scaleFactorX = newWidth / oldWidth;
        var scaleFactorY = newHeight / oldHeight;
        
        var newHeight1: CGFloat!
        var newWidth1: CGFloat!
        if (scaleFactorX < scaleFactorY){
            newHeight1 = oldHeight * scaleFactorX;
            newWidth1 = newWidth;
            newHeight1 = newHeight1 + 5
        }else{
            newWidth1 = oldWidth * scaleFactorY;
            newHeight1 = newHeight;
            newWidth1 = newWidth1 + 5;
        }
        
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: (newWidth - newWidth1) / 2, y: (newHeight - newHeight1) / 2, width: newWidth1, height: newHeight1))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
	public func processPhoto(_ imageData: Data) -> UIImage? {
		let dataProvider = CGDataProvider(data: imageData as CFData)
        var cgImageRef: CGImage?
        if let cgImg  = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent) {
            cgImageRef = cgImg
        } else if let cgImg  =  CGImage(pngDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent) {
            cgImageRef = cgImg
        }
        
        if cgImageRef == nil {
            return nil
        }
        
        let width  = CGFloat((cgImageRef?.width)!)
        let height = CGFloat((cgImageRef?.height)!)
        
        guard let rect = previewLayer.getMetadataOutputRectConverted() else {
            return nil
        }
        
        
        let cropRect = CGRect(x: 0.0,//rect.origin.x * width,
                              y: 0.0,//rect.origin.y * height,
                              width: width,//rect.size.width * width,
                              height: height)//rect.size.height * height)
        
        guard let img = cgImageRef?.cropping(to: cropRect) else {
            return nil
        }
        
        
		// Set proper orientation for photo
		// If camera is currently set to front camera, flip image
        var image = UIImage(cgImage: img, scale: 1.0, orientation: self.getImageOrientation(forCamera: self.currentCamera))
        
        if customWidth > 0 && customHeight > 0 {
        
            image = resizeImage(image: image, newWidth: customWidth, newHeight: customHeight)!
        }
        
		return image
	}

	fileprivate func capturePhotoAsyncronously(completionHandler: @escaping(Bool) -> ()) {
		if let videoConnection = photoFileOutput?.connection(withMediaType: AVMediaTypeVideo) {

			photoFileOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: {(sampleBuffer, error) in
				if (sampleBuffer != nil) {
					let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    if let image = self.processPhoto(imageData!) {

                        // Call delegate and return new image
                        DispatchQueue.main.async {
                            self.cameraDelegate?.camViewController(self, didTake: image)
                        }
                        completionHandler(true)
                    }
				} else {
					completionHandler(false)
				}
			})
		} else {
			completionHandler(false)
		}
	}


	fileprivate func promptToAppSettings() {

		DispatchQueue.main.async(execute: { [unowned self] in
			let message = NSLocalizedString("AVCam doesn't have permission to use the camera, please change privacy settings", comment: "Alert message when the user has denied access to the camera")
			let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
			alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
			alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"), style: .default, handler: { action in
				if #available(iOS 10.0, *) {
					UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
				} else {
					if let appSettings = URL(string: UIApplicationOpenSettingsURLString) {
						UIApplication.shared.openURL(appSettings)
					}
				}
			}))
			self.present(alertController, animated: true, completion: nil)
		})
	}

	fileprivate func videoInputPresetFromVideoQuality(quality: VideoQuality) -> String {
		switch quality {
		case .high: return AVCaptureSessionPresetHigh
		case .medium: return AVCaptureSessionPresetMedium
		case .low: return AVCaptureSessionPresetLow
		case .resolution352x288: return AVCaptureSessionPreset352x288
		case .resolution640x480: return AVCaptureSessionPreset640x480
		case .resolution1280x720: return AVCaptureSessionPreset1280x720
		case .resolution1920x1080: return AVCaptureSessionPreset1920x1080
		case .iframe960x540: return AVCaptureSessionPresetiFrame960x540
		case .iframe1280x720: return AVCaptureSessionPresetiFrame1280x720
		case .resolution3840x2160:
			if #available(iOS 9.0, *) {
				return AVCaptureSessionPreset3840x2160
			}
			else {
				print("[Cam]: Resolution 3840x2160 not supported")
				return AVCaptureSessionPresetHigh
			}
		}
	}

	/// Get Devices

	fileprivate class func deviceWithMediaType(_ mediaType: String, preferringPosition position: AVCaptureDevicePosition) -> AVCaptureDevice? {
		if let devices = AVCaptureDevice.devices(withMediaType: mediaType) as? [AVCaptureDevice] {
			return devices.filter({ $0.position == position }).first
		}
		return nil
	}

	/// Enable or disable flash for photo
	fileprivate func changeFlashSettings(device: AVCaptureDevice, mode: AVCaptureFlashMode) {
		do {
			try device.lockForConfiguration()
			device.flashMode = mode
			device.unlockForConfiguration()
		} catch {
			print("[Cam]: \(error)")
		}
	}

	/// Enable flash
	fileprivate func enableFlash() {
		if self.isCameraTorchOn == false {
			toggleFlash()
		}
	}

	/// Disable flash
	fileprivate func disableFlash() {
		if self.isCameraTorchOn == true {
			toggleFlash()
		}
	}

	fileprivate func toggleFlash() {
		guard self.currentCamera == .rear else {
			return
		}

		let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
		if (device?.hasTorch)! {
			do {
				try device?.lockForConfiguration()
				if (device?.torchMode == AVCaptureTorchMode.on) {
					device?.torchMode = AVCaptureTorchMode.off
					self.isCameraTorchOn = false
				} else {
					do {
						try device?.setTorchModeOnWithLevel(1.0)
						self.isCameraTorchOn = true
					} catch {
						print("[Cam]: \(error)")
					}
				}
				device?.unlockForConfiguration()
			} catch {
				print("[Cam]: \(error)")
			}
		}
	}

	fileprivate func setBackgroundAudioPreference() {
		guard allowBackgroundAudio == true else {
			return
		}
        
        guard audioEnabled == true else {
            return
        }

		do{
			try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord,
			                                                with: [.duckOthers, .defaultToSpeaker])

			session.automaticallyConfiguresApplicationAudioSession = false
		}
		catch {
			print("[Cam]: Failed to set background audio preference")

		}
	}
}

extension CamViewController : CamButtonDelegate {

	public func setMaxiumVideoDuration() -> Double {
		return maximumVideoDuration
	}
	public func buttonWasTapped() {
		takePhoto()
	}

	public func buttonDidBeginLongPress() {
		startVideoRecording()
	}

	public func buttonDidEndLongPress() {
		stopVideoRecording()
	}

	public func longPressDidReachMaximumDuration() {
		stopVideoRecording()
	}
    
    public func setVideoRecordingTime(_ seconds: Int) {
        updateRecordingTime(seconds)
    }
}

// MARK: AVCaptureFileOutputRecordingDelegate
extension CamViewController : AVCaptureFileOutputRecordingDelegate {
	/// Process newly captured video and write it to temporary directory

	public func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
		if let currentBackgroundRecordingID = backgroundRecordingID {
			backgroundRecordingID = UIBackgroundTaskInvalid

			if currentBackgroundRecordingID != UIBackgroundTaskInvalid {
				UIApplication.shared.endBackgroundTask(currentBackgroundRecordingID)
			}
		}
		if error != nil {
			print("[Cam]: Movie file finishing error: \(error)")
            DispatchQueue.main.async {
                self.cameraDelegate?.camViewController(self, didFailToRecordVideo: error)
            }
		} else {
			//Call delegate function with the URL of the outputfile
			DispatchQueue.main.async {
                if self.customWidth == 0.0 && self.customHeight == 0.0 {
                    self.cameraDelegate?.camViewController(self, didFinishProcessVideoAt: outputFileURL! as URL)
                } else {
                    self.showHud()
                    self.squareCropVideo(inputURL: outputFileURL! as NSURL, completion: { (outputURL) -> () in
                        self.hideHud()
                        if outputURL != nil {
                            self.cameraDelegate?.camViewController(self, didFinishProcessVideoAt: outputURL! as URL)
                        }
                    })
                }
                
			}
		}
	}
    
    public func squareCropVideo(inputURL: NSURL, completion: @escaping (_ outputURL : NSURL?) -> ())
    {
        let videoAsset: AVAsset = AVAsset( url: inputURL as URL )
        
        let mixComposition = AVMutableComposition()
        let videoTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
        
        let sourceVideoTrack = videoAsset.tracks(withMediaType: AVMediaTypeVideo).first! as AVAssetTrack
        
        do {
            try videoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAsset.duration),
                                           of: videoAsset.tracks(withMediaType: AVMediaTypeVideo)[0],
                                           at: kCMTimeZero)
        } catch let error as NSError {
            print("error: \(error)")
        }
        
        // -- Create instruction
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
        let transformer = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        
        guard let rect = previewLayer.getMetadataOutputRectConverted() else {
            return
        }
        
        let scale = view.frame.width / sourceVideoTrack.naturalSize.width
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = CGSize( width: sourceVideoTrack.naturalSize.height, height: sourceVideoTrack.naturalSize.height )
        videoComposition.frameDuration = CMTimeMake(1, 30)
        
      /*  let cropOffX = rect.origin.x
        let cropOffY = rect.origin.y
        let cropWidth = rect.size.width
        let cropHeight = rect.size.height
        
        let videoOrientation = getVideoOrientationFromAsset(videoAsset)
        var t1 = CGAffineTransform.identity
        var t2 = CGAffineTransform.identity
        
        switch videoOrientation {
        case UIImageOrientation.up:
            t1 = CGAffineTransform(translationX: sourceVideoTrack.naturalSize.height - cropOffX, y: 0 - cropOffY );
            t2 = t1.rotated(by: .pi/2)
            break;
        case UIImageOrientation.down:
            t1 = CGAffineTransform(translationX: 0 - cropOffX, y: sourceVideoTrack.naturalSize.width - cropOffY );
            t2 = t1.rotated(by: -(.pi/2))
            break;
        case UIImageOrientation.right:
            t1 = CGAffineTransform(translationX: 0 - cropOffX, y: 0 - cropOffY );
            t2 = t1.rotated(by: 0)
            break;
        case UIImageOrientation.left:
            t1 = CGAffineTransform(translationX: sourceVideoTrack.naturalSize.width - cropOffX, y: sourceVideoTrack.naturalSize.height - cropOffY );
            t2 = t1.rotated(by: .pi)
            break;
        default:
            break;
        }
        
        let finalTransform = t2
 
 */
        
        let transform1: CGAffineTransform = CGAffineTransform(translationX: sourceVideoTrack.naturalSize.height, y: rect.width / scale -  ( sourceVideoTrack.naturalSize.width - sourceVideoTrack.naturalSize.height ) / 2  )
        
        let transform2 = transform1.rotated(by: .pi/2)
        let finalTransform = transform2
        
        transformer.setTransform(finalTransform, at: kCMTimeZero)
        
        instruction.layerInstructions = [transformer]
        videoComposition.instructions = [instruction]
      
        // Export
        let exportSession = AVAssetExportSession(asset: videoAsset, presetName: AVAssetExportPresetHighestQuality)!
        
        let fileManager = FileManager.default
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileURL = documentDirectory.appendingPathComponent(NSUUID().uuidString + ".mov")
            
            exportSession.outputURL = fileURL
            exportSession.outputFileType = AVFileTypeQuickTimeMovie
            exportSession.videoComposition = videoComposition
            
            exportSession.exportAsynchronously() { handler -> Void in
                if exportSession.status == .completed {
                    print("Export complete")
                    DispatchQueue.main.async(execute: {
                        completion(fileURL as NSURL)
                    })
                    return
                } else if exportSession.status == .failed {
                    print("Export failed - \(String(describing: exportSession.error))")
                }
                
                completion(nil)
                return
            }
        } catch {
            print(error)
        }
        
   }
  
    fileprivate func getVideoOrientationFromAsset(_ asset: AVAsset) -> UIImageOrientation {
        let videoTrack = asset.tracks(withMediaType: AVMediaTypeVideo).first! as AVAssetTrack
        let size = videoTrack.naturalSize
        let txf = videoTrack.preferredTransform
        
        if size.width == txf.tx && size.height == txf.ty {
            return UIImageOrientation.left
        } else if txf.tx == 0 && txf.ty == 0 {
            return UIImageOrientation.right
        } else if txf.tx == 0 && txf.ty == size.width {
            return UIImageOrientation.down
        } else {
            return UIImageOrientation.up
        }
    }
}

// Mark: UIGestureRecognizer Declarations

extension CamViewController {

	@objc fileprivate func zoomGesture(pinch: UIPinchGestureRecognizer) {
		guard pinchToZoom == true && self.currentCamera == .rear else {
			return
		}
		do {
			let captureDevice = AVCaptureDevice.devices().first as? AVCaptureDevice
			try captureDevice?.lockForConfiguration()

			zoomScale = min(maxZoomScale, max(1.0, min(beginZoomScale * pinch.scale,  captureDevice!.activeFormat.videoMaxZoomFactor)))

			captureDevice?.videoZoomFactor = zoomScale

			DispatchQueue.main.async {
				self.cameraDelegate?.camViewController(self, didChangeZoomLevel: self.zoomScale)
			}

			captureDevice?.unlockForConfiguration()

		} catch {
			print("[Cam]: Error locking configuration")
		}
	}

	/// Handle single tap gesture
	@objc fileprivate func singleTapGesture(tap: UITapGestureRecognizer) {
		guard tapToFocus == true else {
			// Ignore taps
			return
		}

		let screenSize = previewLayer!.bounds.size
		let tapPoint = tap.location(in: previewLayer!)
		let x = tapPoint.y / screenSize.height
		let y = 1.0 - tapPoint.x / screenSize.width
		let focusPoint = CGPoint(x: x, y: y)

		if let device = videoDevice {
			do {
				try device.lockForConfiguration()

				if device.isFocusPointOfInterestSupported == true {
					device.focusPointOfInterest = focusPoint
					device.focusMode = .autoFocus
				}
				device.exposurePointOfInterest = focusPoint
				device.exposureMode = AVCaptureExposureMode.continuousAutoExposure
				device.unlockForConfiguration()

				DispatchQueue.main.async {
					self.cameraDelegate?.camViewController(self, didFocusAtPoint: tapPoint)
				}
			}
			catch {
				// just ignore
			}
		}
	}

	/// Handle double tap gesture
	@objc fileprivate func doubleTapGesture(tap: UITapGestureRecognizer) {
		guard doubleTapCameraSwitch == true else {
			return
		}
		switchCamera()
	}
    
    @objc private func panGesture(pan: UIPanGestureRecognizer) {
        
        guard swipeToZoom == true && self.currentCamera == .rear else {
            //ignore pan
            return
        }
        
        let currentTranslation    = pan.translation(in: camContainer ?? view).y
        let translationDifference = currentTranslation - previousPanTranslation
        
        do {
            let captureDevice = AVCaptureDevice.devices().first as? AVCaptureDevice
            try captureDevice?.lockForConfiguration()
            
            guard captureDevice == nil else {
                return
            }
            
            let currentZoom = captureDevice?.videoZoomFactor ?? 0.0
            
            if swipeToZoomInverted == true {
                zoomScale = min(maxZoomScale, max(1.0, min(currentZoom - (translationDifference / 75),  captureDevice!.activeFormat.videoMaxZoomFactor)))
            } else {
                zoomScale = min(maxZoomScale, max(1.0, min(currentZoom + (translationDifference / 75),  captureDevice!.activeFormat.videoMaxZoomFactor)))

            }
            
            captureDevice?.videoZoomFactor = zoomScale
            
            // Call Delegate function with current zoom scale
            DispatchQueue.main.async {
                self.cameraDelegate?.camViewController(self, didChangeZoomLevel: self.zoomScale)
            }
            
            captureDevice?.unlockForConfiguration()
            
        } catch {
            print("[Cam]: Error locking configuration")
        }
        
        if pan.state == .ended || pan.state == .failed || pan.state == .cancelled {
            previousPanTranslation = 0.0
        } else {
            previousPanTranslation = currentTranslation
        }
    }

	fileprivate func addGestureRecognizers() {
		pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(zoomGesture(pinch:)))
		pinchGesture.delegate = self
		previewLayer.addGestureRecognizer(pinchGesture)

		let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(singleTapGesture(tap:)))
		singleTapGesture.numberOfTapsRequired = 1
		singleTapGesture.delegate = self
		previewLayer.addGestureRecognizer(singleTapGesture)

		let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapGesture(tap:)))
		doubleTapGesture.numberOfTapsRequired = 2
		doubleTapGesture.delegate = self
		previewLayer.addGestureRecognizer(doubleTapGesture)
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGesture(pan:)))
        panGesture.delegate = self
        previewLayer.addGestureRecognizer(panGesture)
	}
}


// MARK: UIGestureRecognizerDelegate

extension CamViewController : UIGestureRecognizerDelegate {

	public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		if gestureRecognizer.isKind(of: UIPinchGestureRecognizer.self) {
			beginZoomScale = zoomScale;
		}
		return true
	}
}




