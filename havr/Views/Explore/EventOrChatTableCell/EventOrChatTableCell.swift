//
//  EventOrChatTableCell.swift
//  havr
//
//  Created by Agon Miftari on 5/3/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

protocol EventOrChatTableCellDelegate: class {
    func eventOrChatTableCell(sender: EventOrChatTableCell, didPressButton button: UIButton)
    func eventOrChatTableCell(sender: EventOrChatTableCell, didPressAddressWithLocation location: CLLocationCoordinate2D, placeName: String)
}


class EventOrChatTableCell: UITableViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var imgCellType: UIImageView!
    @IBOutlet weak var lblCellType: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var bigDivider: UIView!
    @IBOutlet weak var smallDivider: UIView!
    
    var event: Event! {
        didSet {
            setEventValues()
            setupTap()
        }
    }
    var chatRoom: ChatRoom! {
        didSet {
            setChatRoomValues()
            setupTap()
        }
    }
    
    var darkBlueHavr = UIColor(red255: 71, green255: 103, blue255: 141)
    
    var isView : Bool = false
    var isEvent : Bool = false
    var isChat : Bool = false
    var isEdit : Bool = false
    var isJoin : Bool = false
    
    let strMessage = "Message"
    let strJoined = "Joined"
    let strJoin = "Join"
    
    weak var delegate: EventOrChatTableCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imgView.borderWidth = 1.0
        imgView.borderColor = UIColor.HexToColor("#EFEFEF")
        imgView.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        lblCellType.textColor = UIColor.HexToColor("#9799A6")
        bigDivider.backgroundColor = UIColor.clear
        smallDivider.backgroundColor = UIColor.clear
        
        if isView && isEvent {

//            sectionButton.setTitle("View", for: .normal)
//            sectionView.backgroundColor = Constants.eventColor
//            sectionLabel.text = eventString
//            sectionButton.backgroundColor = darkBlueHavr
            
            self.imgCellType.image = UIImage.init(named: "E list group not join")
            lblCellType.text = strJoin
            bigDivider.backgroundColor = Constants.eventColor
            smallDivider.backgroundColor = Constants.eventColor
        }else if isView && isChat {
//            sectionButton.setTitle("View", for: .normal)
//            sectionView.backgroundColor = Constants.chatRoomColor
//            sectionLabel.text = chatString
//            sectionButton.backgroundColor = darkBlueHavr
            self.imgCellType.image = UIImage.init(named: "E list group join")
            lblCellType.text = strJoined
            lblCellType.textColor = UIColor.HexToColor("#47678D")
            bigDivider.backgroundColor = Constants.chatRoomColor
            smallDivider.backgroundColor = Constants.chatRoomColor
        }
        else if isEvent && isJoin{

//            sectionButton.setTitle("Join", for: .normal)
//            sectionView.backgroundColor = Constants.eventColor
//            sectionLabel.text = eventString
//            sectionButton.backgroundColor = darkBlueHavr
            
            self.imgCellType.image = UIImage.init(named: "E list group not join")
            lblCellType.text = strJoin
            bigDivider.backgroundColor = Constants.eventColor
            smallDivider.backgroundColor = Constants.eventColor
        }else if isChat && isJoin{

//            sectionButton.setTitle("Join", for: .normal)
//            sectionView.backgroundColor = Constants.chatRoomColor
//            sectionLabel.text = chatString
//            sectionButton.backgroundColor = darkBlueHavr
            self.imgCellType.image = UIImage.init(named: "E list group not join")
            lblCellType.text = strJoin
            bigDivider.backgroundColor = Constants.chatRoomColor
            smallDivider.backgroundColor = Constants.chatRoomColor

        }
        else if isEvent && isEdit {
//            sectionButton.setTitle("Edit", for: .normal)
//            sectionView.backgroundColor = Constants.eventColor
//            sectionLabel.text = eventString
//            sectionButton.backgroundColor = darkBlueHavr
            
        }
        else if isChat && isEdit {
//            sectionButton.setTitle("Edit", for: .normal)
//            sectionView.backgroundColor = Constants.chatRoomColor
//            sectionLabel.text = chatString
//            sectionButton.backgroundColor = darkBlueHavr

        }
        else {
            //Don't change
        }
    
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: true)
        
        if isView && isEvent {
//
//            sectionButton.setTitle("View", for: .normal)
//            sectionView.backgroundColor = Constants.eventColor
//            sectionLabel.text = eventString
//            sectionButton.backgroundColor = darkBlueHavr
            
            self.imgCellType.image = UIImage.init(named: "E list group join")
            lblCellType.text = strJoined
            self.lblCellType.textColor = UIColor.HexToColor("#47678D")
            bigDivider.backgroundColor = Constants.eventColor
            smallDivider.backgroundColor = Constants.eventColor
        }else if isView && isChat {
//            sectionButton.setTitle("View", for: .normal)
//            sectionView.backgroundColor = Constants.chatRoomColor
//            sectionLabel.text = chatString
//            sectionButton.backgroundColor = darkBlueHavr
            
            self.imgCellType.image = UIImage.init(named: "E list group join")
            lblCellType.text = strJoined
            self.lblCellType.textColor = UIColor.HexToColor("#47678D")
            bigDivider.backgroundColor = Constants.chatRoomColor
            smallDivider.backgroundColor = Constants.chatRoomColor
        }
        else if isEvent && isJoin{
//
//            sectionButton.setTitle("Join", for: .normal)
//            sectionView.backgroundColor = Constants.eventColor
//            sectionLabel.text = eventString
//            sectionButton.backgroundColor = darkBlueHavr
            
            self.imgCellType.image = UIImage.init(named: "E list group not join")
            lblCellType.text = strJoin
            bigDivider.backgroundColor = Constants.eventColor
            smallDivider.backgroundColor = Constants.eventColor
        }else if isChat && isJoin{
//
//            sectionButton.setTitle("Join", for: .normal)
//            sectionView.backgroundColor = Constants.chatRoomColor
//            sectionLabel.text = chatString
//            sectionButton.backgroundColor = darkBlueHavr
            
            self.imgCellType.image = UIImage.init(named: "E list group not join")
            lblCellType.text = strJoin
            bigDivider.backgroundColor = Constants.chatRoomColor
            smallDivider.backgroundColor = Constants.chatRoomColor
        }
