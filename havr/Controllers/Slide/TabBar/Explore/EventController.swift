//
//  EventController.swift
//  havr
//
//  Created by Agon Miftari on 5/8/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import MBProgressHUD
class EventController: UIViewController {
    
    //MARK: - OUTLETS
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var userDetailsView: UIView!
    @IBOutlet weak var loadingPostsActivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tapOnCameraView: UIView!
    
    @IBOutlet weak var progressWidthConstraint: NSLayoutConstraint!
    //MARK: - VARIABLES
    let images = [#imageLiteral(resourceName: "M moreChat icon"), #imageLiteral(resourceName: "E more icon")]
    var progress: SegmentedProgressBar! = {
        let progress = SegmentedProgressBar(frame: CGRect(x: 0, y: 0, width: 320 , height: 4))
        progress.topColor = UIColor.white
        progress.bottomColor = UIColor.white.withAlphaComponent(0.25)
        return progress
    }()
    
    fileprivate var event: Event!
    fileprivate var eventPosts: EventPosts!
    
    var posts: [EventPost] {
        return eventPosts.posts
    }
    
    var pagination: Pagination { return eventPosts.pagination }
    
    //MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionInit()
        setupEventBar()
        loadResource()
        checkIfUserCanUpload()
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        GA.TrackScreen(name: "Event")
        imageView.loadGif(name: "giphy")
        UIApplication.shared.isStatusBarHidden = true
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        UIApplication.shared.isStatusBarHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.tabBarController?.tabBar.isHidden = false
    }
    
