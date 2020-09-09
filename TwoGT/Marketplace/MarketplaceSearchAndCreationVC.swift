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
    @IBOutlet weak var whereTextField: UITextField!
    @IBOutlet weak var buttonsAndDescriptionView: UIView!
    @IBOutlet weak var descriptionTextView: DesignableTextView!
    @IBOutlet var dismissTapGesture: UITapGestureRecognizer!
    
    var currentNeed = Need()
    var currentCity = ""
    var currentState = ""
    var currentCountry = "USA"
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //dismissTapGesture.isEnabled = false
        
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
        
    }
    
    @IBAction func createNeedTouched(_ sender: Any) {
        storeNeedToDatabase()
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
        default:
            print("Different segue")
        }
    }
    
   @IBAction func unwindToMarketplaceSearchAndCreationVC( _ segue: UIStoryboardSegue) {
    if let s = segue.source as? CityStateSearchVC, let city = s.selectedCity, let state = s.selectedState {
            whereTextField.text = city.capitalized + ", " + state.capitalized
            saveFor(s.saveType)
            currentCity = city.capitalized
            currentState = state.capitalized
        }
    }
    
    func saveFor(_ type: SaveType) {
        // store values
    }
    
    private func storeNeedToDatabase() {
        // if need-type nor location is not selected, display an error message
        guard let user = Auth.auth().currentUser else { print("ERROR!!!!"); return } // TODO: proper error message / handling here.

        let locData = NeedsDbWriter.LocationInfo(city: currentCity, state: currentState, country: currentCountry, address: nil, geoLocation: nil)
        let need = NeedsDbWriter.NeedItem(category: currentNeed.type?.rawValue ?? "miscellany",
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
