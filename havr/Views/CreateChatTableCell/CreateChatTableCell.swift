//
//  CreateChatTableCell.swift
//  havr
//
//  Created by Agon Miftari on 6/27/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

class CreateChatTableCell: UITableViewCell {
    
    
    @IBOutlet weak var firstDistanceLabel: UILabel!
    @IBOutlet weak var secondDistanceLabel: UILabel!
    @IBOutlet weak var thirdDistanceLabel: UILabel!
    
    @IBOutlet weak var firstDistanceView: UIView!
    @IBOutlet weak var secondDistanceView: UIView!
    @IBOutlet weak var thirdDistanceView: UIView!
    
    
    @IBOutlet weak var firstDistanceButton: UIButton!
    @IBOutlet weak var secondDistanceButton: UIButton!
    @IBOutlet weak var thirdDistanceButton: UIButton!
    
    var proximityChanged: ((Double) -> Void)? = nil
    
    var proximity: Double? {
        didSet {
            proximityChanged?(proximity ?? 0)
        }
    }


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func firstDistanceButtonPressed(_ sender: UIButton) {
        
        //Appearance Layer
        CreateChatTableCell.selectedDistanceAppearance(title: firstDistanceLabel, distanceView: firstDistanceView)
        CreateChatTableCell.defaultDistanceAppearance(title: secondDistanceLabel, distanceView: secondDistanceView)
        CreateChatTableCell.defaultDistanceAppearance(title: thirdDistanceLabel, distanceView: thirdDistanceView)
        
        if let firstDistance = firstDistanceLabel.text {
            proximity = Double(firstDistance.trim)
        }
       
    }
    
    @IBAction func secondDistanceButtonPressed(_ sender: UIButton) {
        
        //Appearance Layer
        CreateChatTableCell.selectedDistanceAppearance(title: secondDistanceLabel, distanceView: secondDistanceView)
        CreateChatTableCell.defaultDistanceAppearance(title: firstDistanceLabel, distanceView: firstDistanceView)
        CreateChatTableCell.defaultDistanceAppearance(title: thirdDistanceLabel, distanceView: thirdDistanceView)
        
        if let secondDistance = secondDistanceLabel.text {
            proximity = Double(secondDistance.trim)
        }
    }
    @IBAction func thirdDistanceButtonPressed(_ sender: UIButton) {
        
        //Appearance Layer
        CreateChatTableCell.selectedDistanceAppearance(title: thirdDistanceLabel, distanceView: thirdDistanceView)
        CreateChatTableCell.defaultDistanceAppearance(title: secondDistanceLabel, distanceView: secondDistanceView)
        CreateChatTableCell.defaultDistanceAppearance(title: firstDistanceLabel, distanceView: firstDistanceView)
        
        if let thirdDistance = thirdDistanceLabel.text {
            proximity = Double(thirdDistance.trim)
        }
    }
    
    
    static func selectedDistanceAppearance(title: UILabel, distanceView: UIView) {
        
        title.textColor = Apperance.appBlueColor
        distanceView.layer.borderColor = Apperance.appBlueColor.cgColor
        distanceView.backgroundColor = Apperance.appBlueColor
        
    }
    
    static func defaultDistanceAppearance(title: UILabel, distanceView: UIView) {
        
        title.textColor = UIColor(red255: 92, green255: 89, blue255: 92)
        distanceView.layer.borderColor = UIColor(red255: 198, green255: 195, blue255: 198).cgColor
        distanceView.backgroundColor = UIColor.white
        
    }

}


extension UITableView {
    func dequeueCreateChatTableCell(index: IndexPath) -> CreateChatTableCell {
        return self.dequeueReusableCell(withIdentifier: "CreateChatTableCell", for: index) as! CreateChatTableCell
    }
    
    func registerCreateChatTableCell() {
        let nib = UINib(nibName: "CreateChatTableCell", bundle: nil)
        self.register(nib, forCellReuseIdentifier: "CreateChatTableCell")
    }
}
