//
//  AdminController.swift
//  havr
//
//  Created by Ismajl Marevci on 4/29/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import MapKit

enum ViewAppearFrom {
    case same
    case different
}

class AdminController: UIViewController {
    
    //MARK: - OUTLETS
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - LIFE CYCLE
    
    var navBar : UINavigationBar?
    
    var aroundMeView : AroundMeHeaderView?
    
    var isfirstTimeInController : Bool = true
    var type : ViewAppearFrom?
    
    var exploreModelView: ExploreModelView {
        return ExploreModelView.shared
    }
    
    
    lazy var emptyView : EmptyDataView = {
        let v = EmptyDataView.createForChatsEvents()
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commonInit()
        
        NotificationCenter.default.addObserver(self, selector: #selector(exploreModelViewChanged), name: NSNotification.Name(rawValue: "ExploreModelViewChanged"), object: nil)
    }
    
    
    func commonInit() {
        
        let titleView = UILabel()
        titleView.font = UIFont.navigationTitleFont
        titleView.text = "Chats"
        self.navigationItem.titleView = titleView
        
        aroundMeView = AroundMeHeaderView.instanceFromNib() as? AroundMeHeaderView
        aroundMeView?.headerLabel.text = "Edit"
        tableView.registerEventOrChatTableCell()
        type = .different
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("AdminController DidAppear")
        
        if type == .different{
            self.tabBarController?.tabBar.isHidden = true
        }
        else {
            delay(delay: 0, closure: {
                self.tabBarController?.tabBar.isHidden = true
            })
            type = .different
        }
        
        refreshTableView()
    }
    
    
    func exploreModelViewChanged(notification: Notification) {
        refreshTableView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        isfirstTimeInController = true
    }
    
    func refreshTableView() {
        if exploreModelView.myExplore.count == 0 {
            emptyView.show(to: self.view)
        } else {
            emptyView.hide()
        }
        
        self.tableView.reloadData()
    }
    
}

//MARK: - EXTENSIONS
extension AdminController {
    static func create() -> AdminController {
        return UIStoryboard.admin.instantiateViewController(withIdentifier: "AdminController") as! AdminController
    }
}


//MARK: - UITableViewDelegate, UITableViewDataSource
extension AdminController: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exploreModelView.myExplore.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueEventOrChatTableCell(index: indexPath)
        cell.delegate = self
        
        if let chatRoom = self.exploreModelView.myExplore[indexPath.item] as? ChatRoom {
            cell.bindEditChatTableCell()
            cell.chatRoom = chatRoom
            
        } else if let event = self.exploreModelView.myExplore[indexPath.item] as? Event {
            cell.bindEditEventTableCell()
            cell.event = event
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //selected row
        tableView.deselectRow(at: indexPath, animated: true)
        didSelect(at: indexPath)
    }
    
    func didSelect(at indexPath: IndexPath){
        let item = self.exploreModelView.myExplore[indexPath.item]
        
        if let chatRoom = item as? ChatRoom {
            let editChatVC = EditChatController.create()
            editChatVC.chatRoom = chatRoom
            editChatVC.delegate = self
            let editChatNav = UINavigationController(rootViewController: editChatVC)
            type = .same
            self.showModal(editChatNav)
            
            
        } else if let event = item as? Event {
            let editEventVC = EditEventController.create()
            let editEventNAV = UINavigationController(rootViewController: editEventVC)
            editEventVC.event = event
            type = .same
            self.showModal(editEventNAV)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if let view = aroundMeView {
            return view
        }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
}

extension AdminController: EditChatRoomControllerDelegate {
    func didUpdate(chatRoom: ChatRoom) {
        ExploreModelView.shared.updateChatRoom(chatroom: chatRoom)
    }
    
    func didDelete(chatRoom: ChatRoom) {
        ExploreModelView.shared.deleteChatRoom(chatroom: chatRoom.id)
    }
}

extension AdminController: EventOrChatTableCellDelegate{
    func eventOrChatTableCell(sender: EventOrChatTableCell, didPressButton button: UIButton) {
        didSelect(at: tableView.indexPath(for: sender)!)
    }
    
    func eventOrChatTableCell(sender: EventOrChatTableCell, didPressAddressWithLocation location: CLLocationCoordinate2D, placeName: String) {
        //Working in Swift new versions.
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
