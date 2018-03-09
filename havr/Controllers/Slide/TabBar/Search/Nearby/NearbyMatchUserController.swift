//
//  NearbyMatchUserController.swift
//  havr
//
//  Created by Ismajl Marevci on 4/21/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import Koloda
import MBProgressHUD
import CoreLocation

class NearbyMatchUserController: UIViewController {
    
    //MARK: - OUTLETS
    @IBOutlet weak var buttonsHolderView: UIView!
    @IBOutlet weak var thirdView: UIView!
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var matchButtonView: UIView!
    @IBOutlet weak var kolodaView: KolodaView!
    @IBOutlet weak var rightBarButton: UIBarButtonItem!
    @IBOutlet weak var leftBarButton: UIBarButtonItem!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var rotationFrameView: UIView!
    @IBOutlet weak var cotainerView: UIView!
    
    
    //MARK: - VARIABLES
    fileprivate var users: [User] = []
    fileprivate var selectedUser: Int = 0
    fileprivate var pagination = Pagination()
    fileprivate var kolodaDataSource: [NearbyKoloda] = []
    
    var searchFilter: SearchFilter = SearchFilter()
    var locationManager = CLLocationManager()
    
    lazy var locationPermission : AllowPermissionView = {
        let lP = AllowPermissionView.createForLocation()
        return lP
    }()
    
    //MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationPermission.permissionButtonPressed = permissionButtonPressed
        
        NotificationCenter.default.addObserver(self, selector: #selector(appEnterForeground), name: Constants.AppEnterForegroundNotification, object: nil)
        delay(delay: 0) {
            self.setupLocationView()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GA.TrackScreen(name: "Nearby")
        
        if let filter = SearchFilter.get() {
            searchFilter = filter
        }
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        responseRadiusViews()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        responseRadiusViews()
    }
    
    //MARK: - FUNCTIONS
    func commonInit() {
        kolodaView.dataSource = self
        kolodaView.delegate = self
        
        self.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
        matchButtonView.isHidden = false
        
        addHeartBeatAnimation(view: firstView, toMaxValue: 0.8, toMinValue: 0.4)
        addHeartBeatAnimation(view: secondView, toMaxValue: 0.75, toMinValue: 0.55)
        addHeartBeatAnimation(view: thirdView, toMaxValue: 0.4, toMinValue: 0.6)
    }
    
    func setupLocationView(){
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()
        
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case  .restricted, .denied:
                print("No Access")
                locationPermission.show(to: self.cotainerView)
            case .notDetermined:
                print("Not Determined")
                locationPermission.hide()
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
                locationPermission.hide()
                commonInit()
                search()
                locationManager.startUpdatingLocation()
            }
        } else {
            locationPermission.hide()
            print("Location services are not enabled")
        }
    }
    
    func permissionButtonPressed() {
        UIApplication.shared.openURL(NSURL(string:UIApplicationOpenSettingsURLString)! as URL)
    }
    
    func connectUser(sender: UIButton, for user: User) {
        let type = user.getConnectionActionType()
        switch type {
        case .remove:
            let alert = UIAlertController(title: "Alert", message: "Are you sure you want to disconnect this user?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
                ConnectionsAPI.makeAction(with: type, userId: user.id) { (success, error) in
                    if success{
                        user.setStatus(with: type)
                        self.kolodaView?.swipe(.right)
                    }else{
                        
                    }
                }
            }))
            
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: {(action) in
                
            }))
            
            alert.view.tintColor = Apperance.appBlueColor
            self.present(alert, animated: true, completion: nil)
            alert.view.tintColor = Apperance.appBlueColor
            
            break
        default:
            ConnectionsAPI.makeAction(with: type, userId: user.id) { (success, error) in
                if success{
                    user.setStatus(with: type)
                }else{
                    
                }
            }
        }
    }
    
    func appEnterForeground(notification: Notification) {
        setupLocationView()
    }
    
    func search() {
        UsersAPI.search(gender: searchFilter.gender, minAge: searchFilter.minAge, maxAge: searchFilter.maxAge, distance: searchFilter.distance, page: pagination.nextPage) { (usersArray, pagination, error) in
            if let users = usersArray, let pagination = pagination {
                self.createKolodas(with: users)
                self.users += users
                self.pagination = pagination
            }
            self.kolodaView.reloadData()
        }
    }
    
    func createKolodas(with users: [User]){
        for user in users {
            let nearbyKoloda = Bundle.main.loadNibNamed("NearbyKoloda", owner: self, options: nil)?[0] as! NearbyKoloda
            nearbyKoloda.user = user
            nearbyKoloda.updateFileds()
            nearbyKoloda.fetchProfile()
            nearbyKoloda.interestView.delegate = self
            kolodaDataSource.append(nearbyKoloda)
        }
    }
    
    func responseRadiusViews(){
        let butonRadius = acceptButton.frame.size.height / 2
        acceptButton.layer.cornerRadius = butonRadius
        cancelButton.layer.cornerRadius = butonRadius
        
        self.rotationFrameView.transform = CGAffineTransform(rotationAngle: CGFloat(-0.0666666))
    }
    
    
    func addHeartBeatAnimation(view: UIView, toMaxValue: CGFloat, toMinValue: CGFloat) {
        let beatLong: CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
        beatLong.fromValue = 1.0
        beatLong.toValue = toMaxValue
        beatLong.autoreverses = true
        beatLong.duration = 0.7
        beatLong.beginTime = 0.0
        beatLong.repeatCount = 1
        
        let beatShort: CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
        beatLong.fromValue = 1.0
        beatShort.toValue = toMinValue
        beatShort.autoreverses = true
        beatShort.duration = 0.5
        beatShort.beginTime = beatLong.duration
        beatLong.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        
        let heartBeatAnim: CAAnimationGroup = CAAnimationGroup()
        heartBeatAnim.animations = [beatLong, beatShort]
        heartBeatAnim.duration = beatShort.beginTime + beatShort.duration + 0.5
        heartBeatAnim.fillMode = kCAFillModeForwards
        heartBeatAnim.isRemovedOnCompletion = false
        heartBeatAnim.repeatCount = 1000
        view.layer.add(heartBeatAnim, forKey: nil)
    }
    
    //MARK: - ACTIONS
    @IBAction func cancelButtonClicked(_ sender: UIButton) {
        kolodaView?.swipe(.left)
    }
    @IBAction func leftBarButtonPressed(_ sender: UIBarButtonItem) {
        self.pop()
    }
    @IBAction func acceptButtonClicked(_ sender: UIButton) {
        let user = users[selectedUser]
        switch user.status {
        case .connected:
            connectUser(sender: sender, for: user)
            break
        case .connect:
            connectUser(sender: sender, for: user)
            kolodaView?.swipe(.right)
            break
        case .declined:
            connectUser(sender: sender, for: user)
            kolodaView?.swipe(.right)
            break
        case .requested:
            connectUser(sender: sender, for: user)
            kolodaView?.swipe(.right)
            break
        case .requesting:
            let nearbyConnection = NearbyConnectionController.create()
            nearbyConnection.user = users[selectedUser]
            connectUser(sender: sender, for: user)
            self.showModal(nearbyConnection)
            kolodaView?.swipe(.right)
            break
        case .blocked:
            connectUser(sender: sender, for: user)
            kolodaView?.swipe(.right)
            break
        case .blocking:
            connectUser(sender: sender, for: user)
            kolodaView?.swipe(.right)
            break
        }
    }
    @IBAction func rightBarButtonClicked(_ sender: UIBarButtonItem) {
        let searchF = SearchFiltersController.create()
        searchF.delegate = self
        let searchNav = UINavigationController(rootViewController: searchF)
        self.showModal(searchNav)
    }
    
    func updateAnimation(){
        let showContainer: CGFloat = self.users.count > 0 ? 1.0 : 0.0
        let showAnimation: CGFloat = showContainer == 1.0 ? 0.0 : 1.0

        UIView.animate(withDuration: 0.1, animations: {
            self.cotainerView.alpha = showContainer
            self.matchButtonView.alpha = showAnimation
        }, completion: { (completed) in
            
        })
    }
    
    func restartSearch(andPagination: Bool = true){
        if andPagination {
            pagination = Pagination()
        }
        kolodaDataSource.removeAll()
        users.removeAll()
        kolodaView.reloadData()
        updateAnimation()
        search()
    }
}
//MARK: - EXTENSIONS
extension NearbyMatchUserController {
    static func create() -> NearbyMatchUserController {
        return UIStoryboard.search.instantiateViewController(withIdentifier: "NearbyMatchUserController") as! NearbyMatchUserController
    }
}

