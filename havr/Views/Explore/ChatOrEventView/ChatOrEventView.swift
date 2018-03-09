//
//  ChatOrEventView.swift
//  havr
//
//  Created by Agon Miftari on 5/16/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import MapKit

class ChatOrEventView: UIView {
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var imgCellType: UIImageView!
    @IBOutlet weak var lblCellType: UILabel!
    
    @IBOutlet weak var bigDivider: UIView!
    @IBOutlet weak var smallDivider: UIView!
    
    var view: UIView!
    
    var chatRoom: ChatRoom! {
        didSet {
            
            if chatRoom == nil { return }
            event = nil
            setChatRoomValues()
        }
    }
    
    var event: Event! {
        didSet {
            
            if event == nil { return }
            
            chatRoom = nil
            setEventValue()
        }
    }
    var isChat : Bool{
        return chatRoom != nil
    }
    
    var actionButtonEvent: ((Event) -> Void)? = nil
    var actionButtonChatRoom: ((ChatRoom) -> Void)? = nil
    
    let strMessage = "Message"
    let strJoined = "Joined"
    let strJoin = "Join"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    func setup(){
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        return UINib(nibName: "ChatOrEventView", bundle: bundle).instantiate(withOwner: self, options: nil)[0] as! UIView
    }
    
    @IBAction func addressLabelPressed(_ sender: UITapGestureRecognizer) {
        guard let location: CLLocation = (isChat ? chatRoom.location : event.location) else { return }
        let name: String = isChat ? chatRoom.address : event.address
        
        
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)){
            UIApplication.shared.openURL(NSURL(string:
                "comgooglemaps://?saddr=&daddr=\(Float(location.coordinate.latitude)),\(Float(location.coordinate.longitude))&directionsmode=driving")! as URL)
        } else {
            let regionDistance:CLLocationDistance = 10000
            let coordinates = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
            let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
            ]
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = name
            mapItem.openInMaps(launchOptions: options)
        }
    }
    
    @IBAction func joinButtonPressed(_ sender: UIButton) {
        
        if let chatRoom = self.chatRoom {
            self.actionButtonChatRoom?(chatRoom)
        } else if let event = self.event {
            self.actionButtonEvent?(event)
        }
    }
    
    fileprivate func setChatRoomValues() {
        if chatRoom.isMember {
            bindViewChat()
        } else {
            bindJoinChat()
        }
    }
    
    fileprivate func setEventValue() {
        if event.isMember {
            bindViewEvent()
        } else {
            bindJoinEvent()
        }
    }
    
    func bindViewChat() {
        delay(delay: 0) {
//            self.sectionButton.setTitle("View", for: .normal)
//            self.sectionView.backgroundColor = Constants.chatRoomColor
//            self.sectionLabel.text = "Chat Room"
            
            self.imgCellType.image = UIImage.init(named: "E list group join")
            self.lblCellType.text = self.strJoined
            self.lblCellType.textColor = UIColor.HexToColor("#47678D")
        }
        
        self.nameLabel.text = chatRoom.name
        self.addressLabel.text = chatRoom.address
        self.distanceLabel.text = chatRoom.getDistance()
        self.imageView.kf.setImage(with: chatRoom.getImageUrl(), placeholder: Constants.defaultChatRoomImage)
    }
    
    func bindJoinChat() {
        delay(delay: 0) {
//            self.sectionButton.setTitle("Join", for: .normal)
//            self.sectionView.backgroundColor = Constants.chatRoomColor
//            self.sectionLabel.text = "Chat Room"
            self.imgCellType.image = UIImage.init(named: "E list group not join")
            self.lblCellType.text = self.strJoin
        }
        
        self.nameLabel.text = chatRoom.name
        self.addressLabel.text = chatRoom.address
        self.distanceLabel.text = chatRoom.getDistance()
        self.imageView.kf.setImage(with: chatRoom.getImageUrl(), placeholder: Constants.defaultChatRoomImage)
    }
    
    func bindViewEvent() {
        delay(delay: 0) {
//            self.sectionButton.setTitle("View", for: .normal)
//            self.sectionView.backgroundColor = Constants.eventColor
//            self.sectionLabel.text = "Event"
            self.imgCellType.image = UIImage.init(named: "E list group join")
            self.lblCellType.text = self.strJoined
            self.lblCellType.textColor = UIColor.HexToColor("#47678D")
        }
        
        self.nameLabel.text = event.name
        self.addressLabel.text = event.address
        self.distanceLabel.text = event.getDistance()
        self.imageView.kf.setImage(with: event.getImageUrl(), placeholder: Constants.defaultEventGroupImage)
    }
    
    func bindJoinEvent() {
        delay(delay: 0) {
//            self.sectionButton.setTitle("Join", for: .normal)
//            self.sectionView.backgroundColor = Constants.eventColor
//            self.sectionLabel.text = "Event"
            self.imgCellType.image = UIImage.init(named: "E list group not join")
            self.lblCellType.text = self.strJoin
        }
        
        self.nameLabel.text = event.name
        self.addressLabel.text = event.address
        self.distanceLabel.text = event.getDistance()
        self.imageView.kf.setImage(with: event.getImageUrl(), placeholder: Constants.defaultEventGroupImage)
        
    }
}
