//
//  ContactUsView.swift
//  havr
//
//  Created by Ismajl Marevci on 4/22/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit


class ContactUsView: UIView {

    //Mark: - OUTLETS
    @IBOutlet weak var screenshotImageView: UIImageView!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var descriptionView: GrowingTextView!
    @IBOutlet weak var addScreenshotButton: UIButton!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var fullNameText: UITextField!
    
    //MARK: - VARIALBES
    var view: UIView!
    var addScreenshotButtonPressed : ((_ sender: UIButton) -> Void)? = nil
    
    //MARK: - LIFE CYCLE
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup(){
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        return UINib(nibName: "ContactUsView", bundle: bundle).instantiate(withOwner: self, options: nil)[0] as! UIView
    }

    //MARK: - ACTIONS
    @IBAction func addScreenshotButtonPressed(_ sender: UIButton) {
        self.addScreenshotButtonPressed?(sender)
    }
}
