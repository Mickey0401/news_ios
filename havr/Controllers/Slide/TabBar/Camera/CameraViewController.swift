//
//  CameraViewController.swift
//  havr
//
//  Created by Yuriy G. on 1/17/18.
//  Copyright © 2018 Tenton LLC. All rights reserved.
//

import UIKit
import SDWebImage
import MobileCoreServices
import MediaPlayer
import MBProgressHUD
import Kingfisher

class CameraViewController: CamViewController, UITextViewDelegate {

    @IBOutlet weak var cameraPreview        : UIView!
    @IBOutlet weak var containerView        : UIView!
    @IBOutlet weak var viewInterests        : UIView!

    @IBOutlet weak var viewControl          : UIStackView!
    @IBOutlet weak var viewCaption          : UIView!
    
    @IBOutlet weak var ivIndicator          : UIImageView!
    @IBOutlet weak var cameraPreviewTop     : NSLayoutConstraint!
    @IBOutlet weak var cameraPreviewHeight  : NSLayoutConstraint!
    @IBOutlet weak var viewInterestsHeight  : NSLayoutConstraint!
    
    @IBOutlet weak var viewInterestBottom   : NSLayoutConstraint!
    
    @IBOutlet weak var btnCancel            : UIButton!
    
    @IBOutlet weak var btnFlash             : RoundedButton!
    @IBOutlet weak var btnLibrary           : RoundedButton!
    @IBOutlet weak var btnCapture           : CameraButton!
    @IBOutlet weak var btnRecord            : RecordButton!
    
    @IBOutlet weak var btnSwitchCamera      : RoundedButton!
    @IBOutlet weak var btnDimension         : RoundedButton!
    
    @IBOutlet weak var btnMomentOut         : RoundedButton!
    @IBOutlet weak var btnSaveOut           : RoundedButton!
    @IBOutlet weak var btnMoment            : RoundedButton!
    @IBOutlet weak var btnSave              : RoundedButton!
    @IBOutlet weak var btnInt1              : RoundedButton!
    @IBOutlet weak var btnInt3              : RoundedButton!
    @IBOutlet weak var btnInt2              : RoundedButton!
    
    @IBOutlet weak var ivInt2               : RoundedImageView!
    @IBOutlet weak var ivInt1               : RoundedImageView!
    @IBOutlet weak var ivInt3               : RoundedImageView!
    @IBOutlet weak var lblTimer             : UILabel!
    
    @IBOutlet weak var lblInt1              : UILabel!
    @IBOutlet weak var lblInt2              : UILabel!
    @IBOutlet weak var lblInt3              : UILabel!
    @IBOutlet weak var lblMoment            : UILabel!
    @IBOutlet weak var lblSave              : UILabel!
    
    @IBOutlet weak var scrollView           : UIScrollView!
    @IBOutlet weak var pageIndicator        : UIPageControl!
    
    @IBOutlet weak var captionButtonView    : UIView!
    
    ///Comment
    @IBOutlet weak var viewComment          : UIView!
    @IBOutlet weak var tvComment            : UITextView!
    var placeholder_text                    = "Write a caption"
    ///Enum for setting image on buttons
    fileprivate enum CameraButtonImage {
        case flash_on
        case flash_off
        case library
        case lock
        case unlock
        case front
        case rear
    }
    ///Enum whether photo or video
    fileprivate enum MediaType {
        case photo
        case video
    }
    
    fileprivate var isFullScreen            = false,
                    currentMediaType        : MediaType!,
                    oldView                 : UIViewController!,
                    isCameraMode            = true,
                    offsetX                 : CGFloat = 0,
                    activeInterestBtn       : UIButton!,
                    activePost              : Post!,
                    activeTag               : Int = -1
    
    fileprivate var interestButtons         = [UIButton]()
    fileprivate var interestLabels          = [UILabel]()
    fileprivate var mediaButtons            = [UIButton]()

    var profileInterests: [UserInterest] {
        return ResourcesManager.activeInterests
    }

   fileprivate var activeViewController: UIViewController? {
        didSet {
            updateActiveViewController()
        }
    }
    
    let cache = KingfisherManager.shared.cache
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        createGestureRecognizers()
        
