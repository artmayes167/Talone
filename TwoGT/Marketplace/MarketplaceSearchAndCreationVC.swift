//
//  AddANeedVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 8/9/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import Firebase

class Need {
    var type: NeedType?
}

@IBDesignable public class DesignableTextView: UITextView {}

class MarketplaceSearchAndCreationVC: UIViewController, NeedSelectionDelegate {

    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var categoriesPopOver: UIView!
    @IBOutlet weak var whereTextLabel: UILabel!
    @IBOutlet weak var whereTextField: UITextField!
    @IBOutlet weak var buttonsAndDescriptionView: UIView!
    @IBOutlet weak var descriptionTextLabel: UILabel!
    @IBOutlet weak var descriptionTextView: DesignableTextView!
    @IBOutlet var dismissTapGesture: UITapGestureRecognizer!
    @IBOutlet weak var createNewNeedHaveButton: UIButton!

    var currentNeed = Need()
    var currentCity: String?
    var currentState: String?
    var currentCountry = "USA"
    var currentNeedHaveSelectedSegmentIndex = 0

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        //dismissTapGesture.isEnabled = false

        currentCity = UserDefaults.standard.string(forKey: "currentCity")
        currentState = UserDefaults.standard.string(forKey: "currentState")
        currentCountry = UserDefaults.standard.string(forKey: "currentCountry") ?? "USA"