    func collectionInit() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerEventsCollectionCell()
    }
    
    func setupEventBar() {
        progress.delegate = self
        self.progressView.addSubview(progress)
    }
    
    func fillUserwith(post: EventPost) {
        if post.isAnon {
            userImageView.image = Constants.anonimImage
            usernameLabel.text = "Anonymous"
        } else if let user = post.user {
            userImageView.kf.setImage(with: user.getUrl(), placeholder: Constants.defaultImageUser)
            usernameLabel.text = user.getFirstName()
        }
        timeLabel.text = "\(post.created.timeAgoSinceDate())"
    }
    
    fileprivate func checkIfUserCanUpload(){
        let eventLocation = CLLocation.init(latitude: self.eventPosts.event.latitude, longitude: self.eventPosts.event.longitude)
        
        if self.eventPosts.event.isOwner{
            cameraButton.isHidden = false
            tapOnCameraView.isHidden = false
            
        }else if let currentLocation = AccountManager.currentLocation{
            let distance = eventLocation.distance(from: currentLocation)
            let shouldHide = distance > 1000
            cameraButton.isHidden = shouldHide
            tapOnCameraView.isHidden = shouldHide
        }
    }
    
    fileprivate func changeStatus(paused: Bool) {
        progress?.isPaused = paused
        
        guard let cell = self.collectionView.visibleCells.first as? EventsCollectionCell else { return }
        
        cell.changePlayerStatus(paused: paused)
    }
    
    fileprivate func loadResource(reset: Bool = false) {
        if eventPosts.fetchedPosts && reset {
            loadingPostsActivityIndicatorView.hide()
        }
        
        if posts.count > 0 {
            self.collectionView.reloadData()
            self.updateProgresBarView()
            
            self.updateView()
            if reset {
                return
            }
        }
        
        EventPostAPI.getPosts(byEvent: self.eventPosts.event.id, page: 1) { (posts, pagination, error) in
            if let posts = posts, let pagination = pagination {
                self.eventPosts.posts = posts
                self.eventPosts.pagination = pagination
                self.eventPosts.fetchedPosts = true
                self.collectionView.reloadData()
                self.updateProgresBarView()
                
                self.updateView()
            }
        }
    }
    fileprivate func updateView() {
        if eventPosts.fetchedPosts {
            self.loadingPostsActivityIndicatorView.hide()
            
            if self.posts.count == 0 {
                //self.noPostsView.show(to: collectionView)
            } else {
                // self.noPostsView.hide()
            }
        }
    }
    
    func updateProgresBarView(){
        progressWidthConstraint.constant = segmentWidth() * CGFloat(self.posts.count)
        progressView.layoutIfNeeded()
        progressView.updateConstraints()
        progress.frame = CGRect(x: 0, y: 0, width: progressWidthConstraint.constant, height: 4)
        progress.setup(posts: self.posts)
        if self.posts.count > 0 {
            progress.startAnimation()
        }
    }
    func goToIndex(index: Int) {
        
        if index > self.posts.count - 1 || index < 0 {
            return
        }
        
        let newIndexPath = IndexPath(item: index, section: 0)
        self.collectionView.scrollToItem(at: newIndexPath, at: .centeredHorizontally, animated: false)
        self.collectionView.reloadItems(at: [newIndexPath])
        
        let pageWidth = scrollView.frame.width
        let ind = Int(CGFloat(segmentWidth() * CGFloat(index)))
        let point = CGPoint(x: ind, y: 0)
        let rect = CGRect(x: ind, y: 0, width: Int(segmentWidth()), height: 4)
        self.scrollView.scrollRectToVisible(rect, animated: true)
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            let pageWidth = scrollView.frame.width
            let index = Int(scrollView.contentOffset.x / pageWidth)
            goToIndex(index: index)
        }
    }
    
    func backFunction(){
        UIView.animate(withDuration: 2.0, delay: 0, options: .curveEaseOut, animations: {
            self.pop()
        })
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func showReportOptions(for post: EventPost){
        var reportMessage: ReportPostMessage = .accountHacked
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        
        alert.addAction(UIAlertAction(title: ReportPostMessage.accountHacked.description, style: .default, handler: {(action) in
            self.reportPost(post: post, message: reportMessage)
        }))
        
        alert.addAction(UIAlertAction(title: ReportPostMessage.inappropriate.description, style: .default, handler: {(action) in
            reportMessage = .inappropriate
            self.reportPost(post: post, message: reportMessage)
        }))
        
        alert.addAction(UIAlertAction(title: ReportPostMessage.spam.description, style: .default, handler: {(action) in
            reportMessage = .spam
            self.reportPost(post: post, message: reportMessage)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action) in
            
        }))
        
        if let wPPC = alert.popoverPresentationController {
            let barButtonItem = self.navigationItem.rightBarButtonItem!
            let buttonItemView = barButtonItem.value(forKey: "view")
            wPPC.sourceView = buttonItemView as? UIView
            wPPC.sourceRect = (buttonItemView as AnyObject).bounds
        }
        alert.view.tintColor = Apperance.appBlueColor
        self.present(alert, animated: true, completion: nil)
        alert.view.tintColor = Apperance.appBlueColor
    }
    
    func reportPost(post: EventPost, message: ReportPostMessage){
        self.showHud()
        EventPostAPI.report(post: post, reportMessage: message, reportPlace: ReportPostPlace.inEvents) { (success, error) in
            self.hideHud()
            
            if success {
                MBProgressHUD.showWithStatus(view: self.view, text: "Thank you for reporting this!", image: #imageLiteral(resourceName: "SUCCESS"))
            }else {
                if let error = error  {
                    MBProgressHUD.showWithStatus(view: self.view, text: error.message, image: #imageLiteral(resourceName: "ERROR"))
                }
            }
        }
    }
    
    //MARK: - ACTIONS
    @IBAction func cameraButtonPressed(_ sender: UIButton) {
        
        changeStatus(paused: true)
        
        let kanvasNavigation = KanvasNavigationController()
        kanvasNavigation.cameraDelegate = self
        self.showModal(kanvasNavigation)
    }
    @IBAction func backButtonPressed(_ sender: UIButton) {
        backFunction()
    }
    @IBAction func moreButtonPressed(_ sender: UIButton) {
        changeStatus(paused: true)
        let indexpath = collectionView.indexPathForItem(at: collectionView.contentOffset)
        let post = (collectionView.cellForItem(at: indexpath!) as! EventsCollectionCell).event
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Report media", style: .destructive, handler:  {
            (alert: UIAlertAction!) -> Void in
            self.showReportOptions(for: post!)
        } ))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action) in
            self.changeStatus(paused: false)
        }))
        
        if let wPPC = alert.popoverPresentationController {
            let barButtonItem = self.navigationItem.rightBarButtonItem!
            let buttonItemView = barButtonItem.value(forKey: "view")
            wPPC.sourceView = buttonItemView as? UIView
            wPPC.sourceRect = (buttonItemView as AnyObject).bounds
        }
        alert.view.tintColor = Apperance.appBlueColor
        self.present(alert, animated: true, completion: nil)
        alert.view.tintColor = Apperance.appBlueColor
    }
    
    deinit {
        print("Deinit EventController")
    }
}
//MARK: - EXTENSIONS
extension EventController {
    static func create(for event: Event) -> EventController {
        let eventController =  UIStoryboard.explore.instantiateViewController(withIdentifier: "EventController") as! EventController
        eventController.event = event
        
        let eventsPost = EventPostsManager.shared.getOrCreate(for: event)
        eventController.eventPosts = eventsPost
        return eventController
    }
}