//        else if isEvent && isEdit {
//            sectionButton.setTitle("Edit", for: .normal)
//            sectionView.backgroundColor = Constants.eventColor
//            sectionLabel.text = eventString
//            sectionButton.backgroundColor = darkBlueHavr
//
//        }
//        else if isChat && isEdit {
//            sectionButton.setTitle("Edit", for: .normal)
//            sectionView.backgroundColor = Constants.chatRoomColor
//            sectionLabel.text = chatString
//            sectionButton.backgroundColor = darkBlueHavr
//
//        }
//        else {
//            //Don't change
//        }
        
    }
    @IBAction func sectionButtonPressed(_ sender: UIButton) {
        self.delegate?.eventOrChatTableCell(sender: self, didPressButton: sender)
    }
    
    func setupTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(addressLabelPressed))
        tap.numberOfTapsRequired = 1
        addressLabel?.isUserInteractionEnabled = true
        addressLabel?.addGestureRecognizer(tap)
    }
    
    func addressLabelPressed(){
        let location = isChat ? chatRoom.location : event.location
        let name = isChat ? chatRoom.address : event.address
        self.delegate?.eventOrChatTableCell(sender: self, didPressAddressWithLocation: location!.coordinate, placeName: name)
    }

    func bindJoinEventTableCell() {
        delay(delay: 0) { 
//            self.sectionButton.setTitle("Join", for: .normal)
//            self.sectionView.backgroundColor = Constants.eventColor
//            self.sectionLabel.text = self.eventString
            self.imgCellType.image = UIImage.init(named: "E list group not join")
            self.lblCellType.text = self.strJoin
        }
        isView = false
        isEvent = true
        isChat = false
        isEdit = false
        isJoin = true
    }
    
    func bindJoinChatTableCell() {
        delay(delay: 0) {
//            self.sectionButton.setTitle("Join", for: .normal)
//            self.sectionView.backgroundColor = Constants.chatRoomColor
//            self.sectionLabel.text = self.chatString
            self.imgCellType.image = UIImage.init(named: "E list group not join")
            self.lblCellType.text = self.strJoin
        }
        isView  = false
        isEvent = false
        isChat = true
        isJoin = true
        isEdit = false
    }
    
    func bindEditEventTableCell() {
        delay(delay: 0) { 
//            self.sectionButton.setTitle("Edit", for: .normal)
//            self.sectionView.backgroundColor = Constants.eventColor
//            self.sectionLabel.text = self.eventString
        }
        
        isView = false
        isEvent = true
        isEdit = true
        isChat = false
        isJoin = false
    }
    
    
    func bindEditChatTableCell() {
        delay(delay: 0) { 
//            self.sectionButton.setTitle("Edit", for: .normal)
//            self.sectionView.backgroundColor = Constants.chatRoomColor
//            self.sectionLabel.text = self.chatString
        }
        isView  = false
        isEvent = false
        isChat = true
        isEdit = true
        isJoin = false
        
    }
    
    func bindViewChatTableCell() {
        delay(delay: 0) { 
//            self.sectionButton.setTitle("View", for: .normal)
//            self.sectionView.backgroundColor = Constants.chatRoomColor
//            self.sectionLabel.text = self.chatString
            
            self.imgCellType.image = UIImage.init(named: "E list group join")
            self.lblCellType.text = self.strJoined
            self.lblCellType.textColor = UIColor.HexToColor("#47678D")
        }
        
        isView = true
        isEvent = false
        isChat = true
        isEdit = false
        isJoin = false
        
    }
    
    func bindViewEventTableCell() {
        delay(delay: 0) {
//            self.sectionButton.setTitle("View", for: .normal)
//            self.sectionView.backgroundColor = Constants.eventColor
//            self.sectionLabel.text = self.eventString
            self.imgCellType.image = UIImage.init(named: "E list group join")
            self.lblCellType.text = self.strJoined
            self.lblCellType.textColor = UIColor.HexToColor("#47678D")
        }
        
        isView = true
        isEvent = true
        isChat = false
        isEdit = false
        isJoin = false
    }
    
    func setChatRoomValues() {
        if (chatRoom == nil) {
            return
        }
        
        imgView.kf.setImage(with: chatRoom.getImageUrl())
        nameLabel.text = chatRoom.name
        
        if chatRoom.address == "" {
            addressLabel.text = "location is unavailable"
        }
        else {
            addressLabel.text = chatRoom.address
        }
        
        addressLabel.text = chatRoom.address
        distanceLabel.text = chatRoom.getDistance()
    }
    
    func setEventValues() {
        if (event == nil) {
            return
        }
        
        if let imgUrl = event.getImageUrl() {
            print("imageUrl = \(imgUrl)")
            imgView.kf.setImage(with: event.getImageUrl())
        }
        nameLabel.text = event.name
        
        if event.address == "" {
            addressLabel.text = "location is unavailable"
        }
        else {
            addressLabel.text = event.address
        }
        
        distanceLabel.text = event.getDistance()
    }
}

extension UITableView {
    func dequeueEventOrChatTableCell(index: IndexPath) -> EventOrChatTableCell {
        return self.dequeueReusableCell(withIdentifier: "EventOrChatTableCell", for: index) as! EventOrChatTableCell
    }
    
    func registerEventOrChatTableCell() {
        let nib = UINib(nibName: "EventOrChatTableCell", bundle: nil)
        self.register(nib, forCellReuseIdentifier: "EventOrChatTableCell")
    }
}
