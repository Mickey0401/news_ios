//
//  NoCommentsBroadcastCell.swift
//  havr
//
//  Created by Arben Pnishi on 7/23/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

class NoCommentsBroadcastCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

//MARK: - EXTENSIONS
extension UITableView {
    func registerNoCommentsBroadcastCell(){
        let nib = UINib(nibName: "NoCommentsBroadcastCell", bundle: nil)
        self.register(nib, forCellReuseIdentifier: "NoCommentsBroadcastCell")
    }
    func dequeueNoCommentsBroadcastCell(indexpath: IndexPath) -> NoCommentsBroadcastCell{
        return self.dequeueReusableCell(withIdentifier: "NoCommentsBroadcastCell", for: indexpath) as! NoCommentsBroadcastCell
    }
}
