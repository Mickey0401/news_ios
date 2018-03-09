//
//  InterestController.swift
//  havr
//
//  Created by Ismajl Marevci on 6/7/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import MBProgressHUD

class InterestController: UIViewController {

    //MARK: - OUTLETS
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var leftBarButton: UIBarButtonItem!
    
    //MARK: - VARIABLES
    var gap: CGFloat = UIScreen.main.bounds.width / (414/15)
    fileprivate let maxCountActiveInterest = 5
    var activeInterests : [UserInterest] = []
    var interests: [UserInterest] = []{
        didSet{
            preProcessInterests()
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    var headerView : InterestHeaderCollectionReusableView!
    
    //MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        activeInterests = ResourcesManager.activeInterests
        interests = ResourcesManager.allInterests
        collectionInit()
        getInterests()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = . default
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.backgroundColor = .white
        GA.TrackScreen(name: "Choose interests")
    }
    
    func collectionInit() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsetsMake(gap, gap, gap + 50, gap)
        collectionView.registerInterestListCollectionCell()
        collectionView.register(UINib.init(nibName: "InterestHeaderCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "InterestHeaderCollectionReusableView")
        collectionView.reloadData()
    }
    
    func getInterests(){
        InterestsAPI.getAll { (interests, error) in
            if let interests = interests{
                ResourcesManager.allInterests = interests
                self.collectionView.reloadData()
            }
        }
    }
    
    func preProcessInterests(){
        for u in interests{
            u.isActive = activeInterests.filter({ (t) -> Bool in
                return u == t
            }).count > 0
        }
    }

    //MARK: - ACTIONS
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        let m = MBProgressHUD.showAdded(to: self.view, animated: true)
        m.contentColor = Apperance.appBlueColor
        InterestsAPI.addInterests(interests: activeInterests) { (success, error) in
            if success{
                m.hide(animated: true)
                ResourcesManager.userInterests = self.activeInterests
                BroadcastAPI.getKeywords { (keywords, error) in
                    guard error == nil else { return }
                    ResourcesManager.userKeywords = keywords
                    var allKeywords = [String]()
                    for item in keywords {
                        allKeywords += item.removedSpaces()
                    }
                    let formatedKeywords = allKeywords.map({$0.capitalized}).joined(separator: " OR ")
                    ResourcesManager.keywordAsParam = formatedKeywords
                }
                self.pop()
            }else{
                console("add interests error: \(String(describing: error?.message))")
            }
            m.hide(animated: true)
        }
    }
    @IBAction func leftBarButtonPressed(_ sender: UIBarButtonItem) {
        self.pop()
    }
}

//MARK: - EXTENSIONS
extension InterestController {
    static func create() -> InterestController {
        return UIStoryboard.profile.instantiateViewController(withIdentifier: "InterestController") as! InterestController
    }
}

extension InterestController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return interests.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueInterestListCollectionCell(indexpath: indexPath)
        let interest = interests[indexPath.row]
        
        
        cell.interestNameLabel.text = interest.item?.name
        cell.interestImageView.kf.setImage(with: interest.item?.getUrl(), placeholder: nil)

        DispatchQueue.main.async {
            cell.interestImageView.cornerRadius = cell.interestImageView.frame.height / 2
            cell.interestBackgroundView.cornerRadius = cell.interestBackgroundView.frame.height / 2
            cell.isActiveView.cornerRadius = cell.isActiveView.frame.height / 2
        }
        delay(delay: 0) { 
            cell.isActiveView.isHidden = !interest.isActive
        }
        
        let width = collectionView.frame.size.width
        if width == 320 { // 5
            cell.interestNameLabel.font = UIFont.robotoMediumFont(12)
        }else if width == 375 { // 7
            cell.interestNameLabel.font = UIFont.robotoMediumFont(12)
        }else if width == 414 { // 7 plus
            cell.interestNameLabel.font = UIFont.robotoMediumFont(14)
        }else {
            cell.interestNameLabel.font = UIFont.robotoMediumFont(14)
        }
        cell.layoutSubviews()

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let interest = interests[indexPath.row]
        let cell = collectionView.cellForItem(at: indexPath)
        
        if interest.isActive {
            if activeInterests.count > 1 {
                for u in activeInterests {
                    if u == interest {
                        activeInterests.remove(at: activeInterests.index(of: u)!)
                        interest.isActive = false
                    }
                }
            }else{
                //alert ose shake
                cell?.shake()
            }

        }else{
            if activeInterests.count == maxCountActiveInterest {
                //alert ose shake
                cell?.shake()
            }else{
                interest.isActive = true
                activeInterests.append(interest)
            }
        }
        collectionView.reloadItems(at: [indexPath])
        headerView.selectedLabel.text = "Selected \(activeInterests.count - 2) of 3 "
        console("activeInterests: \(activeInterests.count)")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (collectionView.frame.width - (3 * gap)) / 2
        let height: CGFloat = width / (183/65)
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return gap
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        headerView = (collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "InterestHeaderCollectionReusableView", for: indexPath) as! InterestHeaderCollectionReusableView)
        headerView.delegate = self
        headerView.selectedLabel.text = "Selected \(activeInterests.count - 2) of 3 "
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = collectionView.frame.size.width
        return CGSize(width: width, height: 160)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, heightForHeaderInSection section: Int) -> Float {
        return 160
    }
}

extension InterestController : InterestHeaderCollectionReusableViewDelegate {
    func segmentController(sender: InterestHeaderCollectionReusableView, interests index: Int) {
        interests = ResourcesManager.allInterests
        print ("INTERESTS PRESSED")
    }
    func segmentController(sender: InterestHeaderCollectionReusableView, trending index: Int) {
        interests = ResourcesManager.trendingInterests
        print ("TRENDING PRESSED")
    }
    func segmentController(sender: InterestHeaderCollectionReusableView, inactive index: Int) {
        interests = ResourcesManager.inactiveInterests
        print ("INACTIVE PRESSED")
    }
}