        getInterests()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        btnCapture.delegate = self
        btnRecord.delegate = self
        
        scrollView.contentOffset = CGPoint(x: offsetX, y: 0)
        addAction()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        offsetX = scrollView.contentOffset.x
        removeAction()
    }
    
    fileprivate func createGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tap))
        btnCapture.addGestureRecognizer(tapGesture)
    }
    
    @objc private func tap() {
        btnCapture.tap()
    }
    
    fileprivate func configureUI() {
        for btn in [btnFlash, btnLibrary, btnDimension, btnSwitchCamera] {
            btn?.backgroundColor = UIColor(white: 0.3, alpha: 0.2)
        }
        
        captionButtonView.layer.borderWidth = 0.0
        /// setInterestButtons
        setInterestButtons()
        
        /// CameraView configuration
        cameraDelegate = self
        maximumVideoDuration = 180.0  //3 mins
        shouldUseDeviceOrientation = true
        allowAutoRotate = false
        audioEnabled = true
        
        setPreviewContainer(cameraPreview)
        
        /// ScrollView configuration.
        let sHeight = scrollView.bounds.height
        
        let toolView = UIView()
        let btnPhoto = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: sHeight))
        toolView.addSubview(btnPhoto)
        btnPhoto.setTitle("Photo", for: .normal)
        btnPhoto.addTarget(self, action: #selector(self.tapPhoto), for: .touchUpInside)
        mediaButtons.append(btnPhoto)
        
        let btnVideo = UIButton(frame: CGRect(x: 80, y: 0, width: 50, height: sHeight))
        toolView.addSubview(btnVideo)
        btnVideo.setTitle("Video", for: .normal)
        btnVideo.addTarget(self, action: #selector(self.tapVideo), for: .touchUpInside)
        mediaButtons.append(btnVideo)
        
        toolView.frame = CGRect(x: scrollView.bounds.width/2 - 25, y: 0, width: 160, height: sHeight)
        scrollView.addSubview(toolView)
        scrollView.contentSize = CGSize(width: 320, height: sHeight)
        scrollView.delegate = self
        
        pageIndicator.pageIndicatorTintColor = Color.lightBlueColor
        pageIndicator.currentPageIndicatorTintColor = Color.darkBlueColor
        
        /// Hide views in camera view
        updateMediaControls(false)
        setCameraMode()
        /// Switch icons and colors
        resetView()
    }
    
    @objc private func tapPhoto(_ sender: UIButton) {
        scrollView.setContentOffset(CGPoint.init(x: 0, y: 0), animated: true)
    }
    
    @objc private func tapVideo(_ sender: UIButton) {
        scrollView.setContentOffset(CGPoint.init(x: 80, y: 0), animated: true)
    }
    
    fileprivate func setInterestButtons() {
        interestButtons = [btnMomentOut, btnSaveOut]
        interestLabels = [lblMoment, lblSave]
        
        for btn in [btnMoment, btnSave] {
            btn?.layer.borderWidth = 2
            btn?.layer.borderColor = UIColor.white.cgColor
        }
        
        var count = 0
        
        for pi in profileInterests {
            let interest = pi.item
            
            if !isInterest(interest: interest!) {
                continue
            }
            
            print(interest!)
            var button: UIButton
            var imageView: UIImageView
            
            if count == 0 {
                lblInt1.text = interest?.name
                
                interestButtons.append(btnInt1)
                interestLabels.append(lblInt1)
                imageView = ivInt1
                button = btnInt1
            } else if count == 1 {
                lblInt2.text = interest?.name
                interestButtons.append(btnInt2)
                interestLabels.append(lblInt2)
                button = btnInt2
                imageView = ivInt2
            } else if count == 2 {
                lblInt3.text = interest?.name
                interestButtons.append(btnInt3)
                interestLabels.append(lblInt3)
                imageView = ivInt3
                button = btnInt3
            } else {
                break
            }
            
            button.tag = count
            
            imageView.kf.setImage(with: interest?.getUrl())
            
            imageView.layer.borderColor = UIColor.white.cgColor
            imageView.layer.borderWidth = 2
            
            button.addTarget(self, action: #selector(interestsAction), for: .touchUpInside)
            
            count += 1
        }
        
        toggleInterestButton()
    }
    fileprivate func setCameraMode() {
        btnCapture.isHidden = !isCameraMode
        btnRecord.isHidden = isCameraMode
        lblTimer.isHidden = isCameraMode
    }
    
    fileprivate func isInterest(interest: Interest) -> Bool {
        if interest.name == "saved" || interest.name == "save" || interest.name == "moments" {
            return false
        }
        
        return true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        cache.clearMemoryCache()
        cache.clearDiskCache()
        cache.cleanExpiredDiskCache()
    }
    
    @objc private func interestsAction(_ sender: UIButton) {
        activeTag = sender.tag
        let button = interestButtons[activeTag + 2]
        
        activeInterestBtn = button
        toggleInterestButton()
        
        viewControl.isHidden = true
        viewCaption.isHidden = false
    }
    
 //MARK - Define Actions
    @IBAction func flashAction(_ sender: Any) {
        
        flashEnabled = !flashEnabled
        
        if flashEnabled == true {
            setImageButton(btnFlash, type: .flash_on)
        } else {
            setImageButton(btnFlash, type: .flash_off)
        }
    }
    
    @IBAction func libraryAction(_ sender: Any) {
        if isCameraMode  {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
                let imagePicker = BaseImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
                imagePicker.allowsEditing = false
                
                
                
                self.present(imagePicker, animated: true, completion: nil)
            }
        } else {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
                let imagePicker = BaseImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary;
                imagePicker.mediaTypes = [kUTTypeMovie as String]
                imagePicker.allowsEditing = false
                imagePicker.videoQuality = .type640x480
                
                
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func recordAction(_ sender: RecordButton) {
        print(btnRecord.isRecording ? "Recording Started" : "Recording Ended")
    }
    @IBAction func dimensionAction(_ sender: Any) {
        isFullScreen = !isFullScreen
        if isFullScreen == true {
            setImageButton(btnDimension, type: .unlock)
        } else {
            setImageButton(btnDimension, type: .lock)
        }
        resetView()
    }

    @IBAction func switchCameraAction(_ sender: Any) {
        switchCamera()
        setImageButton(btnSwitchCamera, type: switchedFrontCamera ? .rear : .front)
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        if nil != currentMediaType {
            viewControl.isHidden = false
            viewCaption.isHidden = true
            
            updateMediaControls(false)
            return
        }
        
        dismiss(animated: true, completion: nil)
    }

    @IBAction func momentAction(_ sender: UIButton) {
        activeInterestBtn = sender
        toggleInterestButton()
        
        var interest: Interest!
        for pi in ResourcesManager.allInterests {
            if pi.item?.name == "moments" {
                interest = pi.item
            }
        }
        
        if (interest == nil){
            return
        }
        getMedia { media in
            if let media = media {
                self.upload(media: media, interest: interest, caption: self.tvComment.text)
            }
        }
    }
    
    @IBAction func saveAction(_ sender: UIButton) {
        activeInterestBtn = sender
        toggleInterestButton()
        
        if let activeVC = activeViewController, activeVC.isKind(of: PhotoViewController.self) {
            let vc = activeVC as! PhotoViewController
            vc.saveCameraRoll({ saved in
                self.updateMediaControls(false)
            })
        } else if let activeVC = activeViewController, activeVC.isKind(of: VideoPlayViewController.self) {
            let vc = activeVC as! VideoPlayViewController
            vc.saveCameraRoll({ saved in
                self.updateMediaControls(false)
            })
        }
    }
    
    private func getMedia(_ completion: @escaping ((Media?) -> Void)) {
        if let activeVC = activeViewController, activeVC.isKind(of: PhotoViewController.self) {
            let vc = activeVC as! PhotoViewController
            let media = vc.getMedia()
            completion(media)
        } else if let activeVC = activeViewController, activeVC.isKind(of: VideoPlayViewController.self) {
            let vc = activeVC as! VideoPlayViewController
            vc.getMedia({ media in
                completion(media)
            })
        }
    }
    ///Caption
    @IBAction func captionAction(_ sender: Any) {
        viewComment.isHidden = false
        tvComment.delegate = self
        resetTextView()       
    }
    
    @IBAction func actionSend(_ sender: Any) {
//        if (tvComment.text == "") {
//            //tvComment.becomeFirstResponder()
//            Helper.show(alert: "Please type comment")
//            return
//        }
        if (tvComment.text == "Write a caption" || tvComment.text == ""){
            var interest: Interest!
            var count = 0
            for pi in profileInterests {
                if !isInterest(interest: pi.item!) {
                    continue
                }

                if count == activeTag {
                    interest = pi.item
                }

                count += 1
            }
            tvComment.text = interest.name
        }
        tvComment.resignFirstResponder()
        postMedia()
    }
    
    @IBAction func cancelComment(_ sender: Any) {
        tvComment.resignFirstResponder()
        viewComment.isHidden = true
    }
    
    @IBAction func sendComment(_ sender: Any) {
        if (tvComment.text == "") {
            tvComment.becomeFirstResponder()
            Helper.show(alert: "Please type comment")
            return
        }
        if (tvComment.text == "Write a caption"){
            var interest: Interest!
            var count = 0
            for pi in profileInterests {
                if !isInterest(interest: pi.item!) {
                    continue
                }
                
                if count == activeTag {
                    interest = pi.item
                }
                
                count += 1
            }
            tvComment.text = interest.name
        }
        tvComment.resignFirstResponder()
        postMedia()
    }
    
    private func addAction() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(CameraViewController.keyboardWillShow(_:)),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(CameraViewController.keyboardWillHide(_:)),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
    }
    
    private func removeAction () {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    private func postMedia() {
        var interest: Interest!
        var count = 0
        for pi in profileInterests {
            if !isInterest(interest: pi.item!) {
                continue
            }
            
            if count == activeTag {
                interest = pi.item
            }
            
            count += 1
        }
        
        getMedia { media in
            if let media = media {
                self.upload(media: media, interest: interest, caption: self.tvComment.text)
            }
        }
    }
    
    fileprivate func finishComment() {
        activePost = nil
        
        viewControl.isHidden = false
        viewCaption.isHidden = true
        viewComment.isHidden = true
        
        if nil != currentMediaType {
            updateMediaControls(false)
            return
        }
    }
}

// MARK -- Extension Methods Define
extension CameraViewController {
    fileprivate func resetView() {
        customWidth = isFullScreen ? 0 : 414
        customHeight = isFullScreen ? 0 : 414
        
        cameraPreviewHeight.constant = isFullScreen ? view.bounds.height : view.bounds.width
        cameraPreviewTop.constant = isFullScreen ? -20 : 36
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
        
        setImageButton(btnFlash, type: flashEnabled ? .flash_on : .flash_off)
        setImageButton(btnLibrary, type: .library)
        setImageButton(btnDimension, type: isFullScreen ? .unlock : .lock)
        setImageButton(btnSwitchCamera, type: switchedFrontCamera ? .rear : .front)
        
        btnCapture.setButtonColor(isFullScreen)
        btnRecord.setButtonColor(isFullScreen)
        
        let tintColor = isFullScreen ? UIColor.white : UIColor.black
        for lbl in interestLabels {
            lbl.textColor = tintColor
        }
        
        for btn in mediaButtons {
            btn.setTitleColor( tintColor, for: .normal)
        }
        
        btnCancel.setTitleColor(tintColor, for: .normal)
        lblTimer.textColor = tintColor
    }    
    
    fileprivate func setImageButton(_ btn: UIButton, type: CameraButtonImage) {
        var image: UIImage?
        
        switch (type) {
        case .flash_on:
            image = #imageLiteral(resourceName: "light_light_on")
            break
        case .flash_off:
            image = #imageLiteral(resourceName: "light_light_off")
            break
        case .library:
            image = #imageLiteral(resourceName: "light_camera_roll")
            break
        case .lock:
            image = #imageLiteral(resourceName: "light_dimen_lock")
            break
        case .unlock:
            image = #imageLiteral(resourceName: "light_dimen_unlock")
            break
        case .front:
            image = #imageLiteral(resourceName: "light_front_camera")
            break
        case .rear:
            image = #imageLiteral(resourceName: "light_back_camera")
            break
        }
        
        btn.setImage(image, for: .normal)
    }

    
    fileprivate func removeInactiveViewController(inactiveViewController: UIViewController?) {
        if let inActiveVC = inactiveViewController {
            
            inActiveVC.willMove(toParentViewController: nil)
            
            inActiveVC.view.removeFromSuperview()
            
            inActiveVC.removeFromParentViewController()
        }
    }
    
    fileprivate func updateActiveViewController() {
        if let activeVC = activeViewController {
            addChildViewController(activeVC)
            
            activeVC.view.frame = containerView.bounds
            activeVC.updateViewConstraints()
            addSubview(subView: activeVC.view, toView: containerView)
 
            activeVC.didMove(toParentViewController: self)
            
            oldView = activeVC
        }
    }
    
    func addSubview(subView:UIView, toView parentView:UIView) {
        parentView.addSubview(subView)
        
        var viewBindingsDict = [String: AnyObject]()
        viewBindingsDict["subView"] = subView
        parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[subView]|",
                                                                                 options: [], metrics: nil, views: viewBindingsDict))
        parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[subView]|",
                                                                                 options: [], metrics: nil, views: viewBindingsDict))
    }
    
    fileprivate func updateMediaControls(_ isShowed: Bool) {
        containerView.isHidden = !isShowed
        viewInterestBottom.constant = isShowed ? 0 : -93
        viewInterests.isHidden = !isShowed
        
        if let oView = oldView {
            removeInactiveViewController(inactiveViewController: oView)
            oldView = nil
        }
        
        if !isShowed {
            currentMediaType = nil
            ivIndicator.image = nil
            ivIndicator.isHidden = true
            activeInterestBtn = nil
        } else {
            ivIndicator.image = isFullScreen ? #imageLiteral(resourceName: "dark_bottom_arrow") : #imageLiteral(resourceName: "ic_bottom_arrow")
            ivIndicator.isHidden = false
        }
        
        scrollView.isHidden = isShowed
        btnCapture.isEnabled = !isShowed
        btnRecord.isEnabled = !isShowed
        btnFlash.isHidden = isShowed
        btnLibrary.isHidden = isShowed
        btnDimension.isHidden = isShowed
        btnSwitchCamera.isHidden = isShowed
        lblTimer.isHidden = isShowed || isCameraMode
        
        toggleInterestButton()
        
        UIView.animate(withDuration: 0.25, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    fileprivate func displayContainer(_ vc: UIViewController) {
        updateMediaControls(true)
        
        activeViewController = vc
    }
    
    fileprivate func toggleInterestButton() {
        for btn in interestButtons {
            if let activeBtn = activeInterestBtn, btn == activeBtn {
                btn.layer.borderColor = UIColor.yellow.cgColor
            } else {
                btn.layer.borderColor = Color.purpleColor.cgColor
            }
            btn.layer.borderWidth = 2
        }
    }
}

// MARK -- CamViewControllerDelegate
extension CameraViewController: CamViewControllerDelegate {
    func camViewController(_ camViewController: CamViewController, didTake photo: UIImage) {
        openPhotoViewController(photo)
    }
    
    fileprivate func openPhotoViewController(_ photo: UIImage) {
        let newVC = PhotoViewController(image: photo)
        currentMediaType = .photo
        displayContainer(newVC)
    }
    
    func camViewController(_ camViewController: CamViewController, didBeginRecordingVideo camera: CamViewController.CameraSelection) {
        print("Did Begin Recording")
        btnRecord.isRecording = true
        
        UIView.animate(withDuration: 0.25, animations: {
            self.btnFlash.isEnabled = false
            self.btnSwitchCamera.isEnabled = false
            self.btnDimension.isEnabled = false
            self.btnLibrary.isEnabled = false
            self.scrollView.isUserInteractionEnabled = false
        })
    }
    
    func camViewController(_ camViewController: CamViewController, didFinishRecordingVideo camera: CamViewController.CameraSelection) {
        print("Did finish Recording")
        btnRecord.isRecording = false
        UIView.animate(withDuration: 0.25, animations: {
            self.btnFlash.isEnabled = true
            self.btnSwitchCamera.isEnabled = true
            self.btnDimension.isEnabled = true
            self.btnLibrary.isEnabled = true
            self.lblTimer.text = "00:00"
            self.scrollView.isUserInteractionEnabled = true
        })
    }
    
    func camViewController(_ camViewController: CamViewController, didFinishProcessVideoAt url: URL) {
        openVideoViewController(url)
    }
    
    fileprivate func openVideoViewController(_ url: URL) {
        let newVC = VideoPlayViewController(videoURL: url)
        currentMediaType = .video
        displayContainer(newVC)
    }
    
    func camViewController(_ camViewController: CamViewController, didFocusAtPoint point: CGPoint) {
        let focusView = UIImageView(image: #imageLiteral(resourceName: "focus"))
        focusView.center = point
        focusView.alpha = 0.0
        view.addSubview(focusView)
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
            focusView.alpha = 1.0
            focusView.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        }, completion: { (success) in
            UIView.animate(withDuration: 0.15, delay: 0.5, options: .curveEaseInOut, animations: {
                focusView.alpha = 0.0
                focusView.transform = CGAffineTransform(translationX: 0.6, y: 0.6)
            }, completion: { (success) in
                focusView.removeFromSuperview()
            })
        })
    }
    
    func camViewController(_ camViewController: CamViewController, didChangeZoomLevel zoom: CGFloat) {
        print(zoom)
    }
    
    func camViewController(_ camViewController: CamViewController, didSwitchCameras camera: CamViewController.CameraSelection) {
        print(camera)
    }
    
    func camViewController(_ camViewController: CamViewController, didFailToRecordVideo error: Error) {
        print(error)
    }
    
    func camViewController(_ camViewController: CamViewController, didChangeRecordingTime seconds: Int) {
        let (m, s) = Helper.secondsToMinutesSeconds(seconds: seconds)
        lblTimer.text =  String.init(format: "%02d:%02d", m, s)
    }

}