extension NearbyMatchUserController: KolodaViewDelegate {
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        restartSearch(andPagination: false)
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        
    }
    
    func koloda(_ koloda: KolodaView, didShowCardAt index: Int) {
        buttonsHolderView.isHidden = false
        let user = users[index]
        
        self.selectedUser = index
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        let user = users[index]
        switch direction {
        case .right:
            connectUser(sender: UIButton(), for: user)
        default:
            ConnectionsAPI.excludeFromNearbySearch(with: user.id, completion: { (success, error) in
                if success{
                    console ("Excluded success")

                }else{
                    console ("Excluded error")
                }
            })
        }
        console("koloda didSwipeCardAt: \(index) in direction: \(direction)")
    }
    
}
extension NearbyMatchUserController: KolodaViewDataSource {
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        updateAnimation()
        return users.count
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .default
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        return kolodaDataSource[index]
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        //        return kolodaDataSource[index]
        return nil
    }
}

extension NearbyMatchUserController: InterestViewDelegate {
    func didSelect(contentType: InterestContent, interest: UserInterest?, in collectionCiew: UICollectionView, at indexPath: IndexPath) {
        collectionCiew.isUserInteractionEnabled = true
    }
    
    func didSave(sender: InterestView) {
        //
    }
    
    func didSelect(interest: UserInterest, at index: IndexPath) {
        let user = users[selectedUser]
        let m = MBProgressHUD.showAdded(to: self.view, animated: true)
        m.contentColor = Apperance.appBlueColor
        PostsAPI.randomPost(interest: interest.item!.id, for: user.id) { (post, error) in
            if let post = post {
                let postDetails = PostDetailController.create()
                m.hide(animated: true)
                postDetails.post = post
                self.push(postDetails)
            }else {
                MBProgressHUD.showAlert(view: self.view, text: "", image: #imageLiteral(resourceName: "S no result"), hideAfter: 1.5)
            }
        }
        m.hide(animated: true)
    }
    func didUpload(media: Media?, error: ErrorMessage?, at index: Int) {
        //
    }
}

extension NearbyMatchUserController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            manager.stopUpdatingLocation()
            AccountManager.currentLocation = location

            UsersAPI.updateLocation(with: location.coordinate.latitude, longitude: location.coordinate.longitude, completion: { (success, error) in
                if !success{
                    manager.startUpdatingLocation()
                }
            })
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .denied || status == .restricted {
            self.locationPermission.show(to: self.cotainerView)
        }else {
            self.locationPermission.hide()
            locationManager.startUpdatingLocation()
        }
    }
}

extension NearbyMatchUserController: SearchFiltersControllerDelegate {
    func searchFiltersController(sender: SearchFiltersController, updateFilter: SearchFilter, didUpdate button: UIBarButtonItem) {
        restartSearch()
    }
}