        if let c = currentCity, let s = currentState {    // TODO: Countries other than USA, Mexico may not have states
            whereTextField.text = c.capitalized + ", " + s.capitalized
        }

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
           super.viewDidAppear(animated)
           view.endEditing(true)
       }

     // MARK: - Actions
    @IBAction func dismissOnTap(_ sender: Any) {
        if categoriesPopOver.isHidden == false {
            categoriesPopOver.isHidden = true
            //dismissTapGesture.isEnabled = false
        }
        view.endEditing(true)
    }

    @IBAction func selectedNeedOrHave(_ sender: UISegmentedControl) {
        currentNeedHaveSelectedSegmentIndex = sender.selectedSegmentIndex
        switch sender.selectedSegmentIndex {
        case 1:
            whereTextLabel.text = "Where Do You Have It?"
            createNewNeedHaveButton.titleLabel?.text = "Create A New Have"
            descriptionTextLabel.text = "Please enter a detailed description"
        default:
            whereTextLabel.text = "Where Do You Need It?"
            createNewNeedHaveButton.titleLabel?.text = "Create A New Need"
            descriptionTextLabel.text = "Or enter a description and create"
        }
    }

    @IBAction func createNeedHaveTouched(_ sender: Any) {
        switch currentNeedHaveSelectedSegmentIndex {
        case 1:
            storeHaveToDatabase()
        default:
            storeNeedToDatabase()
        }
    }

    // MARK: - NeedSelectionDelegate
    func didSelect(_ need: NeedType) {
        categoriesPopOver.isHidden = true
        categoryTextField.text = need.rawValue.capitalized
        currentNeed.type = need
        dismissTapGesture.isEnabled = false
        view.layoutIfNeeded()
    }

     // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "needsPO":
            let needsTVC = segue.destination as! NeedsTVC
            needsTVC.delegate = self
        case "toCollection":
            guard let s = sender as? [NeedsBase.NeedItem] else { fatalError() }
            guard let c = currentCity, let st = currentState else { fatalError() }
            let vc = segue.destination as! NeedsSearchDisplayVC
            vc.needs = s
            let (category, city, state): (String, String, String) = (currentNeed.type!.rawValue, c, st)
            vc.uiTuple = (category, city, state)
        default:
            print("Different segue")
        }
    }

    @IBAction func seeMatchingNeeds(_ sender: Any) {
        guard let c = currentCity, let s = currentState else {
            showOkayAlert(title: "", message: "Please complete all fields before trying to search", handler: nil)
            return
        }
        NeedsDbFetcher().fetchNeeds(city: c, state: s, currentCountry) { array in
            let newArray = array.filter { $0.category.lowercased() == self.currentNeed.type!.rawValue }
            if newArray.isEmpty {
                self.showOkayAlert(title: "", message: "There are no results for this category, in this city.  Try creating one!", handler: nil)
            } else {
                self.performSegue(withIdentifier: "toCollection", sender: newArray)
            }
        }
    }

   @IBAction func unwindToMarketplaceSearchAndCreationVC( _ segue: UIStoryboardSegue) {
    if let s = segue.source as? CityStateSearchVC, let city = s.selectedCity, let state = s.selectedState {
            whereTextField.text = city.capitalized + ", " + state.capitalized
            saveFor(s.saveType)
            currentCity = city.capitalized
            currentState = state.capitalized
            UserDefaults.standard.setValue(currentCity, forKeyPath: "currentCity")
            UserDefaults.standard.setValue(currentState, forKeyPath: "currentState")
        }
    }

    func saveFor(_ type: SaveType) {
        // store values
    }

    private func storeNeedToDatabase() {
        // if need-type nor location is not selected, display an error message
        guard let user = Auth.auth().currentUser else { print("ERROR!!!!"); return } // TODO: proper error message / handling here.
        guard let c = currentCity, let s = currentState else {
            showOkayAlert(title: "", message: "Please complete all fields before trying to create a Need", handler: nil)
            return
        }

        let locData = NeedsDbWriter.LocationInfo(city: c, state: s, country: currentCountry, address: nil, geoLocation: nil)
        let need = NeedsDbWriter.NeedItem(category: currentNeed.type?.rawValue.capitalized ?? "miscellany",
                                          description: "",
                                          validUntil: Int(Date().timeIntervalSince1970) + 7*24*60*60, //valid until next 7 days
                                          owner: user.uid,
                                          locationInfo: locData)

        let needsWriter = NeedsDbWriter()       // TODO: Decide if this needs to be stored in singleton

        needsWriter.addNeed(need, completion: { error in
            if error == nil {
                print("Need added!")
            } else {
                print("Error writing a need: \(error!)")
            }
        })
    }

    private func storeHaveToDatabase() {
        // if need-type nor location is not selected, display an error message
        guard let user = Auth.auth().currentUser else { print("ERROR!!!!"); return } // TODO: proper error message / handling here.
        guard let c = currentCity, let s = currentState else {
            showOkayAlert(title: "", message: "Please complete all fields before trying to search", handler: nil)
            return
        }

        let locData = HavesDbWriter.LocationInfo(city: c, state: s, country: currentCountry, address: nil, geoLocation: nil)
        let have = HavesDbWriter.HaveItem(category: currentNeed.type?.rawValue.capitalized ?? "miscellany",
                                          description: "",
                                          validUntil: Int(Date().timeIntervalSince1970) + 7*24*60*60, //valid until next 7 days
                                          owner: user.uid,
                                          locationInfo: locData)

        let havesWriter = HavesDbWriter()       // TODO: Decide if this needs to be stored in singleton

        havesWriter.addHave(have, completion: { error in
            if error == nil {
                print("Have added!")
            } else {
                print("Error writing a need: \(error!)")
            }
        })
    }

}

extension MarketplaceSearchAndCreationVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == categoryTextField {
            categoriesPopOver.isHidden = false
            textField.resignFirstResponder()
            dismissTapGesture.isEnabled = true
            view.layoutIfNeeded()
        }
    }
}

protocol NeedSelectionDelegate {
    func didSelect(_ need: NeedType)
}

class NeedsTVC: UITableViewController {
    var delegate: NeedSelectionDelegate?
    let needs = NeedType.allCases

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelect(needs[indexPath.row])
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return needs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = needs[indexPath.row].rawValue.capitalized
        return cell
    }
}

extension MarketplaceSearchAndCreationVC: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        dismissTapGesture.isEnabled = true
    }
}
