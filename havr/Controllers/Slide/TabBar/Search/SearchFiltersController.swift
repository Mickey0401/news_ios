//
//  SearchFiltersController.swift
//  havr
//
//  Created by Ismajl Marevci on 4/20/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

protocol SearchFiltersControllerDelegate: class {
    func searchFiltersController(sender: SearchFiltersController, updateFilter: SearchFilter, didUpdate button: UIBarButtonItem)
}

class SearchFiltersController: UIViewController {
    
    //MARK: - OUTLETS
    
    @IBOutlet weak var distanceSlider: CustomSlider!
    @IBOutlet weak var ageSlider: UIView!
    @IBOutlet weak var rightBarItem: UIBarButtonItem!
    @IBOutlet weak var leftBarItem: UIBarButtonItem!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    //MARK: - VARIABLES
    var distanceSelected : Int? = nil
    let distances = [1, 5, 15, 40, 999999]
    var distanceMeter = ["0.5 km","5 km","15 km","40 km","50km+"]
    
    let selectedColor = UIColor(red255: 71, green255: 103, blue255: 141)
    let unselectedColor = UIColor(red255: 197, green255: 195, blue255: 197)
    var searchFilter: SearchFilter = SearchFilter()
    weak var delegate: SearchFiltersControllerDelegate?
    
    //MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let filter = SearchFilter.get() {
            self.searchFilter = filter
        }
        self.fillFields()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        GA.TrackScreen(name: "Search Filter")
    }
    
    func fillFields() {
        //gender
        if searchFilter.gender == "Male" {
            segmentedControl.selectedSegmentIndex = 0
//            maleButton.sendActions(for: .touchUpInside)
        }else if searchFilter.gender == "Female"{
            segmentedControl.selectedSegmentIndex = 1
//            femaleButton.sendActions(for: .touchUpInside)
        }else{
            segmentedControl.selectedSegmentIndex = 2
//            bothButton.sendActions(for: .touchUpInside)
        }
        
        //age
        setupAgeSlider()
        
        //distance
        distanceSlider.setThumbImage(#imageLiteral(resourceName: "DistanceBar"), for: UIControlState())
        distanceSlider.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)

        distanceSlider.value = Float(searchFilter.distance)
    }

    func setupAgeSlider(){
        let kWidth: CGFloat = 300
        let rangeSlider = GZRangeSlider(frame: CGRect(x: 0,y: 0,width: kWidth,height: 30))
        if let user = AccountManager.currentUser{
            if user.age < 18{
                rangeSlider.setRange(13, maxRange: 17, accuracy: 1)
                rangeSlider.setCurrentValue(searchFilter.minAge, right: searchFilter.maxAge)
            }else{
                rangeSlider.setRange(18, maxRange: 99, accuracy: 1)
                rangeSlider.setCurrentValue(searchFilter.minAge, right: searchFilter.maxAge)
            }
        }
        rangeSlider.valueChangeClosure = {
            (left, right) -> () in
            CacheManager.write {
                self.searchFilter.minAge = left
                self.searchFilter.maxAge = right
            }
        }
        ageSlider.addSubview(rangeSlider)        
    }
    
    
    //MARK: - ACTIONS
    @IBAction func distanceSliderChanged(_ sender: CustomSlider) {
        CacheManager.write {
            searchFilter.distance = Int(sender.value)
        }
    }
    @IBAction func rightBarItemClicked(_ sender: UIBarButtonItem) {
        searchFilter.store()
        UIView.animate(withDuration: 0.1, animations: {
            self.delegate?.searchFiltersController(sender: self, updateFilter: self.searchFilter, didUpdate: sender)
        }) { (completed) in
            self.hideModal()
        }
    }
    @IBAction func segmentedControlPressed(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            CacheManager.write {
                searchFilter.gender = "Male"
            }
            break
        case 1:
            CacheManager.write {
                searchFilter.gender = "Female"
            }
            break
        case 2:
            CacheManager.write {
                searchFilter.gender = "Both"
            }
            break
        default: break
        }
    }
    @IBAction func leftBarItemClicked(_ sender: UIBarButtonItem) {
        self.hideModal()
    }
}

//MARK: - EXTENSIONS
extension SearchFiltersController {
    static func create() -> SearchFiltersController {
        return UIStoryboard.search.instantiateViewController(withIdentifier: "SearchFiltersController") as! SearchFiltersController
    }
}