// MARK -- UIScrollViewDelegate
extension CameraViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var currentPage = 0
        let offx = scrollView.contentOffset.x
        if offx > 0 {
            isCameraMode = false
            currentPage = 1
        } else {
            isCameraMode = true
            currentPage = 0
        }
        
        pageIndicator.currentPage = currentPage
        setCameraMode()
    }
}

// Mark -- UIImagePickerControllerDelegates
extension CameraViewController:UIImagePickerControllerDelegate,
UINavigationControllerDelegate {
 
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {        
        
        self.dismiss(animated: true, completion: nil);
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
           var image: UIImage?
            if let data:Data = UIImagePNGRepresentation(pickedImage) {
                image = self.processPhoto(data)
            } else if let data:Data = UIImageJPEGRepresentation(pickedImage, 1.0) {
                image = self.processPhoto(data)
            }
            
            if let image = image {
                DispatchQueue.main.async {
                    self.openPhotoViewController(image)
                }
            }
        }
        
        if let videoURL = info[UIImagePickerControllerMediaURL] as? URL {
            if self.customWidth == 0.0 && self.customHeight == 0.0 {
                DispatchQueue.main.async {
                    self.openVideoViewController(videoURL)
                }
            } else {
                self.showHud()
                self.squareCropVideo(inputURL: videoURL as NSURL, completion: { (outputURL) -> () in
                    self.hideHud()
                    DispatchQueue.main.async {
                        self.openVideoViewController(outputURL! as URL)
                    }
                })
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil);
    }
    
}

