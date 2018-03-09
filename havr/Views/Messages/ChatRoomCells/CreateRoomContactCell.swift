//
//  CreateRoomContactCell.swift
//  havr
//
//  Created by CloudStream on 2/19/18.
//  Copyright © 2018 Tenton LLC. All rights reserved.
//

import Foundation
import UIKit

class CreateRoomContactCell: UITableViewCell {

    @IBOutlet weak var ivUser: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblState: UILabel!
    @IBOutlet weak var lblMemLvl: UILabel!
    
    var user: User! {
        didSet {
            setValues()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.lblName.text = ""
        self.lblState.text = ""
        self.lblMemLvl.text = ""
        self.ivUser.image = #imageLiteral(resourceName: "defaultImageUser")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)        
    }
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
    }
    
    fileprivate func setValues() {
        self.lblName.text = user.fullName
        self.lblState.text = user.status.rawValue
        
        self.ivUser.layer.cornerRadius = 20.0
        self.ivUser.layer.masksToBounds = true
        
        if let image = user.getUrl() {
            ivUser.kf.setImage(with: image, placeholder: user.getPlaceholder())
        }else {
            ivUser.image = #imageLiteral(resourceName: "defaultImageUser")
        }
    }
    
}

extension UITableView {
    func dequeueCreateRoomContactCell(index: IndexPath) -> CreateRoomContactCell {
        return self.dequeueReusableCell(withIdentifier: "ChatRoomContactCell", for: index) as! CreateRoomContactCell
    }
}
