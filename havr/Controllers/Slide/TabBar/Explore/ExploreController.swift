//
//  ExploreController.swift
//  havr
//
//  Created by Arben Pnishi on 4/21/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import UIScrollView_InfiniteScroll
import SwiftyTimer
import Alamofire

/// Point of Interest Item which implements the GMUClusterItem protocol.
class POIItem: NSObject, GMUClusterItem {
    var position: CLLocationCoordinate2D
    var name: String!
    var marker: GMSMarker!
    var icon: UIImage!
    
    init(position: CLLocationCoordinate2D, name: String) {
        self.position = position
        self.name = name
    }
    
    init(marker: GMSMarker) {
        self.position = marker.position
        self.marker = marker
        self.name = ""
        self.icon = UIImage.renderUIViewToImage(marker.iconView!)
    }
}

class ExploreController: UIViewController {
    
    //MARK: - OUTLETS
    @IBOutlet weak var leftBarButton: UIBarButtonItem!
    @IBOutlet weak var rightBarButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var bottomViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatOrEventView: ChatOrEventView!
    
    var exploreList: ExploreListController!
    //MARK: - VARIABLES
    
    var locationManager = CLLocationManager()
    var camera = GMSCameraPosition()
    var searchedTypes = ["bakery", "bar", "cafe", "grocery_or_supermarket", "restaurant"]
    
    var userLocation : CLLocation?
    
    let dataProvider = GoogleDataProvider()
    let searchRadius: Double = 1000
    
    var leftBar : UIBarButtonItem?
    var rightBar : UIBarButtonItem?
    
    fileprivate var isSearching : Bool = false
    fileprivate var didSetCamera: Bool = false
    fileprivate var didAnimateCamera: Bool = false

    
    fileprivate var didLoadResources = false
    lazy var searchBar : UISearchBar = {
        Helper.exploreStatusBar(placeholder: "Search events")
    }()
    var pagination = Pagination()
    var swiftyTimer: SwiftyTimer.Timer?
    
