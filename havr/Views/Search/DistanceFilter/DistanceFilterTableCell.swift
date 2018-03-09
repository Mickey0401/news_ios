//
//  DistanceFilterTableCell.swift
//  havr
//
//  Created by Ismajl Marevci on 4/20/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

class DistanceFilterTableCell: UITableViewCell {

    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var distanceImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
extension UITableView {
    func registerDistanceFilterTableCell(){
        let nib = UINib(nibName: "DistanceFilterTableCell", bundle: nil)
        self.register(nib, forCellReuseIdentifier: "DistanceFilterTableCell")
    }
    
    func dequeueDistanceFilterTableCell(indexpath: IndexPath) -> DistanceFilterTableCell{
        return self.dequeueReusableCell(withIdentifier: "DistanceFilterTableCell", for: indexpath) as! DistanceFilterTableCell
    }
}