// Mark -- Http Call
extension CameraViewController {
    func getInterests(){
        InterestsAPI.getAll { (interests, error) in
            if let interests = interests{
                ResourcesManager.allInterests = interests
                self.setInterestButtons()
            }
        }
    }
    
    fileprivate func upload(media: Media, interest: Interest, caption: String){
        self.showHud()

        if media.uploadStatus == .uploaded {
            return
        }
        
        if media.uploadStatus == .uploading {
            return
        }
        
        media.upload(deleteOnUpload: true, completion: { (media, success, error) in
            //self.hideHud()
            if success{
                self.postMedia(interest, media: media, error: nil, title: caption)
            }else{
                //self.hideHud()
                self.postMedia(interest, media: media, error: error, title: caption)
                console("upload error: \(String(describing: error))")
            }
        }, progress: { (progress) in
            delay(delay: 0, closure: {
            })
            console("upload progress: \(progress)")
        })
    }
    
    fileprivate func postMedia(_ interest: Interest, media: Media, error: ErrorMessage?, title: String) {
        if error != nil {
            self.hideHud()
            Helper.show(alert: error!)
            return
        }
        
        let post = Post()
        post.interest = interest
        if (title == nil){
            post.title = interest.name
        }else{
            post.title = title
        }
        post.media = media
        print(media)
        
        //showHud()
        PostsAPI.create(new: post) { (post, error) in
            //self.hideHud()
            if let post = post{
                console("post: \(post.id)")
                //MBProgressHUD.showWithStatus(view: self.view, text: "Posted", image: #imageLiteral(resourceName: "SUCCESS"))
                self.hideHudWithMark(image: #imageLiteral(resourceName: "SUCCESS"), string: "Posted")
                
                delay(delay: 0.3, closure: {
                    self.finishComment()
                })
            }else{
                console("error: \(String(describing: error))")
//                MBProgressHUD.showWithStatus(view: self.view, text: error!.message, image: #imageLiteral(resourceName: "ERROR"))
                self.hideHudWithMark(image: #imageLiteral(resourceName: "SUCCESS"), string: "Posted")
            }
        }
    }
    
    fileprivate func addComment(_ interest : Interest, post: Post) {
        if  isInterest(interest: interest) {
            activePost = post
            
            if (viewComment.isHidden == true) {
                 viewControl.isHidden = false
                 viewCaption.isHidden = true
                
                //self.finishComment()
            }
            
                tvComment.resignFirstResponder()
                postComment()
            
        } else {
            if nil != currentMediaType {
                updateMediaControls(false)
                return
            }
        }
    }
}

// Mark -- Comment keyboard
extension CameraViewController {
    func keyboardWillShow(_ note: NSNotification) {
        if let keyboardSize = (note.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    func keyboardWillHide(_ note: NSNotification) {
        self.view.frame.origin.y = 0
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
}

// Mark -- Post Comments
extension CameraViewController {
    fileprivate func postComment() {
        if let post = activePost {
            //showHud()
            
            PostsAPI.createComment(with: tvComment.text, media: nil, to: post, completion: { (comment, error) in
//                self.hideHud()
                if error == nil {
                    self.hideHudWithMark(image: #imageLiteral(resourceName: "SUCCESS"), string: "Posted")
//                    MBProgressHUD.showWithStatus(view: self.view, text: "Posted", image: #imageLiteral(resourceName: "SUCCESS"))
                    self.finishComment()
                } else {
//                    self.hideHudWithMark(image: #imageLiteral(resourceName: "ERROR"), string: error!.message)
                    MBProgressHUD.showWithStatus(view: self.view, text: error!.message, image: #imageLiteral(resourceName: "ERROR"))
                }
                
            })
        }
    }
    
}

// MARK: - CameraViewController
extension CameraViewController {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let changedText = NSString(string: textView.text).replacingCharacters(in: range, with: text)
        
        if changedText.isEmpty {
            resetTextView()
            
            return false
        }
        else if textView.textColor == UIColor.lightGray && !text.isEmpty {
            textView.text = nil
            textView.textColor = UIColor.black
        }
        
        return true
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if (textView.text == "Write a caption"){
                textView.textColor = UIColor.lightGray
            }else{
                textView.textColor = UIColor.black
            }
            if textView.textColor == UIColor.lightGray {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }
    fileprivate func resetTextView() {
        tvComment.text = ""
        
        tvComment.text = placeholder_text
        tvComment.textColor = UIColor.lightGray
        
        tvComment.selectedTextRange = tvComment.textRange(from: tvComment.beginningOfDocument, to: tvComment.beginningOfDocument)
    }
}

extension CameraViewController {
    static func create() -> CameraViewController {
        return UIStoryboard.camera.instantiateViewController(withIdentifier: "CameraViewController") as! CameraViewController
    }
}

