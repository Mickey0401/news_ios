//
//  ConversationFooterView.swift
//  havr
//
//  Created by Ismajl Marevci on 8/4/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

class ConversationFooterView: UITableViewHeaderFooterView {

    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
extension UITableView {
    func registerConversationFooterView() {
        let nib = UINib(nibName: "ConversationFooterView", bundle: nil)
        self.register(nib, forHeaderFooterViewReuseIdentifier: "ConversationFooterView")
    }
    func dequeueConversationFooterView() -> ConversationFooterView {
        return self.dequeueReusableHeaderFooterView(withIdentifier: "ConversationFooterView") as! ConversationFooterView
    }
}
