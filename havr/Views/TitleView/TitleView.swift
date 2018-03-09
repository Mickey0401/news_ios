//
//  TitleView.swift
//  havr
//
//  Created by Ismajl Marevci on 8/22/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

enum MessageType {
    case typing
    case recording
    case neutral
}

class TitleView: UIView {
    
    //MARK: - OUTLETS
    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    var view: UIView!
    fileprivate var title: String = ""
    fileprivate var subtitle: String = ""

    var type: MessageType = .neutral{
        didSet{
            onTypeChanged()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func titleForType(title: String, subtitle: String?) {
        self.title = title
        self.subtitle = subtitle ?? ""
        titleLabel.text = title
        titleLabel.textColor = UIColor.darkGray

        onTypeChanged()
    }
    func onTypeChanged() {
        switch type {
        case .neutral:
            subTitleLabel.text = subtitle
            subTitleLabel.textColor = UIColor.init(red: 179/255, green: 178/255, blue: 179/255, alpha: 1.0)
            imageWidthConstraint.constant = 0
            imageView.image = nil
            break
        case .recording:
            subTitleLabel.text = "recording"
            subTitleLabel.textColor = Apperance.appBlueColor
            imageWidthConstraint.constant = 20
            delay(delay: 0.0, closure: { 
                self.imageView.loadGif(name: "Recording")
            })
            
            break
        case .typing:
            subTitleLabel.text = "typing"
            subTitleLabel.textColor = Apperance.appBlueColor
            imageWidthConstraint.constant = 20
            delay(delay: 0.0, closure: { 
                self.imageView.loadGif(name: "Typing")
            })
            
            break
        }
    }
    
    static func loadViewFromNib() -> TitleView {
        let view = UIView.load(fromNib: "TitleView") as! TitleView
        return view
    }
}
