//
//  LoginPhoneNumberViewController.swift
//  havr
//
//  Created by Alexandr Lobanov on 1/10/18.
//  Copyright © 2018 Tenton LLC. All rights reserved.
//

import UIKit
import PhoneNumberKit
import Whisper

class LoginPhoneNumberViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var selectCountryTapView: UIView!
    @IBOutlet weak var termConstarint: NSLayoutConstraint!
    @IBOutlet weak var selectedCountryLabel: UILabel!
    @IBOutlet weak var termsLabel: UILabel!
    @IBOutlet weak var phoneTextField: PhoneNumberTextField!
    @IBOutlet weak var countryCodeLabel: UILabel!
    @IBOutlet weak var pointerSeparator: ELPointerSeparatorView!
    @IBOutlet weak var separatorView: UIView!
    
    fileprivate let locale = NSLocale.current
    fileprivate var countryPhone = Country().curentCountry
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
        if let model = countryPhone {
            selectedCountryLabel.text = "\(model.flag) \(model.name)"
            countryCodeLabel.text = model.dialCode
        }
        phoneTextField.withPrefix = false
        termsLabel.addTapGestureFor(self, #selector(showTermCondotion))
        selectCountryTapView.addTapGestureFor(self, #selector(showCountryCodesAction))
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        pointerSeparator.pointerTargetX = countryCodeLabel.frame.width / 2.0
        pointerSeparator.lineColor = separatorView.backgroundColor!
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            termConstarint.constant = keyboardSize.height + 8
            UIView.animate(withDuration: 0.2, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            termConstarint.constant = 8
            UIView.animate(withDuration: 0.2, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
}

//MARK: Create controller from storyboard id
extension LoginPhoneNumberViewController {
    static func create() -> LoginPhoneNumberViewController{
        return UIStoryboard.introduction.instantiateViewController(withIdentifier: String(describing: self)) as! LoginPhoneNumberViewController
    }
}
//MARK: CountryPhoneDelegate
extension LoginPhoneNumberViewController: CountryPhoneDelegate {
    func country(_ tableView: UITableView, didSelectCountry model: CountryPhone?) {
        countryCodeLabel.text = model?.dialCode
        selectedCountryLabel.text = model?.nameWithFlag
        countryPhone = model
    }
}
//MARK: Actions
extension LoginPhoneNumberViewController {
    func showTermCondotion() {
        let terms = TermsAndPrivacyController.create()
        terms.navTitle = "Terms of use"
        terms.termsOrPPText = Terms.termsText
        self.push(terms)
    }
    
    func showCountryCodesAction() {
        let controller = CountryCodesViewController.create()
        controller.delegate = self
        self.push(controller)
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func showConfirmationCodeViewController(_ sender: UIBarButtonItem) {
        let phoneKit = PhoneNumberKit()
        guard let userNumber = phoneTextField.text else { return }
        var phoneNumber: PhoneNumber? = nil

        let phone = userNumber.clearPhoneNumber()
        do {
            phoneNumber = try phoneKit.parse(phone, withRegion: (countryPhone?.code)!, ignoreType: true)
        } catch let error {
            print(error.localizedDescription)
        }
        if let phoneNumber = phoneNumber {
            let formated = phoneKit.format(phoneNumber, toType: PhoneNumberFormat.national)
            print(formated)
        }

        guard let isEmpty = phoneTextField.text?.isEmpty, !isEmpty else {
                phoneTextField.shake()
                return
        }
        guard let controller = ConfirmCodeViewController.create(from: UIStoryboard.introduction) as? ConfirmCodeViewController,
            let code = countryCodeLabel.text, let number = phoneTextField.text else { return }
        controller.contryPhoneModel = countryPhone
        controller.userNumber = code + number
        push(controller)
    }
}


extension String {
    func clearPhoneNumber() -> String {
       return  self.replacingOccurrences(of: ")", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: "+", with: "").replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "")
    }
}
