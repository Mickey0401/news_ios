//
//  YoutubeSearchTableCell.swift
//  havr
//
//  Created by Agon Miftari on 4/25/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

class YoutubeSearchTableCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}

extension UITableView {
    
    func registerYoutubeSearchTableCell() {
        let nib = UINib(nibName: "YoutubeSearchTableCell", bundle: nil)
        self.register(nib, forCellReuseIdentifier: "YoutubeSearchTableCell")
    }
    
    func dequeueYoutubeSearchTableCell(indexpath: IndexPath) -> YoutubeSearchTableCell {
        return self.dequeueReusableCell(withIdentifier: "YoutubeSearchTableCell", for: indexpath) as! YoutubeSearchTableCell
    }
    
}
