//
//  PhoneViewController.swift
//  
//
//  Created by Alexandr Lobanov on 12/26/17.
//

import UIKit
import PhoneNumberKit

class PhoneViewController: UIViewController {
    
    @IBOutlet weak var curentNumberLabel: UILabel!
    @IBOutlet weak var selectCountryView: UIView!
    @IBOutlet weak var countryCodeLabel: UILabel!
    @IBOutlet weak var newPhoneNumberTextField: PhoneNumberTextField! { didSet {
        newPhoneNumberTextField.isPartialFormatterEnabled = true
        newPhoneNumberTextField.withPrefix = false
        newPhoneNumberTextField.delegate = self
        }
    }
    @IBOutlet weak var selectedCountryNamelabel: UILabel!
    @IBOutlet weak var countruCodeView: UIView!
    @IBOutlet weak var contentView: UIView!
    fileprivate let userStore = UserStore.shared
    fileprivate let phoneNumberKit = PhoneNumberKit()
    fileprivate var countryCode = Country().curentCountry
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Phone Number"
        newPhoneNumberTextField.maxDigits = 12
        if let country = countryCode {
            selectedCountryNamelabel.textColor = .black
            selectedCountryNamelabel.text = country.name
            countryCodeLabel.text = country.dialCode
        }
        self.showHud()
        UsersAPI.currentPhoneNumber { (phone, error) in
            DispatchQueue.main.async {
                self.hideHud()
                if !phone.isEmpty {
                    self.curentNumberLabel.text =  ("+" + phone).parsePhoneWithSpaces()
                } else {
                    self.curentNumberLabel.text = "Didn't set phone number yet"
                }
            }
        }
    
        Helper.setupTransparentNavigationBar(nav: navigationController!)
        selectCountryView.addTapGestureFor(self, #selector(showCountryCodes))
        countruCodeView.addTapGestureFor(self, #selector(showCountryCodes))
        contentView.addTapGestureFor(self, #selector(hideKeyboard))
        view.addTapGestureFor(self, #selector(hideKeyboard))
    }
    
    func hideKeyboard() {
        newPhoneNumberTextField.resignFirstResponder()
        view.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        newPhoneNumberTextField.resignFirstResponder()
        view.endEditing(true)
    }
}
//MARK: text field delegate
extension PhoneViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case newPhoneNumberTextField:
            guard let count = textField.text?.count else { return }
            if count < 4 || count > 15  {
                showAlert()
            }
        default:
            break
        }
    }
}
//MARK: alert controller
extension PhoneViewController {
    func showAlert() {
        let alertController = UIAlertController(title: "Invalid number", message: "The number you entered doesn’t appear to be valid. Check the number and try again.", preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Try Again", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.modalPresentationStyle = .overFullScreen
        alertController.modalPresentationCapturesStatusBarAppearance = true
        alertController.addAction(action)
        showModal(alertController, animated: true, completion: {
            DispatchQueue.main.async {
                self.setStatusBarBackgroundColor(color: .clear)
            }
        })
    }
}
//MARK: actions
extension PhoneViewController {
    func showCountryCodes() {
        let controller = CountryCodesViewController.create()
        controller.delegate = self
        self.push(controller)
    }
    
    @IBAction func backAction(_ sender: UIBarButtonItem) {
        view.endEditing(true)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextAction(_ sender: UIBarButtonItem) {
        guard let count = newPhoneNumberTextField.text?.count else {
            return
        }
        if count < 6 || count > 15  {
            showAlert()
            return
        }
        //this thing temrory, phone number will saved in user profile
        if let code = countryCodeLabel.text, let number = newPhoneNumberTextField.text, let country = selectedCountryNamelabel.text {
            userStore.saveCode(code)
            userStore.savePhone(number)
            userStore.saveContry(country)
            
            let number = code + number
            UsersAPI.updatePhone( number.removeSpecialCharsFromString(), completion: { (phone, error) in
                    DispatchQueue.main.async {
                        self.hideHud()
                        if !phone.isEmpty {
                            self.curentNumberLabel.text = phone
                        } else {
                            self.curentNumberLabel.text = "Didn't set phone number yet"
                        }
                        if let error = error {
                            Helper.show(alert: error.message)
                        }
                }
            })
        }
        newPhoneNumberTextField.resignFirstResponder()
        navigationController?.popViewController(animated: true)
    }
}

//MARK: CountryPhoneDelegate
extension PhoneViewController: CountryPhoneDelegate {
    func country(_ tableView: UITableView, didSelectCountry model: CountryPhone?) {
        countryCodeLabel.text = model?.dialCode
        selectedCountryNamelabel.text = model?.name
    }
}
//MARK: create controller
extension PhoneViewController {
    static func create() -> PhoneViewController {
        return UIStoryboard.settings.instantiateViewController(withIdentifier: String(describing: self)) as! PhoneViewController
    }
}

extension String {
    func parsePhoneWithSpaces() -> String {
        if self.count < 10 { return self }
        let index = self.index(self.startIndex, offsetBy: self.count - 10)
        let subStr = self.substring(to: index)
        let subString = self.substring(from: index)
        var nsStr: NSString = String(subString) as NSString
        
        let r1 = NSRange(location: nsStr.length - 4, length: 0)
        let r2 = NSRange(location: nsStr.length - 7, length: 0)
        let r0 = NSRange(location: nsStr.length - 10, length: 0)
        
        for range in [r1, r2, r0] {
            nsStr = nsStr.replacingCharacters(in: range, with: " ") as NSString
        }
        let partPhone = nsStr as String
        return subStr.appending(partPhone)
    }
}
