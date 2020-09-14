//
//  CityStateSearchVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 8/11/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit

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
    var savedLocations: Saves = Saves.shared()
    
    var statesTVC: LocationPickerTVC?
    var citiesTVC: LocationPickerTVC?
    var states: [USState] = []
    var allStates: [String] = []
    var sectionTitles: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            
        } catch {
            print(error.localizedDescription)
        }
        savedLocationTableView.reloadData()
        savedLocationView.isHidden = true
    }
    
    
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
    
    var saveType: SaveType = .none
    
    @IBAction func selectedTypeOfSave(_ sender: UISegmentedControl) {
        for x in SaveType.allCases {
            if x.rawValue == sender.selectedSegmentIndex {
                saveType = x
                continue
            }
        }
    }
    
    @IBAction func saveSearchLocation(_ sender: Any) {
        // Pass city, state and save type
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case stateTextField:
            textField.resignFirstResponder()
            stateContainer.isHidden = false
            cityContainer.isHidden = true
        case cityTextField:
            textField.resignFirstResponder()
            stateContainer.isHidden = true
            cityContainer.isHidden = false
        default:
            print("Need another segue defined in CityStateSearchVC")
        }
        view.layoutIfNeeded()
    }
    
    var selectedState: String?
    var selectedCity: String?
    var stateSelector: LocationPickerTVC?
    var citySelector: LocationPickerTVC?
    
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
}

extension CityStateSearchVC: UITableViewDataSource, UITableViewDelegate {
    
    func applicableSections() -> NSDictionary {
        sectionTitles = Saves.CodingKeys.allCases.map { $0.rawValue }
        sectionTitles.sort { $0 > $1 }
        var myDict: [String: AnyObject?] = [:]
        for s in sectionTitles {
            myDict[s] = Saves.shared().propertyValue(s)
        }
        let compactDict = myDict.filter { (key, value) -> Bool in
            if let v = value as? [CityState], !v.isEmpty { return true }
            if let _ = value as? CityState { return true }
            return false
        }     //compactMapValues { obj in obj }
        sectionTitles = sectionTitles.filter { compactDict[$0] != nil }
        return NSDictionary(dictionary: compactDict as [AnyHashable : Any])
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        _ = applicableSections()
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SavedLocationCell
        _ = applicableSections()
        let a = sectionTitles
        cell.titleLabel.text = a[section]
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let _ = applicableSections()[sectionTitles[section]] as? CityState { return 1 }
        if let item = applicableSections()[sectionTitles[section]] as? [CityState] { return item.count }
        print("applicableSections mechanism has failed miserably in numberOfRowsInSection")
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SavedLocationCell
        let sections = applicableSections()
        
        if let item = sections[sectionTitles[indexPath.section]] as? CityState {
            cell.titleLabel.text = item.displayName()
        } else if let item = sections[sectionTitles[indexPath.section]] as? [CityState] {
                cell.titleLabel.text = item[indexPath.row].displayName()
        } else {
            cell.titleLabel.text = "Suck It, Art"
            print("applicableSections mechanism has failed miserably in cellForRowAt")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

class SavedLocationCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
}

extension CityStateSearchVC: LocationPickerDelegate {
    func selected(item: String, type: ItemType) {
        switch type {
        case .state:
            stateTextField.text = item
            // Hide the table in the stack
            stateContainer.isHidden = true
            selectedState = item
            if let arr = states.first(where: { $0.name.uppercased() == item.uppercased() })?.cities {
                cityTextField.text = ""
                selectedCity = nil
                cityInputView.isHidden = false
                citySelector?.configure(list: arr.sorted(), itemType: .city)
            } else {
                fatalError()
            }
        case .city:
            cityTextField.text = item
            cityContainer.isHidden = true
            selectedCity = item
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = list[indexPath.row]
        return cell ?? UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.selected(item: list[indexPath.row], type: type)
    }
}
