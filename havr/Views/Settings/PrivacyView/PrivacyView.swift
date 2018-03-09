//
//  PrivacyView.swift
//  havr
//
//  Created by Ismajl Marevci on 4/22/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import MBProgressHUD

class PrivacyView: UIView {

    //MARK: - OUTLETS
    @IBOutlet weak var applyReadSwitch: UISwitch!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var blockedListButton: UIButton!
    @IBOutlet weak var emailSwitch: UISwitch!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var changePasswordButton: UIButton!
    
    @IBOutlet weak var changePasswordView: UIView!
    //MARK: - VARIABLES
    var view: UIView!    
    
    var blockedListButtonPressed: (() -> Void)? = nil
    var changePasswordButtonPressed: (() -> Void)? = nil
    var logOutButtonPressed: (() -> Void)? = nil
    var emailSwitchChanged: ((UISwitch) -> Void)? = nil
    
    //MARK: - LIFE CYCLE
    override func awakeFromNib() {
        super.awakeFromNib()
        
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
        return UINib(nibName: "PrivacyView", bundle: bundle).instantiate(withOwner: self, options: nil)[0] as! UIView
    }
    
    //MARK: - ACTIONS


    @IBAction func notificationSwitchChanged(_ sender: UISwitch) {
    }
    @IBAction func emailSwitchChanged(_ sender: UISwitch) {
        self.emailSwitchChanged?(sender)
    }
    @IBAction func applyReadSwitchChanged(_ sender: UISwitch) {
    }
    
    @IBAction func blockedListButtonPressed(_ sender: UIButton) {

        self.blockedListButtonPressed?()
    }
    
    @IBAction func changePasswordButtonPressed(_ sender: UIButton) {
        
        self.changePasswordButtonPressed?()
    }
    
    
    @IBAction func logOutButtonPressed(_ sender: UIButton) {
        
        self.logOutButtonPressed?()
        
    }
}
