//
//  CityStateSearchVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 8/11/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import CoreData

struct USState: Decodable {
    let name: String
    let cities: [String]
}

enum SaveType: Int, CaseIterable {
    case home, alternate, none
}

class CityStateSearchVC: UIViewController {
    
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateContainer: UIView!
    @IBOutlet weak var cityContainer: UIView!
    
    @IBOutlet weak var cityInputView: UIView!
    
    @IBOutlet weak var typeOfSaveSegmentedControl: UISegmentedControl!
    @IBOutlet weak var searchButton: UIButton!
    
    // Managing Saved/New
    @IBOutlet weak var savedLocationTableView: UITableView!
    @IBOutlet weak var savedLocationView: UIView!
    
    @IBOutlet weak var newCreationStack: UIStackView!
    
    @IBOutlet weak var statesCoverView: UIView?
    
    let user = AppDelegate.user
    
    var statesTVC: LocationPickerTVC?
    var citiesTVC: LocationPickerTVC?
    var states: [USState] = []
    var allStates: [String] = []
    var sections: Dictionary<String, [SearchLocation]> = [:]
    
    var saveType: SaveType = .none
    var selectedLocation: [DefaultsSavedLocationKeys: String] = [:]
    var stateSelector: LocationPickerTVC?
    var citySelector: LocationPickerTVC?

    /// To be set by presenting controller, defaults to `unwindToMarketplaceSearch`
    var unwindSegueIdentifier: String = "unwindToMarketplaceSearch"
    
     // MARK: - View Life Cycle
    @IBOutlet weak var pageHeaderView: SecondaryPageHeader!
    override func viewDidLoad() {
        super.viewDidLoad()
        pageHeaderView.setTitleText("Search Location")
        
        if let s = statesCoverView {
            view.bringSubviewToFront(s)
        }
        savedLocationTableView.rowHeight = UITableView.automaticDimension
        savedLocationTableView.estimatedRowHeight = 50

        let path = Bundle.main.path(forResource: "citiesAndStates", ofType: "json")
        let url = URL.init(fileURLWithPath: path!)
        do {
            let jsonData = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            
            //print(jsonData)
            let container = try decoder.decode([String: [String]].self, from: jsonData) as [String: [String]]
            //print(container)
            container.forEach { (key, value) in
                let st = USState(name: key, cities: value)
                states.append(st)
                allStates.append(key)
            }
            allStates.sort{ $0 < $1 }
            stateSelector?.configure(list: allStates, itemType: .state)
            stateContainer.isHidden = true
            statesCoverView?.isHidden = true
            
        } catch {
            print(error.localizedDescription)
        }
        savedLocationTableView.reloadData()
        savedLocationView.isHidden = true
    }
    
     // MARK: - IBActions
    @IBAction func selectedNewOrSaved(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            savedLocationView.isHidden = true
            newCreationStack.isHidden = false
            view.layoutIfNeeded()
        case 1:
            savedLocationView.isHidden = false
            newCreationStack.isHidden = true
            view.layoutIfNeeded()
            savedLocationTableView.reloadData()
        default:
            print("Oops in CityStateSearchVC")
        }
    }
    
    @IBAction func selectedTypeOfSave(_ sender: UISegmentedControl) {
        for x in SaveType.allCases {
            if x.rawValue == sender.selectedSegmentIndex {
                saveType = x
                continue
            }
        }
    }
    
    @IBAction func saveSearchLocation(_ sender: Any) {
        performSegue(withIdentifier: unwindSegueIdentifier, sender: nil)
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case stateTextField:
            textField.resignFirstResponder()
            stateContainer.isHidden = false
            statesCoverView?.isHidden = false
            cityContainer.isHidden = true
        case cityTextField:
            textField.resignFirstResponder()
            stateContainer.isHidden = true
            statesCoverView?.isHidden = true
            cityContainer.isHidden = false
        default:
            print("Need another segue defined in CityStateSearchVC")
        }
        view.layoutIfNeeded()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "toStates":
            let vc = segue.destination as! LocationPickerTVC
            vc.delegate = self
            stateSelector = vc
        case "toCities":
            let vc = segue.destination as! LocationPickerTVC
            vc.delegate = self
            citySelector = vc
        default:
            print("Unknown segue in CityStateSearchVC")
        }
        
    }
    
    @IBAction func back(_ sender: Any) {
        if let n = self.navigationController {
            n.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
}

 // MARK: - Saved Locations TableView DataSource/Delegate
extension CityStateSearchVC: UITableViewDataSource, UITableViewDelegate {
    enum SectionTitles: String, CaseIterable {
        case home, alternate
    }
    
    func setApplicableSections() {
        sections = user.sortedAddresses()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        setApplicableSections()
        return sections.keys.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "header") as! SavedLocationCell
        let array = ["home", "alternate"]
        cell.titleLabel.text = array[section]
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let array = ["home", "alternate"]
        return sections[array[section]]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let array = ["home", "alternate"]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SavedLocationCell
        guard let s = sections[array[indexPath.section]] else { return cell }
        cell.titleLabel.text = s[indexPath.row].displayName()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let array = ["home", "alternate"]
        let type = array[indexPath.section]
        guard let s = sections[type] else { fatalError() }
        let loc = s[indexPath.row]
        selectedLocation = [.city: loc.city!, .state: loc.state!]
        searchButton.isEnabled = true
    }
}

class SavedLocationCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var colorBarView: DesignableView?
}

extension CityStateSearchVC: LocationPickerDelegate {
    func selected(item: String, type: ItemType) {
        switch type {
        case .state:
            stateTextField.text = item
            // Hide the table in the stack
            stateContainer.isHidden = true
            statesCoverView?.isHidden = true
            selectedLocation[.state] = item
            if let arr = states.first(where: { $0.name.uppercased() == item.uppercased() })?.cities {
                cityTextField.text = ""
                cityInputView.isHidden = false
                citySelector?.configure(list: arr.sorted(), itemType: .city)
            } else {
                fatalError()
            }
        case .city:
            cityTextField.text = item
            cityContainer.isHidden = true
            selectedLocation[.city] = item
            searchButton.isEnabled = true
        default:
            print("Forgot to set ItemType in CityStateSearchVC")
        }
        view.layoutIfNeeded()
    }
}

protocol LocationPickerDelegate {
    func selected(item: String, type: ItemType)
}

enum ItemType {
    case undetermined, state, city
}

class LocationPickerTVC: UITableViewController {
    var list: [String] = []
    var type: ItemType = .undetermined
    var delegate: LocationPickerDelegate?
    
    func configure(list: [String], itemType: ItemType) {
        self.list = list
        type = itemType
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SimpleSearchCell
        cell.basicLabel.text = list[indexPath.row]
        // cell.colorBar
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.selected(item: list[indexPath.row], type: type)
    }
}
