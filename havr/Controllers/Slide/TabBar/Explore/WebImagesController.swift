//
//  WebImagesController.swift
//  havr
//
//  Created by Agon Miftari on 5/5/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import Alamofire

protocol WebImageDelegate: class {
    func webImageChosen(image: BingImage)
}

class WebImagesController: UIViewController {

    @IBOutlet weak var webImagesCollection: UICollectionView!
    
    var leftBar : UIBarButtonItem?
    var rightBar : UIBarButtonItem?
    lazy var searchBar : UISearchBar = {
        
        Helper.exploreStatusBar(placeholder: "Search")
    }()
    
    var dataSource: [BingImage] = []
    
    var query: String?
    
    weak var delegate: WebImageDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionInit()
        commonInit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GA.TrackScreen(name: "Web Image Search")

    }
    
    func collectionInit() {
        webImagesCollection.registerFocusImageCollectionCell()
    }
    
    func commonInit() {
        Helper.setupNavSearchBar(searchBar: searchBar)
        
        let searchBarContainer = SearchBarContainerView(customSearchBar: searchBar)
        searchBarContainer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
        navigationItem.titleView = searchBarContainer
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.becomeFirstResponder()
        leftBar = navigationItem.leftBarButtonItem
        rightBar = navigationItem.rightBarButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


extension WebImagesController {
    static func create() -> WebImagesController {
        return UIStoryboard.explore.instantiateViewController(withIdentifier: "WebImagesController") as! WebImagesController
    }
}


extension WebImagesController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueFocusImageCollectionCell(indexpath: indexPath)
        
        let image = dataSource[indexPath.item]
        cell.productHomeImageView.kf.setImage(with: image.getImageUrl())
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let image = dataSource[indexPath.item]
        self.delegate?.webImageChosen(image: image)
        self.hideModal()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.size.width - 10) / 4
        let size = CGSize(width: width, height: width)
        
        return size
    }
}

extension WebImagesController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        UIView.animate(withDuration: 0.2, animations: {
            self.resignFirstResponder()
        }) { (handler) in
            self.hideModal(false)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("\(searchText)")
        query = searchText
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        searchBar.resignFirstResponder()
        
        guard let input = query, !input.isEmpty else {
            Helper.show(alert: "Please give a text to search!")
            return
        }
        
        print("Ky eshte Teksti: \(input)")
        self.showHud()
        BingAPI.searchImages(with: input) { (images, error) in
            self.hideHud()
            if let images = images{
                self.dataSource = images
                self.webImagesCollection.reloadData()
            }else{
                if let er = error{
                    Helper.show(alert: er.message)
                }
            }
        }
    }
}