    var exploreModelView: ExploreModelView {
        return ExploreModelView.shared
    }
    lazy var pullRefresh: UIRefreshControl = {
        let r = UIRefreshControl()
        r.addTarget(self, action: #selector(pullRefreshReload), for: .valueChanged)
        return r
    }()
    
    lazy var locationPermission : AllowPermissionView = {
        let lP = AllowPermissionView.createForLocation()
        return lP
    }()
    
    private var clusterManager: GMUClusterManager?
    
    fileprivate var eventsRequest: DataRequest?
    fileprivate var chatRoomsRequest: DataRequest?
    
    //MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        tableInit()
        //        setupMapView()
        //        setupClusterManager()
        
        leftBar = navigationItem.leftBarButtonItem
        rightBar = navigationItem.rightBarButtonItem
        
        NotificationCenter.default.addObserver(self, selector: #selector(exploreModelViewChanged), name: NSNotification.Name(rawValue: "ExploreModelViewChanged"), object: nil)
        
        locationPermission.permissionButtonPressed = permissionButtonPressed
        
        chatOrEventView.actionButtonChatRoom = actionButtonClicked
        chatOrEventView.actionButtonEvent = actionButtonClickedEvent
        
        bottomViewConstraint.constant = -self.chatOrEventView.frame.height - 10
        
        NotificationCenter.default.addObserver(self, selector: #selector(appEnterForeground), name: Constants.AppEnterForegroundNotification, object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("ExploreController DidAppear")
        setupMapView()
        setupClusterManager()
        
        self.loadResources()
        self.loadEvents()

        Helper.setupNavSearchBar(searchBar: searchBar)
        
        let searchBarContainer = SearchBarContainerView(customSearchBar: searchBar)
        searchBarContainer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 30)
        navigationItem.titleView = searchBarContainer
        searchBar.delegate = self
        
//        navigationController?.navigationBar.isTranslucent = false
//        navigationController?.navigationBar.barTintColor = .white
//        navigationController?.navigationBar.backgroundColor = .white
        
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        GA.TrackScreen(name: "Explore Map")

        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.tabBarController?.tabBar.isHidden = false
        
//        self.navigationController?.navigationBar.isTranslucent = false
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .default
        hideBottomView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func tableInit() {
        //        tableView.delegate = self
        //        tableView.dataSource = self
        tableView.registerEventOrChatTableCell()
        self.tableView.addSubview(pullRefresh)
        
        tableView.addInfiniteScroll { (table) in
            self.searchMoreItems()
        }
        
        tableView.setShouldShowInfiniteScrollHandler { (table) -> Bool in
            return self.pagination.hasNext
        }
    }
    func pullRefreshReload(sender: UIRefreshControl){
        if searchBar.text!.isEmpty {
            pullRefresh.endRefreshing()
            return
        }
        pagination = Pagination()
        searchItem(with: searchBar.text!)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func permissionButtonPressed() {
        UIApplication.shared.openURL(NSURL(string:UIApplicationOpenSettingsURLString)! as URL)
    }
    
    func appEnterForeground(notification: Notification) {
        setupMapView()
    }
    
    func actionButtonClicked(for chatRoom: ChatRoom) {
        if chatRoom.isMember {
            print("IsMember")
            //push to chatRoom
            let chatRoomVC = ExploreConversationController.create(chatRoom: chatRoom)
            let nav = UINavigationController(rootViewController: chatRoomVC)
            
            delay(delay: 0.1, closure: {
                self.showModal(nav)
            })
            
        } else {
            print("Join")
            
            ChatRoomAPI.joinRoom(with: chatRoom.id, completion: { (success, error) in
                if success {
                    //pusht to chatRoom
                    chatRoom.isMember = true
                    let chatRoomVC = ExploreConversationController.create(chatRoom: chatRoom)
                    let nav = UINavigationController(rootViewController: chatRoomVC)
                    self.showModal(nav)
                }
                if let error = error {
                    Helper.show(alert: error.message)
                }
            })
        }
    }
    
    func actionButtonClickedEvent(for event: Event) {
        if event.isLive {
            if event.isMember {
                let eventVC = EventController.create(for: event)
                push(eventVC)
            } else {
                EventAPI.joinEvent(event: event, completion: { (success, error) in
                    if success {
                        event.isMember = true
                        let eventVC = EventWelcomeController.create()
                        eventVC.event = event
                        self.push(eventVC)
                    }
                })
            }
        } else {
            let eventVC = EventWelcomeController.create()
            eventVC.event = event
            self.push(eventVC)
        }
    }
    
    func searchItem(with name: String) {
        
    }
    
    
    func searchMoreItems() {
        guard let name = searchBar.text, !name.isEmpty else {
            self.tableView.finishInfiniteScroll()
            return
        }
        EventAPI.searchEvents(by: name, page: pagination.nextPage) { (query, eventWrapper, error) in
            // guard let `self` = self else { return }
            guard let text = self.searchBar.text else { return }
            
            if text == query {
                if let eventWrapper = eventWrapper {
                    let events = eventWrapper.events
                    
                    //add event to model
                    // should create model for events and chatroom
                    
                    
                    print("Events: \(events.count)")
                    self.pagination = eventWrapper.pagination
                    self.tableView.reloadData()
                    
                }
            }
            self.tableView.finishInfiniteScroll()
            
            if let error = error {
                print("Error Event: \(error.message)")
            }
        }
        
        ChatRoomAPI.searchRooms(name: name, page: pagination.nextPage) { (query, chatroomWrapper, error) in
            //guard let `self` = self else { return }
            guard let text = self.searchBar.text else { return }
            
            if text == query {
                if let chatroomWrapper = chatroomWrapper {
                    let chatrooms = chatroomWrapper.chatroom
                    
                    //add chatroom to model
                    // should create model for events and chatroom
                    print("Chatrooms: \(chatrooms.count)")
                    
                    self.pagination = chatroomWrapper.pagination
                    self.tableView.reloadData()
                }
            }
            self.tableView.finishInfiniteScroll()
            
            if let error = error {
                print("Error Chatroom: \(error.message)")
            }
        }
    }
    
    
    func loadResources() {
        
        var name: String? = nil
        
        if let text = searchBar.text, !text.isEmpty {
            name = text
        }
        chatRoomsRequest?.cancel()
        if !didSetCamera {
            self.showHud()
        }
        
        chatRoomsRequest = ChatRoomAPI.getRooms(role: nil, page: 1, name: name) { (rooms, pagination, error) in
            self.hideHud()
            if let rooms = rooms, let pagination = pagination {
                self.exploreModelView.allChatRooms = rooms
                self.exploreModelView.allChatRoomsPagination = pagination
            }
            
            if let error = error {
                print("Chatroom Event: \(error.message)")
//                Helper.show(alert: error.message)
            }
        }
    }
    
    func loadEvents() {
        
        var name: String? = nil
        
        if let text = searchBar.text, !text.isEmpty {
            name = text
        }
        eventsRequest?.cancel()
        self.hideHud()
        eventsRequest = EventAPI.getEvents(status: nil, name: name, maxDistance: nil) { (eventWrapper, error) in
            self.hideHud()
            if let eventWrapper = eventWrapper {
                let events = eventWrapper.events
                let pagination = eventWrapper.pagination
                
                self.exploreModelView.allEvents = events
                self.exploreModelView.allEventsPagination = pagination
            }
            
            if let error = error {
                print("Error Event: \(error.message)")
            }
        }
    }
    
    func exploreModelViewChanged(notification: Notification) {
        //update Views
        
        //generate markers
        updateMarkers()
        
        if let text = searchBar.text, text.isEmpty {
            return
        }
        
        //find nearest market and set location to that point
        var nearestPosition: MapObject?
        
        for i in ExploreModelView.shared.allMapObjects {
            if let distance = i.distance {
                if let nsPos = nearestPosition, let olddistance = nsPos.distance {
                    if olddistance > distance {
                        nearestPosition = i
                    }
                } else {
                    nearestPosition = i
                }
            }
        }
        
        if let nearestPosition = nearestPosition {
            guard let position = nearestPosition.position else { return  }
            
            camera = GMSCameraPosition(target: position, zoom: 12, bearing: 0, viewingAngle: 0)
            if !didAnimateCamera{
                mapView.animate(to: camera)
                didAnimateCamera = true
            }
        }
    }
    
    func setupMapView(){
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()
        
        mapView.delegate = self
//        mapView.camera = camera
        mapView.isMyLocationEnabled = true
        mapView.settings.zoomGestures = true
        
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .restricted, .denied:
                print("No Access")
                locationPermission.show(to: self.navigationController!.view)
            case .notDetermined:
                print("Not Determined")
                locationPermission.hide()
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
                locationPermission.hide()
                locationManager.startUpdatingLocation()
            }
        } else {
            locationPermission.hide()
            print("Location services are not enabled")
        }
    }
    
    func setupClusterManager(){
        if clusterManager != nil {
            return
        }
        // Set up the cluster manager with default icon generator and renderer.
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)
        
        // Generate and add random items to the cluster manager.
        //        generateClusterItems()
        
        // Call cluster() after items have been added to perform the clustering and rendering on map.
        
        clusterManager?.cluster()
        
        // Register self to listen to both GMUClusterManagerDelegate and GMSMapViewDelegate events.
        clusterManager?.setDelegate(self, mapDelegate: self)
    }
    
