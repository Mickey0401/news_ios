//
//  YoutubeSearchController.swift
//  havr
//
//  Created by Agon Miftari on 4/25/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

class YoutubeSearchController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchField: UITextField!
    
    @IBOutlet weak var cancelButtonWidthConstraints: NSLayoutConstraint!
    @IBOutlet weak var cancelButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        tableInit()
        commonInit()
    }
    
    func tableInit() {
        
        tableView.registerYoutubeSearchTableCell()
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        
    }
    
    func commonInit() {
        
        searchField.delegate = self
        searchField.clearButtonMode = .whileEditing
        cancelButtonWidthConstraints.constant = 0
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
    }
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.cancelButtonWidthConstraints.constant = 0
            
        }) { (false) in
            self.searchField.resignFirstResponder()
            
        }
        
    }
    
}

extension YoutubeSearchController {
    static func create() -> YoutubeSearchController {
        return UIStoryboard.reaction.instantiateViewController(withIdentifier: "YoutubeSearchController") as! YoutubeSearchController
    }
}

extension YoutubeSearchController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueYoutubeSearchTableCell(indexpath: indexPath)
        
        cell.selectionStyle = .none
    
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let videoReactionVC = VideoReactionController.create()
        
//        self.push(videoReactionVC)
    }
    
}

extension YoutubeSearchController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.cancelButtonWidthConstraints.constant = 72
            
        }, completion: nil)
        
    }
    
}
