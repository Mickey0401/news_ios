//
//  EventWelcomeController.swift
//  havr
//
//  Created by Agon Miftari on 5/8/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

class EventWelcomeController: UIViewController, UIGestureRecognizerDelegate {
    
    //MARK: - OUTLETS
    @IBOutlet weak var liveView: UIView!
    @IBOutlet weak var leaveButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    
    //MARK: - VARIABLES
    var event: Event!

    //MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        continueButtonTitle()
    }
    
    func continueButtonTitle() {
        liveView.isHidden = true

        let time: String = event.getTime()
        switch event.status {
        case .ended:
            liveView.isHidden = true
            continueButton.setTitle("Event Ended", for: UIControlState())
            break
        case .live:
            liveView.isHidden = false
            continueButton.setTitle("Continue", for: UIControlState())
            break
        case .soon:
            liveView.isHidden = true
            continueButton.setTitle("Time left: \(time)", for: UIControlState())
            break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        UIApplication.shared.isStatusBarHidden = true
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        UIApplication.shared.isStatusBarHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.tabBarController?.tabBar.isHidden = false
    }
    
    //MARK: - ACTIONS
    @IBAction func leaveButtonPressed(_ sender: UIButton) {
        self.pop()
        
    }
    
    @IBAction func continueButtonPressed(_ sender: UIButton) {
        switch event.status {
        case .ended:
            break
        case .live:
            let eventVC = EventController.create(for: event)
            self.push(eventVC)
            break
        case .soon:
            break
        }
    }
}

extension EventWelcomeController {
   static func create() -> EventWelcomeController {
        return UIStoryboard.explore.instantiateViewController(withIdentifier: "EventWelcomeController") as! EventWelcomeController
    }
}
