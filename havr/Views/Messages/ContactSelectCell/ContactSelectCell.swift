//
//  CreateRoomContactCell.swift
//  havr
//
//  Created by CloudStream on 2/19/18.
//  Copyright © 2018 Tenton LLC. All rights reserved.
//

import Foundation
import UIKit

class ContactSelectCell: UITableViewCell {
    
    @IBOutlet weak var ivUser: UIImageView!
    @IBOutlet weak var ivType: UIImageView!
    @IBOutlet weak var ivSelection: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblState: UILabel!
    
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
        self.ivUser.image = #imageLiteral(resourceName: "defaultImageUser")
        self.ivSelection.image =  #imageLiteral(resourceName: "M contact unselect icon")
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
    }
    
    fileprivate func setValues() {
        self.lblName.text = user.fullName
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
    func dequeueContactSelectCell(index: IndexPath) -> ContactSelectCell {
        return self.dequeueReusableCell(withIdentifier: "ContactSelectCell", for: index) as! ContactSelectCell
    }
}