    //MARK: - ACTIONS
    
    @IBAction func rightBarButtonClicked(_ sender: UIBarButtonItem) {
        
        hideBottomView()
        if exploreList == nil {
            exploreList = ExploreListController.create()
        }
        
        let transition = CATransition()
        transition.duration = 0.4
        transition.type = "flip"
        transition.subtype = kCATransitionFromLeft
        exploreList.userLocation = userLocation
        self.navigationController?.view.layer.add(transition, forKey: kCATransition)
        self.navigationController?.pushViewController(exploreList, animated: false)
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        hideBottomView()
        let createChatEventVC = CreateChatorEventController.create()
        createChatEventVC.userLocation = self.userLocation
        self.push(createChatEventVC)
    }
    
    func updateMarkers() {
        mapView.clear()
        clusterManager?.clearItems()
        
        for chatRoom in ExploreModelView.shared.allChatRooms where chatRoom.marker != nil {
            //            chatRoom.marker?.map = self.mapView
            let item = POIItem.init(marker: chatRoom.marker!)
            clusterManager?.add(item)
        }
        
        for event in ExploreModelView.shared.allEvents where event.marker != nil {
            //            event.marker?.map = self.mapView
            let item = POIItem.init(marker: event.marker!)
            clusterManager?.add(item)
        }
        clusterManager?.cluster()
    }
    
    // MARK: - Private
    
    /// Randomly generates cluster items within some extent of the camera and adds them to the
    /// cluster manager.
    private func generateClusterItems() {
        let extent = 0.2
        for index in 1...10000 {
            let lat = -33.8 + extent * randomScale()
            let lng = 151.2 + extent * randomScale()
            let name = "Item \(index)"
            let item = POIItem(position: CLLocationCoordinate2DMake(lat, lng), name: name)
            clusterManager?.add(item)
        }
    }
    
    /// Returns a random value between -1.0 and 1.0.
    private func randomScale() -> Double {
        return Double(arc4random()) / Double(UINT32_MAX) * 2.0 - 1.0
    }
    
