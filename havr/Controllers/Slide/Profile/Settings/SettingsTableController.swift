//
//  SettingsTableController.swift
//  havr
//
//  Created by Alexandr Lobanov on 12/3/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

class SettingsTableController: UITableViewController {
    
    @IBOutlet weak var receiptSwitch: UISwitch!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var privateModeSwitch: UISwitch!
    @IBOutlet weak var cancelBarBatton: UIBarButtonItem!
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        receiptSwitch.isOn = AccountManager.currentUser!.isPublic
        notificationSwitch.isOn = PushNotificationManager.didRegisterForRemoteNotification()
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        self.view.backgroundColor = .white
        
        Helper.setupTransparentNavigationBar(nav: navigationController!)
    }
    
    @IBAction func changeSwitchState(_ sender: UISwitch) {
        switch sender {
        case privateModeSwitch:
            updatePricacyState(sender)
        case receiptSwitch:
            applyReadReceipts(sender)
        case notificationSwitch:
            updateRemoteNotificationStatus(sender)
        default: break
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension SettingsTableController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = SettingSections(rawValue: indexPath.section), let row = SettingRows(rawValue: section, row: indexPath.row) else { return }
        switch section {
        case .profile:
            print("Profile section")
            switch row {
            case .profile:
                print("profile")
            case .receipt:
                print(" read receipt")
            default: break
            }
        case .controll:
            print("Controll section")
            switch row {
            case .notification:
                print("notification")
            case .blockedUsers:
                openBlockedList()
            case .phoneNumber:
                openPhoneNumberController()
            default: break
            }
        case .logOut:
            logOut()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SettingsTableController {
    static func create() -> UIViewController {
        return UIStoryboard.settings.instantiateViewController(withIdentifier: "settings_navigation")
    }
    
    func openPhoneNumberController() {
        let controller = PhoneViewController.create()
        self.push(controller)
    }
    
    func openBlockedList() {
        let blockedList = BlockedListController.create()
        self.push(blockedList)
    }
    
    func updatePricacyState(_ sender: UISwitch) {
        let current = sender.isOn
        self.showHud()
        UsersAPI.updatePrivacy(isPublic: current) { (newStatus, error) in
            self.hideHud()
            if let status = newStatus {
                sender.isOn = status
                AccountManager.updateProfile()
            }
            
            if let error = error {
                sender.isOn = false
                Helper.show(alert: error.message)
            }
        }
    }
    
    func applyReadReceipts(_ sender: UISwitch) {
        
    }
    
    func updateRemoteNotificationStatus(_ sender: UISwitch) {
        Preferences.isEnabledRemoteNotification = sender.isOn
        if sender.isOn {
            PushNotificationManager.register(application: UIApplication.shared)
        } else {
            PushNotificationManager.unregisterFromNotifications()
        }
    }
    
    func logOut() {
        let alert = UIAlertController(title: "Log out", message: "Are you sure you want to \n log out?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (handler) in
            //Log Out function here ...
            self.showHud()
            AccountManager.delete()
            self.switchWindowRoot(to: .login)
            UsersAPI.logout(completion: { (success, error) in
                self.hideHud()
                if success {
                    print("Token removed.")
                }
            })
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (handler) in}))
        alert.view.tintColor = Apperance.appBlueColor
        self.present(alert, animated: true, completion: nil)
        alert.view.tintColor = Apperance.appBlueColor
    }
}

enum SettingSections: Int {
    case profile = 0
    case controll = 2
    case logOut = 5
}

enum SettingRows {
    case profile
    case receipt
    case notification
    case blockedUsers
    case phoneNumber
    case logOut
    case undefined
    
    init?(rawValue: SettingSections, row: Int) {
        switch rawValue {
        case .profile:
            switch row {
            case 0:
                self = .profile
            case 1:
                self = .receipt
            default:
                self = .undefined
            }
        case .controll:
            switch row {
            case 0:
                self = .notification
            case 1:
                self = .blockedUsers
            case 2:
                self = .phoneNumber
            default:
                self = .undefined
            }
        case .logOut:
            self = .logOut
        }
    }
}
