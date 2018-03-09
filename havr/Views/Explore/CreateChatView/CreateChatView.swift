//
//  CreateChatView.swift
//  havr
//
//  Created by Agon Miftari on 5/2/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit


class CreateChatView: UIView, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var view : UIView!
    
    @IBOutlet weak var firstDistanceLabel: UILabel!
    @IBOutlet weak var secondDistanceLabel: UILabel!
    @IBOutlet weak var thirdDistanceLabel: UILabel!
    
    @IBOutlet weak var firstDistanceView: UIView!
    @IBOutlet weak var secondDistanceView: UIView!
    @IBOutlet weak var thirdDistanceView: UIView!
    
    
    @IBOutlet weak var firstDistanceButton: UIButton!
    @IBOutlet weak var secondDistanceButton: UIButton!
    @IBOutlet weak var thirdDistanceButton: UIButton!
    
    @IBOutlet weak var chatRoomImageView: UIImageView!
    @IBOutlet weak var chatRoomButton: UIButton!
    @IBOutlet weak var eventButton: UIButton!
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var addressField: UITextField!

    
    var shouldLayoutSubviews: (() -> Void)? = nil
    var cameraButtonPressed: ((_ sender: UIButton) -> Void)? = nil
    var cancelButtonPressed: (() -> Void)? = nil
    var createButtonPressed: (() -> Void)? = nil
    var addressButtonPressed : (() -> Void)? = nil
    
    var isChatHidden : Bool = false
    
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
        return UINib(nibName: "CreateChatView", bundle: bundle).instantiate(withOwner: self, options: nil)[0] as! UIView
    }
    
    
    //MARK : - IBActions
    
    @IBAction func firstDistanceButtonPressed(_ sender: UIButton) {
        
        //Appearance Layer
        CreateChatView.selectedDistanceAppearance(title: firstDistanceLabel, distanceView: firstDistanceView)
        CreateChatView.defaultDistanceAppearance(title: secondDistanceLabel, distanceView: secondDistanceView)
        CreateChatView.defaultDistanceAppearance(title: thirdDistanceLabel, distanceView: thirdDistanceView)
    }
    
    @IBAction func secondDistanceButtonPressed(_ sender: UIButton) {
        
        //Appearance Layer
        CreateChatView.selectedDistanceAppearance(title: secondDistanceLabel, distanceView: secondDistanceView)
        CreateChatView.defaultDistanceAppearance(title: firstDistanceLabel, distanceView: firstDistanceView)
        CreateChatView.defaultDistanceAppearance(title: thirdDistanceLabel, distanceView: thirdDistanceView)
    }
    @IBAction func thirdDistanceButtonPressed(_ sender: UIButton) {
        
        //Appearance Layer
        CreateChatView.selectedDistanceAppearance(title: thirdDistanceLabel, distanceView: thirdDistanceView)
        CreateChatView.defaultDistanceAppearance(title: secondDistanceLabel, distanceView: secondDistanceView)
        CreateChatView.defaultDistanceAppearance(title: firstDistanceLabel, distanceView: firstDistanceView)
    }
    
    @IBAction func chatRoomButtonPressed(_ sender: UIButton) {
        isChatHidden = false
        self.shouldLayoutSubviews?()
    }
    
    @IBAction func eventButtonPressed(_ sender: UIButton) {
        isChatHidden = true
        self.shouldLayoutSubviews?()
    }
    
    
    @IBAction func cameraButtonPressed(_ sender: UIButton) {
        
        self.cameraButtonPressed?(sender)
    }
    
    @IBAction func createButtonPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        
        self.cancelButtonPressed?()
    }

    @IBAction func addressButtonPressed(_ sender: UIButton) {
        
        self.addressButtonPressed?()
    }
    
}