    func showBottomView() {
        self.bottomViewConstraint.constant = 59
        delay(delay: 0) {
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func hideBottomView() {
        self.bottomViewConstraint.constant = -self.chatOrEventView.frame.height - 59
        delay(delay: 0) {
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }
    }
}

//MARK: - EEXTENSIONS
extension ExploreController {
    static func create() -> ExploreController {
        return UIStoryboard.explore.instantiateViewController(withIdentifier: "ExploreController") as! ExploreController
    }
}


extension ExploreController: CLLocationManagerDelegate, GMSMapViewDelegate {
    
    //MARK : - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error to get location : \(error) ")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .denied || status == .restricted {
            self.locationPermission.show(to: self.navigationController!.view)
        }else {
            self.locationPermission.hide()
            locationManager.startUpdatingLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0 {
            if let uL = locations.first {
                userLocation = uL
                AccountManager.currentLocation = uL
                
                camera = GMSCameraPosition(target: uL.coordinate, zoom: 12, bearing: 0, viewingAngle: 0)
                LocationManager.shared.lastLocation = uL
                
                if !didSetCamera {
                    self.mapView.camera = camera
                    didSetCamera = true
                }
                
                manager.stopUpdatingLocation()
                
                if !didLoadResources {
                    didLoadResources = true
                    UsersAPI.updateLocation(with: uL.coordinate.latitude, longitude: uL.coordinate.longitude, completion: { (success, error) in
                        if !success{
                            manager.startUpdatingLocation()
                            self.didLoadResources = false
                        }else {
                            delay(delay: 0, closure: {
                                self.loadResources()
                                self.loadEvents()
                            })
                            manager.stopUpdatingLocation()
                        }
                    })
                }
            }
        }
    }
    
    //MARK : - GMSMapViewDelegate
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        if let poiItem = marker.userData as? POIItem {
            console("Did tap marker for cluster item \(poiItem.name!)")
            if let item = ExploreModelView.shared.getItem(for: poiItem.marker) {
                if let chatRoom = item as? ChatRoom {
                    showBottomView()
                    chatOrEventView.chatRoom = chatRoom
                }
                if let event = item as? Event {
                    showBottomView()
                    chatOrEventView.event = event
                }
            }
        } else {
            console("Did tap a normal marker")
            let newCamera = GMSCameraPosition.camera(withTarget: marker.position,
                                                     zoom: mapView.camera.zoom + 1)
            mapView.animate(to: newCamera)
        }
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        hideBottomView()
        if !isSearching {
            hideSearchResult()
        }
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        hideBottomView()
        if !isSearching {
            hideSearchResult()
        }
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        self.mapView.isMyLocationEnabled = true
        self.locationManager.startUpdatingLocation()
        return false
    }
}

extension ExploreController: GMUClusterManagerDelegate{
    // MARK: - GMUClusterManagerDelegate
    
    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
        let newCamera = GMSCameraPosition.camera(withTarget: cluster.position,
                                                 zoom: mapView.camera.zoom + 1)
        mapView.animate(to: newCamera)
        return false
    }
}

extension ExploreController: UISearchBarDelegate, UIScrollViewDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        Helper.showSearchBar(searchBar: searchBar, navigationItem: navigationItem, newFrameWidth: view.frame.size.width)
        isSearching = true
        isSearching = true
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //        search(with: searchText)
        isSearching = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text != "" {
            searchBar.text = nil
            delay(delay: 0, closure: {
                self.loadResources()
                self.loadEvents()
            })
        }
        isSearching = false
        hideSearchResult()
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text, !text.isEmpty {
            didAnimateCamera = false
            didSetCamera = false
            
            delay(delay: 0, closure: {
                self.loadResources()
                self.loadEvents()
            })
            
            let showAllResultsItem = UIBarButtonItem(title: "Show All", style: .plain, target: self, action: #selector(ExploreController.showAllResults))
            self.navigationItem.rightBarButtonItem  = showAllResultsItem
            searchBar.showsCancelButton = false
            searchBar.resignFirstResponder()
        }
    }
    func hideSearchResult() {
        if let l = leftBar, let r = rightBar {
            Helper.hideSearchBar(searchBar: searchBar, navigationItem: navigationItem, leftBar: l, rightBar: r)
            tableView.isHidden = true
        }
//        searchBar.text = nil
    }
    func search(with text: String) {
        
        if text.isEmpty {
            swiftyTimer?.invalidate()
            return
        }
        
        swiftyTimer?.invalidate()
        swiftyTimer = SwiftyTimer.Timer.after(0.35, {
            self.searchItem(with: text)
        })
    }
    
    func showAllResults(){
        
        if searchBar.text != "" {
            searchBar.text = nil
            delay(delay: 0, closure: {
                self.loadResources()
                self.loadEvents()
            })
        }
        isSearching = false
        hideSearchResult()
    }
}

