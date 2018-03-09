//
//  SearchTableCell.swift
//  havr
//
//  Created by Ismajl Marevci on 4/20/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

protocol SearchTableCellDelegate: class {
    func searchTable(sender: SearchTableCell, didPress actionButton: UIButton, at index: IndexPath)
}

class SearchTableCell: UITableViewCell {
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var bottomLine: UIView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var connectButton: UIButton!
    
    let darkBlueColor = UIColor(red255: 71, green255: 103, blue255: 141)
    let textConnectedColor = UIColor(red255: 70, green255: 70, blue255: 70)
    
    var indexPath: IndexPath!
    
    weak var delegate: SearchTableCellDelegate?
    
    var isConnected : Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    @IBAction func connectButtonPressed(_ sender: UIButton) {
        self.delegate?.searchTable(sender: self, didPress: sender, at: indexPath)
    }
    
}

extension UITableView {
    func registerSearchTableCell(){
        let nib = UINib(nibName: "SearchTableCell", bundle: nil)
        self.register(nib, forCellReuseIdentifier: "SearchTableCell")
    }
    
    func dequeueSearchTableCell(indexpath: IndexPath) -> SearchTableCell{
        return self.dequeueReusableCell(withIdentifier: "SearchTableCell", for: indexpath) as! SearchTableCell
    }
}
