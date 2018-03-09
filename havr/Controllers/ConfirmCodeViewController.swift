//
//  ConfirmCodeViewController.swift
//  havr
//
//  Created by Alexandr Lobanov on 1/10/18.
//  Copyright © 2018 Tenton LLC. All rights reserved.
//

import UIKit
import Whisper
import PhoneNumberKit

class ConfirmCodeViewController: UIViewController {
    //MARK: Outlets
    @IBOutlet weak var sendAgainLabel: UILabel!
    @IBOutlet weak var userPhoneNumberLabel: UILabel!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    fileprivate let userStore = UserStore.shared
    
    var contryPhoneModel: CountryPhone?
    var userNumber: String?
    
    fileprivate var code: String? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
//        let phoneKit = PhoneNumberKit()
        let phone = userNumber!.removeSpecialCharsFromString()
//        let phoneNumber = try! phoneKit.parse(phone, withRegion: (contryPhoneModel?.code)!, ignoreType: true)
//        let formated = phoneKit.format(phoneNumber, toType: PhoneNumberFormat.national)
//        print(formated)
        getCode(for: phone.clearPhoneNumber())
        sendAgainLabel.addTapGestureFor(self, #selector(requestCode))
        userPhoneNumberLabel.text = "+" + phone.parsePhoneWithSpaces()
        codeTextField.addTarget(self, action: #selector(didChangeCodeTextField(_:)), for: UIControlEvents.editingChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    func getCode(for phoneNumber: String) {
        UsersAPI.requestCode(with: phoneNumber) { (confirmation, error) in
            guard let error = error else {
                guard let confirm = confirmation else { return }
                print(confirm.phone)
                return
            }
            switch error.code {
            case 404:
                Helper.show(alert: error.message, title: "Error", doneButton: "Resend", completion: {
                    self.getCode(for: self.userNumber!)
                })
            default:
                Helper.show(alert: "Faild send sms code", title: "Error", doneButton: "Resend", completion: {
                    self.getCode(for: self.userNumber!)
                })
            }

        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            bottomConstraint.constant = keyboardSize.height + 8
            UIView.animate(withDuration: 0.2, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            bottomConstraint.constant = 8
            UIView.animate(withDuration: 0.2, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func didChangeCodeTextField(_ textField: UITextField) {
        guard var text = textField.text else { return }
        if text.count > 6 {
            text.removeLast(1)
            textField.text = text
        }
        guard text.count == 6  else {
            return
        }

        self.showHud()

        UsersAPI.confirmPhone(withCode: text) { (token, error) in
            DispatchQueue.main.async {
                self.hideHud()
            }
            guard let error = error else {
                guard let token = token else { return }
                if token.isRegistered {
                    DispatchQueue.main.async {
                        let controller =  EmailRegistrationController.create()
                        controller.token = token.token
                        self.push(controller)
                    }
                } else {
                    guard let user = token.profile else { return }
                    AccountManager.start(user: user, token: token.token)
                    self.switchWindowRoot(to: .slide)
//                    Helper.show(alert: "error.message")
                }
                return
            }
        }
    }
    
    func requestCode() {
        getCode(for: userNumber!.clearPhoneNumber())
        sendAgainLabel.text = " We have sent you the code via SMS"
        sendAgainLabel.textColor = UIColor.gray70
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension UIViewController {
    static func create(from storyBoard: UIStoryboard) -> UIViewController {
        return storyBoard.instantiateViewController(withIdentifier:  String(describing: self))
    }
}
