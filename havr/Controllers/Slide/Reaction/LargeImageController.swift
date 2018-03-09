//
//  LargeImageController.swift
//  havr
//
//  Created by Agon Miftari on 4/24/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

class LargeImageController: UIViewController, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: - OUTLETS
    @IBOutlet weak var reactionVideoButton: UIButton!
    @IBOutlet weak var backButton: UIButton!

    //MARK: - VARIABLES
    var post: Post!
    
    
    //MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(false)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    //MARK: - ACTIONS
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.pop()
    }

    
    @IBAction func reactionVideoButtonPressed(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Create a reaction to a video from", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Selected Video", style: .default, handler: { (handler) in
            
            //Selected video function here ...
            
            let videoReactionVC = VideoReactionController.create(for: self.post)
            
            self.push(videoReactionVC) 
        }))
        
        alert.addAction(UIAlertAction(title: "Camera Roll", style: .default, handler: { (handler) in
        
            //Camera Roll function here ...
            
            self.openPhotoLibraryButton(self)
        }))
        
        alert.addAction(UIAlertAction(title: "Youtube", style: .default, handler: { (handler) in
            
            //Youtube function here ...
            
            let youtubeSearchVC = YoutubeSearchController.create()
            
            self.push(youtubeSearchVC)
            
        }))
        alert.view.tintColor = Apperance.appBlueColor
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.view.tintColor = Apperance.appBlueColor

        self.navigationController?.present(alert, animated: true, completion: nil)
        
    }
    
    func openPhotoLibraryButton(_ sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
}

//MARK: - EXTENSIONS
extension LargeImageController {
    static func create() -> LargeImageController {
        return UIStoryboard.reaction.instantiateViewController(withIdentifier: "LargeImageController") as! LargeImageController
    }
}

