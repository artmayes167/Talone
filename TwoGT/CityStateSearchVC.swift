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

protocol CityStateSelectionDelegate {
    func selected(state: String, city: String)
}

class CityStateSearchVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateContainer: UIView!
    @IBOutlet weak var cityContainer: UIView!
    
    var delegate: CityStateSelectionDelegate?
    
    var statesTVC: LocationPickerTVC?
    var citiesTVC: LocationPickerTVC?
    var states: [USState] = []
    var allStates: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        let path = Bundle.main.path(forResource: "citiesAndStates", ofType: "json")
        let url = URL.init(fileURLWithPath: path!)
        do {
            let jsonData = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            
            print(jsonData)
            let container = try decoder.decode([String: [String]].self, from: jsonData) as [String: [String]]
            print(container)
            container.forEach { (key, value) in
                let st = USState(name: key, cities: value)
                states.append(st)
                allStates.append(key)
            }
            allStates.sort{ $0 < $1 }
            stateSelector?.configure(list: allStates, itemType: .state)
            
        } catch {
            print(error.localizedDescription)
        }
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

    // In a storyboard-based application, you will often want to do a little preparation before navigation
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

extension CityStateSearchVC: LocationPickerDelegate {
    func selected(item: String, type: ItemType) {
        switch type {
        case .state:
            stateTextField.text = item
            stateContainer.isHidden = true
            selectedState = item
            if let arr = states.first(where: { $0.name == item })?.cities {
                citySelector?.configure(list: arr.sorted(), itemType: .city)
                cityTextField.isEnabled = true
                cityTextField.text = ""
                selectedCity = nil
            } else {
                fatalError()
            }
        case .city:
            cityTextField.text = item
            cityContainer.isHidden = true
            selectedCity = item
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
