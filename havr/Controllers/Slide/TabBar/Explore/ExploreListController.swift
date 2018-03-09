//
//  ExploreListController.swift
//  havr
//
//  Created by Ismajl Marevci on 4/29/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import UIScrollView_InfiniteScroll
import Alamofire
import MapKit

class ExploreListController: UIViewController {
    
    //MARK: - OUTLETS
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var leftBarButton: UIBarButtonItem!
    @IBOutlet weak var rightBarButton: UIBarButtonItem!
    
    @IBOutlet weak var myOrAroundSwitch: TwicketSegmentedControl!
    
    //MARK: - VARIABLES
    var leftBar : UIBarButtonItem?
    var rightBar : UIBarButtonItem?
    var pagination: Pagination = Pagination()
    
    var userLocation : CLLocation?
    
    lazy var searchBar : UISearchBar = {
        Helper.exploreStatusBar(placeholder: "Search events")
    }()
    
    var isMyActivity = true
    
    var exploreModelView: ExploreModelView {
        return ExploreModelView.shared
    }
    
    lazy var pullRefresh: UIRefreshControl = {
        let r = UIRefreshControl()
        r.addTarget(self, action: #selector(pullRefreshReload), for: .valueChanged)
        return r
    }()
    
    let titles = ["MY ACTIVITY", "AROUND ME"]
    
    fileprivate var eventsRequest: DataRequest?
    fileprivate var chatRoomsRequest: DataRequest?
    
    //MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commonInit()
        
        NotificationCenter.default.addObserver(self, selector: #selector(exploreModelViewChanged), name: NSNotification.Name(rawValue: "ExploreModelViewChanged"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("ExploreListController DidAppear")
        self.tabBarController?.tabBar.isHidden = false
        tableView.reloadData()
        
//        navigationController?.navigationBar.barTintColor = .white
//        navigationController?.navigationBar.backgroundColor = .white
        
//        self.navigationController?.navigationBar.shadowImage = UIImage()
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GA.TrackScreen(name: "Explore List")
        
//        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func commonInit(){
        Helper.setupNavSearchBar(searchBar: searchBar)
        
        let searchBarContainer = SearchBarContainerView(customSearchBar: searchBar)
        searchBarContainer.frame = CGRect(x: 0, y: 20, width: view.frame.width, height: 30)
        navigationItem.titleView = searchBarContainer
        searchBar.delegate = self
        
        myOrAroundSwitch.setSegmentItems(titles)
        myOrAroundSwitch.delegate = self
        //myOrAroundSwitch.tintColor = UIColor.HexToColor("#47678D")
        //myOrAroundSwitch.segmentsBackgroundColor = UIColor.HexToColor("#47678D")
        myOrAroundSwitch.sliderBackgroundColor =  UIColor.HexToColor("#47678D")
        
        leftBar = navigationItem.leftBarButtonItem
        rightBar = navigationItem.rightBarButtonItem
        
        tableView.separatorStyle = .none
        tableView.registerEventOrChatTableCell()
        self.tableView.addSubview(pullRefresh)
    }
    func pullRefreshReload(sender: UIRefreshControl){
        pagination = Pagination()
        tableView.reloadData()
        self.pullRefresh.endRefreshing()
    }
    
    //MARK: - ACTIONS
    @IBAction func rightBarButtonClicked(_ sender: UIBarButtonItem) {
        
        let transition = CATransition()
        transition.duration = 0.4
        transition.type = "flip"
        transition.subtype = kCATransitionFromRight
        self.navigationController?.view.layer.add(transition, forKey: kCATransition)
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func plusButtonClicked(_ sender: UIButton) {
        //asdf
        let createChatEventVC = CreateChatorEventController.create()
        createChatEventVC.userLocation = userLocation
        self.push(createChatEventVC)
    }
    
    func exploreModelViewChanged(notification: Notification) {
        tableView.reloadData()
    }
    
    func loadResources() {
        
        var name: String? = nil
        
        if let text = searchBar.text, !text.isEmpty {
            name = text
        }
        chatRoomsRequest?.cancel()
        
        self.showHud()
        
        chatRoomsRequest = ChatRoomAPI.getRooms(role: nil, page: 1, name: name) { (rooms, pagination, error) in
            self.hideHud()
            if let rooms = rooms, let pagination = pagination {
                self.exploreModelView.allChatRooms = rooms
                self.exploreModelView.allChatRoomsPagination = pagination
                
                self.tableView.reloadData()
            }
            
            if let error = error {
                Helper.show(alert: error.message)
            }
        }
    }
    
    func loadEvents() {
        
        var name: String? = nil
        
        if let text = searchBar.text, !text.isEmpty {
            name = text
        }
        eventsRequest?.cancel()
        eventsRequest = EventAPI.getEvents(status: nil, name: name, maxDistance: nil) { (eventWrapper, error) in

            if let eventWrapper = eventWrapper {
                let events = eventWrapper.events
                let pagination = eventWrapper.pagination
                
                self.exploreModelView.allEvents = events
                self.exploreModelView.allEventsPagination = pagination
                
                self.tableView.reloadData()
            }
            
            if let error = error {
                print("Error Event: \(error.message)")
            }
        }
    }
}
//MARK: - EXTENSIONS
extension ExploreListController {
    static func create() -> ExploreListController {
        return UIStoryboard.explore.instantiateViewController(withIdentifier: "ExploreListController") as! ExploreListController
    }
}


//MARK: - UITableViewDelegate, UITableViewDataSource
extension ExploreListController: UITableViewDelegate, UITableViewDataSource  {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isMyActivity {
            return exploreModelView.myExplore.count == 0 ? 0 : exploreModelView.myExplore.count * 2
        } else {
            return exploreModelView.noneMyExlore.count == 0 ? 0 : exploreModelView.noneMyExlore.count * 2
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.item % 2 == 0) {
            let emptyCell = UITableViewCell()
            emptyCell.backgroundColor = UIColor.clear
            return emptyCell
        }
        
        let cell = tableView.dequeueEventOrChatTableCell(index: indexPath)
        cell.delegate = self
        
        let item = isMyActivity ? exploreModelView.myExplore[(indexPath.item - 1) / 2] : exploreModelView.noneMyExlore[(indexPath.item - 1) / 2]
        
        if let chatRoom = item as? ChatRoom {
            if chatRoom.isMember {
                cell.bindViewChatTableCell()
            } else {
                cell.bindJoinChatTableCell()
            }
            cell.chatRoom = chatRoom
        } else if let event = item as? Event {
            if event.isMember {
                cell.bindViewEventTableCell()
            } else {
                cell.bindJoinEventTableCell()
            }
            cell.event = event
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //selected row
        tableView.deselectRow(at: indexPath, animated: true)
        didSelect(at: IndexPath.init(item: (indexPath.item - 1) / 2, section: 0))
    }
    
    func didSelect(at indexPath: IndexPath){
        let item = isMyActivity ? exploreModelView.myExplore[indexPath.item] : exploreModelView.noneMyExlore[indexPath.item]
        
        if let chatRoom = item as? ChatRoom {
            if chatRoom.isMember {
                let exploreConversationVC = ExploreConversationController.create(chatRoom: chatRoom)
                exploreConversationVC.isCreationScreen = false
                let nav = UINavigationController(rootViewController: exploreConversationVC)
                delay(delay: 0.1, closure: {
                    self.showModal(nav)
                })
            }else{
                ChatRoomAPI.joinRoom(with: chatRoom.id, completion: { (success, error) in
                    if success {
                        //pusht to chatRoom
                        chatRoom.isMember = true
                        let exploreConversationVC = ExploreConversationController.create(chatRoom: chatRoom)
                        
                        exploreConversationVC.isCreationScreen = false
                        let nav = UINavigationController(rootViewController: exploreConversationVC)
                        self.showModal(nav)
                    }
                    if let error = error {
                        Helper.show(alert: error.message)
                    }
                })
            }
        }else if let event = item as? Event {
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
        
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        switch section {
//        case 0:
//            return myActivity
//        case 1:
//            return aroundMeView
//        default:
//            return UIView()
//        }
//    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row % 2 == 0 {
            return 5.0
        }
        
        return 80.0
    }
}

//MARK: - Search Bar Delegate
extension ExploreListController: UISearchBarDelegate, MyActivityViewDelegate, UIScrollViewDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        Helper.showSearchBar(searchBar: searchBar, navigationItem: navigationItem)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text != "" {
            searchBar.text = nil
            delay(delay: 0, closure: {
                self.loadResources()
                self.loadEvents()
            })
        }
        hideSearchResult()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text, !text.isEmpty {
            delay(delay: 0, closure: { 
                self.loadResources()
                self.loadEvents()
            })
            
            let showAllResultsItem = UIBarButtonItem(title: "Show All", style: .plain, target: self, action: #selector(ExploreListController.showAllResults))
            self.navigationItem.rightBarButtonItem  = showAllResultsItem
            searchBar.showsCancelButton = false
            searchBar.resignFirstResponder()
        }
    }
    
    func myActivity(addChatOrEvent sender: UIButton) {
        let createChatEventVC = CreateChatorEventController.create()
        createChatEventVC.userLocation = userLocation
        self.push(createChatEventVC)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        hideSearchResult()
    }
    
    func hideSearchResult() {
        
        if let l = leftBar, let r = rightBar {
            Helper.hideSearchBar(searchBar: searchBar, navigationItem: navigationItem, leftBar: l, rightBar: r)
        }
        searchBar.text = nil
    }
    
    func showAllResults(){
        
        if searchBar.text != "" {
            searchBar.text = nil
            delay(delay: 0, closure: {
                self.loadResources()
                self.loadEvents()
            })

        }
        hideSearchResult()
        tableView.reloadData()

    }
}

extension ExploreListController: EventOrChatTableCellDelegate{
    
    func eventOrChatTableCell(sender: EventOrChatTableCell, didPressButton button: UIButton) {
        didSelect(at: tableView.indexPath(for: sender)!)
    }
    
    func eventOrChatTableCell(sender: EventOrChatTableCell, didPressAddressWithLocation location: CLLocationCoordinate2D, placeName: String) {
        
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)){
            UIApplication.shared.openURL(NSURL(string:
                "comgooglemaps://?saddr=&daddr=\(Float(location.latitude)),\(Float(location.longitude))&directionsmode=driving")! as URL)
        } else {
            let regionDistance:CLLocationDistance = 10000
            let coordinates = CLLocationCoordinate2DMake(location.latitude, location.longitude)
            let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
            ]
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = placeName
            mapItem.openInMaps(launchOptions: options)
        }
    }
}

extension ExploreListController : TwicketSegmentedControlDelegate {
    func didSelect(_ segmentIndex: Int) {
        isMyActivity = segmentIndex == 0 ? true : false
        
        tableView.reloadData()
//        delay(delay: 0, closure: {
//            self.tableView.reloadRows(at: [IndexPath.init(row: 0, section: 0)], with: .fade)
//        })
    }
}
