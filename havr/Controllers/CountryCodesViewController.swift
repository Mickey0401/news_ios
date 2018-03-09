//
//  CountryCodesViewController.swift
//  havr
//
//  Created by Alexandr Lobanov on 12/26/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

protocol CountryPhoneDelegate: class {
    func country(_ tableView: UITableView, didSelectCountry model: CountryPhone?)
}

class CountryCodesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    fileprivate let countries = Country().countries
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    fileprivate var filteredResult = [CountryPhone]()
    weak var delegate: CountryPhoneDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Country Code"
        searchController.searchResultsUpdater = self
        if #available(iOS 9.1, *) {
            searchController.obscuresBackgroundDuringPresentation = false
        }
        searchController.searchBar.placeholder = "Search Country"
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            navigationItem.titleView = searchController.searchBar
        }
        searchController.searchBar.delegate = self
        searchController.searchBar.backgroundColor = .white
//        searchController.searchBar.barTintColor = .white
        navigationController?.navigationBar.barTintColor = .white
        definesPresentationContext = false
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredResult = countries.filter({ (model) -> Bool in
            return (model.name.lowercased().contains(searchText.lowercased()))
        }) 
        tableView.reloadData()
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }

}
//MARK: SearchBarDelegate
extension CountryCodesViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
}

//MARK: result updating
extension CountryCodesViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

//MARK: create from storyboardID
extension CountryCodesViewController {
    static func create() -> CountryCodesViewController {
        return UIStoryboard.settings.instantiateViewController(withIdentifier: String(describing: self)) as! CountryCodesViewController
    }
}

//MARK: tableview delegate
extension CountryCodesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.country(tableView, didSelectCountry: isFiltering() ?  filteredResult[indexPath.row] : countries[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
        searchController.isActive = false
        navigationController?.popViewController(animated: true)
    }
}

//MARK: datasource
extension CountryCodesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredResult.count
        }
        return countries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "country_code_cell", for: indexPath) as! PhoneContryTableViewCell
        let country = isFiltering() ?  filteredResult[indexPath.row] : countries[indexPath.row]
        cell.updatWith(model: country)
        return cell
    }
}

