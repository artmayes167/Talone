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
    
    func stringValue() -> String {
        switch self {
        case .home:
            return "home"
        case .alternate:
            return "alternate"
        default:
            return "none"
        }
    }
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
    
    let user = CoreDataGod.user
    
    private var statesTVC: LocationPickerTVC?
    private var citiesTVC: LocationPickerTVC?
    private var states: [USState] = []
    private var allStates: [String] = []
    private var sections: Dictionary<String, [SearchLocation]> = [:]
    
    var saveType: SaveType = .none
    var stateSelector: LocationPickerTVC?
    var citySelector: LocationPickerTVC?
    
    var locationForSave: SearchLocation?

    /// To be set by presenting controller, defaults to `unwindToMarketplaceSearch`
    public var unwindSegueIdentifier: String = "unwindToMarketplaceSearch"
    
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
            let container = try decoder.decode([String: [String]].self, from: jsonData) as [String: [String]]
            container.forEach { (key, value) in
                let st = USState(name: key, cities: value)
                states.append(st)
                allStates.append(key)
            }
            allStates.sort{ $0 < $1 }
            stateSelector?.configure(list: allStates, itemType: .state)
            stateContainer.isHidden = true
            statesCoverView?.isHidden = true
            
        } catch { print(error.localizedDescription) }
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
                if let l = locationForSave {
                    l.type = x.stringValue()
                }
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
        if let n = self.navigationController { n.popViewController(animated: true) }
        else { dismiss(animated: true, completion: nil) }
    }
}

 // MARK: - Saved Locations TableView DataSource/Delegate
extension CityStateSearchVC: UITableViewDataSource, UITableViewDelegate {
    enum SectionTitles: String, CaseIterable {
        case home, alternate
    }
    
    func setApplicableSections() {
        sections = user.sortedAddresses(clean: false)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        setApplicableSections()
        return sections.keys.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ["home", "alternate"][section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = ["home", "alternate"][section]
        return sections[key]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let key = ["home", "alternate"][indexPath.section]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SavedLocationCell
        guard let s = sections[key] else { return cell }
        cell.titleLabel.text = s[indexPath.row].displayName()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key = ["home", "alternate"][indexPath.section]
        guard let s = sections[key] else { fatalError() }
        let loc = s[indexPath.row]
        locationForSave = loc
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
            if let arr = states.first(where: { $0.name.uppercased() == item.uppercased() })?.cities {
                cityTextField.text = ""
                cityInputView.isHidden = false
                citySelector?.configure(list: arr.sorted(), itemType: .city)
            } else { fatalError() }
        case .city:
            cityTextField.text = item
            cityContainer.isHidden = true
            searchButton.isEnabled = true
            locationForSave = SearchLocation.createSearchLocation(city: item, state: stateTextField.text!, type: saveType.stringValue())
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
    private var list: [String: [String]]  = [:]
    private var keys: [String] = [] { didSet { tableView.reloadData() } }
    private var type: ItemType = .undetermined
    var delegate: LocationPickerDelegate?
    
    func configure(list: [String], itemType: ItemType) {
        var dict: [String: [String]] = [:]
        var firstLettersArray: [String] = []
        for string in list {
            if let firstChar = string.first {
                if var array = dict[String(firstChar)] {
                    array.append(string)
                    dict[String(firstChar)] = array
                } else { // first time
                    firstLettersArray.append(String(firstChar))
                    dict[String(firstChar)] = [string]
                }
            } else { fatalError() }
        }
        self.list = dict
        self.keys = firstLettersArray.sorted()
        
        type = itemType
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return keys.count
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return keys
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return keys[section]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = keys[section]
        guard let array = list[key] else { return 0 }
        return array.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SimpleSearchCell
        let key = keys[indexPath.section]
        guard let v = list[key] else { fatalError() }
        cell.basicLabel.text = v[indexPath.row]
        // cell.colorBar
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key = keys[indexPath.section]
        guard let array = list[key] else { fatalError() }
        delegate?.selected(item: array[indexPath.row], type: type)
    }
}