extension EventController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.posts.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueEventsCollectionCell(indexpath: indexPath)
            let event = self.posts[indexPath.item]
        
            cell.event = event
            cell.delegate = self
        
            fillUserwith(post: event) 
            self.userDetailsView.isHidden = false
            return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let width = collectionView.frame.width
            let height = collectionView.frame.height
            return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? EventsCollectionCell else {
            return
        }
        
        cell.removeAndStop()
    }
    
    func minPosts() -> Int{
        return min(self.posts.count, 6)
    }
    func segmentWidth() -> CGFloat {
        return (scrollView.frame.width / max(1,CGFloat(minPosts())))
    }
}

extension EventController: SegmentedProgressBarDelegate {
    func segmentedProgressBarChangedIndex(index: Int){
        goToIndex(index: index)
    }
    func segmentedProgressBarFinished(){
        backFunction()
    }
}
extension EventController: EventsCollectionCellDelegate {
    func eventsCollectionCell(sender: EventsCollectionCell, isLoading: Bool) {
        progress?.isPaused = isLoading
    }
    
    func eventsCollectionCell(sender: EventsCollectionCell, isTouching: Bool) {
        if isTouching {
            progress?.isPaused = true
        }else {
            progress?.isPaused = false
        }
    }
    
    func eventsCollectionCell(sender: EventsCollectionCell, didTapForward forward: Bool) {
        if forward {
            progress?.skip()
        } else {
            progress?.rewind()
        }
    }
}

//MARK: - Kanvas Camera NAvigationController Delegate
extension EventController: KanvasCameraControllerDelegate {
    func camera(sender: KanvasNavigationController, didFinishPicking media: Media) {
        print("finish picking media: \(media)")
        AppDelegate.disableScreenOrientation()
        
        self.showHud()
        sender.hideModal()
        media.upload(deleteOnUpload: true, completion: { (media, success, error) in
            self.hideHud()
            if success {
                let event = EventPost.create(from: media, event: self.eventPosts.event.id)
                
                EventPostAPI.create(event: event, completion: { (newEvent, error) in
                    if let newEvent = newEvent {
                        self.loadResource(reset: true) //reset events
                        
                    } else if let error = error {
                        Helper.show(alert: error.message)
                    }
                })
                
            } else if let error = error {
                Helper.show(alert: error)
            }
        }, progress: nil)
    }
}

//MARK: Empty View Delegate
extension EventController: EmptyDataViewDelegate {
    func emptyDataView(sender: EmptyDataView, didPress action: UIButton) {
        print("create posts")
        
        cameraButtonPressed(action)
    }
}
