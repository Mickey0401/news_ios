//
//  TermsAndPrivacyController.swift
//  havr
//
//  Created by Ismajl Marevci on 4/27/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

class TermsAndPrivacyController: UIViewController {
    
    //MARK: - OUTLETS
    @IBOutlet weak var editedTextView: UITextView!

    //MARK: - VARIABLES
    var navTitle : String!
    var termsOrPPText : String! = nil
    //MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        editedTextView.text = termsOrPPText
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        editedTextView.setContentOffset(CGPoint.zero, animated: false)
        editedTextView.showsHorizontalScrollIndicator = false
        editedTextView.contentInset = UIEdgeInsetsMake(10, 0, 10, 0)
        editedTextView.textAlignment = .left
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.title = navTitle
    }

}
//MARK: - EXTENSIONS
extension TermsAndPrivacyController {
    static func create() -> TermsAndPrivacyController {
        return UIStoryboard.introduction.instantiateViewController(withIdentifier: "TermsAndPrivacyController") as! TermsAndPrivacyController
    }
}
