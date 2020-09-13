//
//  AddANeedVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 8/9/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import Firebase
import Toast_Swift

class MarketplaceSearchAndCreationVC: UIViewController, NeedSelectionDelegate {

     // MARK: - Outlets
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var categoriesPopOver: UIView!
    @IBOutlet weak var whereTextLabel: UILabel!
    @IBOutlet weak var whereTextField: UITextField!
    @IBOutlet weak var buttonsAndDescriptionView: UIView!
    
    @IBOutlet weak var headlineTextField: DesignableTextField!
    @IBOutlet weak var descriptionTextView: DesignableTextView!
    @IBOutlet var dismissTapGesture: UITapGestureRecognizer!
    @IBOutlet weak var createNewNeedHaveButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!

     // MARK: - Variables
    let currentNeed = Need()
    let currentHave = Have()
    var currentNeedHaveSelectedSegmentIndex = 0
    
    // Testing something out here
    var currentPurpose: Purpose {
        get {
            return currentNeedHaveSelectedSegmentIndex == 0 ? currentNeed : currentHave
        }
    }

    override func getKeyElements() -> [String] {
        return ["Category selection:", "Location Selection:", "Overall Functionality:"]
    }

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        //dismissTapGesture.isEnabled = false
        setCurrents()

        // Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
           super.viewDidAppear(animated)
           view.endEditing(true)
       }

     // MARK: - Keyboard Notifications
    @objc func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo!
        var keyboardFrame: CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)

        var contentInset: UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 20
        scrollView.contentInset = contentInset
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInset: UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }

     // MARK: - Utility Functions
    /// This will add to and pull from user defaults, for purposes of app operation.  It is simply a reference to the last-used location.
    /// Saved locations for selection are saved in the keychain, using the Saves.shared object
    func setCurrents() {
        let purpose = currentPurpose
        purpose.setLocation(fromDefaults: true)
        if purpose.isLocationValid() {
            whereTextField.text = purpose.getLocation().city + ", " + purpose.getLocation().state
        }
        /// Country is USA by default
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
        whereTextLabel.text = currentNeedHaveSelectedSegmentIndex == 0 ? "Where Do You Need It?" : "Where Do You Have It?"
        createNewNeedHaveButton.titleLabel?.text = currentNeedHaveSelectedSegmentIndex == 0 ? "Create a New Need" : "Create a New Have"
        setCurrents()
    }

    @IBAction func createNeedHaveTouched(_ sender: Any) {
        if checkPreconditionsAndAlert(light: false) {
            switch currentNeedHaveSelectedSegmentIndex {
                   case 1:
                       storeHaveToDatabase()
                   default:
                       storeNeedToDatabase()
                   }
        }
    }

    @IBAction func seeMatchingNeeds(_ sender: Any) {
        fetchMatchingNeeds()
    }

    @IBAction func seeMatchingHaves(_ sender: Any) {
        fetchMatchingHaves()
    }

    // MARK: - NeedSelectionDelegate
    func didSelect(_ need: NeedType) {
        categoriesPopOver.isHidden = true
        categoryTextField.text = need.rawValue.capitalized
        currentPurpose.setCategory(need)
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
            if !currentPurpose.isLocationValid() { fatalError() }
            let vc = segue.destination as! NeedsSearchDisplayVC
            vc.needs = s
            vc.currentUserNeed = currentNeed
        default:
            print("Different segue")
        }
    }

   @IBAction func unwindToMarketplaceSearchAndCreationVC( _ segue: UIStoryboardSegue) {
        if let s = segue.source as? CityStateSearchVC, let city = s.selectedCity, let state = s.selectedState {
            whereTextField.text = city.capitalized + ", " + state.capitalized
            currentPurpose.setLocation(fromDefaults: false, city: city, state: state)
            saveFor(s.saveType)
        }
    }

     // MARK: - Save Functions
    func saveFor(_ type: SaveType) {
        // store values
        switch type {
        case .home:
            Saves.shared.home = currentPurpose.getLocation()
            Saves.shared.saveSaves()
        case .alternate:
            if !Saves.shared.alternates.contains(where: { $0 == currentPurpose.getLocation() }) {
                Saves.shared.alternates.append(currentPurpose.getLocation())
                Saves.shared.saveSaves()
            }
        case .none:
            print("No Save Is Not Complete!!!!!")
        }
    }

    private func checkPreconditionsAndAlert(light: Bool) -> Bool {
        if !currentPurpose.areAllRequiredFieldsFilled(light: light) {
            showOkayAlert(title: "", message: "Please complete all fields before trying to search", handler: nil)
            return false
        }
        return true
    }

    private func fetchMatchingNeeds() {
        guard checkPreconditionsAndAlert(light: true) == true else { return }

        NeedsDbFetcher().fetchNeeds(city: currentNeed.city, state: currentNeed.state, currentNeed.country) { array in
            let newArray = array.filter { $0.category.lowercased() == self.currentNeed.type!.rawValue }
            if newArray.isEmpty {
                self.showOkayAlert(title: "", message: "There are no results for this category, in this city.  Try creating one!", handler: nil)
            } else {
                self.performSegue(withIdentifier: "toCollection", sender: newArray)
            }
        }
    }

    private func fetchMatchingHaves() {
        guard checkPreconditionsAndAlert(light: true) == true else { return }
        let type = self.currentNeed.type!.rawValue.capitalized

        HavesDbFetcher().fetchHaves(matching: [type], currentNeed.city, currentNeed.state, currentNeed.country) { array in
            if array.isEmpty {
                self.showOkayAlert(title: "", message: "There are no results for this category, in this city.  Try creating one!", handler: nil)
            } else {
                //self.performSegue(withIdentifier: "toCollection", sender: array)
                self.showOkayAlert(title: "", message: "Arthur will implement Matching Haves view!", handler: nil)
            }
        }
    }

    private func storeNeedToDatabase() {
        // if need-type nor location is not selected, display an error message
        guard let user = Auth.auth().currentUser else { print("ERROR!!!!"); return } // TODO: proper error message / handling here.
        if currentNeed.city.isEmpty || currentNeed.state.isEmpty || currentNeed.type == nil {
            showOkayAlert(title: "", message: "Please complete all fields before trying to create a Need", handler: nil)
            return
        }

        let locData = NeedsDbWriter.LocationInfo(city: currentNeed.city, state: currentNeed.state, country: currentNeed.country, address: nil, geoLocation: nil)
        let need = NeedsDbWriter.NeedItem(category: currentNeed.type?.rawValue ?? "miscellany",
                                          description: descriptionTextView.text.trimmingCharacters(in: [" "]),
                                          validUntil: Int(Date().timeIntervalSince1970) + 7*24*60*60, //valid until next 7 days
                                          owner: UserDefaults.standard.string(forKey: "userHandle") ?? "Anonymous",
                                          createdBy: user.uid,
                                          locationInfo: locData)

        let needsWriter = NeedsDbWriter()       // TODO: Decide if this needs to be stored in singleton

        needsWriter.addNeed(need, completion: { error in
            if error == nil {
                self.view.makeToast("a Need created successfully!", duration: 2.0, position: .center)
            } else {
                self.showOkayAlert(title: "", message: "Error while adding a Need. Error: \(error!.localizedDescription)", handler: nil)
            }
        })
    }

    private func storeHaveToDatabase() {
        // if need-type nor location is not selected, display an error message
        guard let user = Auth.auth().currentUser else { print("ERROR!!!!"); return } // TODO: proper error message / handling here.


        if !checkPreconditionsAndAlert(light: false) {
            showOkayAlert(title: "", message: "Please complete all fields before trying to create a Have", handler: nil)
            return
        }
        
        guard let n = currentPurpose.getCategory() else { fatalError() }
        let loc = currentPurpose.getLocation()
        let locData = HavesDbWriter.LocationInfo(city: loc.city, state: loc.state, country: loc.country, address: nil, geoLocation: nil)
        let have = HavesDbWriter.HaveItem(category: n.rawValue.capitalized,
                                          description: descriptionTextView.text.trimmingCharacters(in: [" "]),
                                          validUntil: Int(Date().timeIntervalSince1970) + 7*24*60*60, //valid until next 7 days
                                          owner: UserDefaults.standard.string(forKey: "userHandle") ?? "Anonymous",
                                          createdBy: user.uid,
                                          locationInfo: locData)

        let havesWriter = HavesDbWriter()       // TODO: Decide if this needs to be stored in singleton

        havesWriter.addHave(have, completion: { error in
            if error == nil {
                self.view.makeToast("a Have created successfully!", duration: 2.0, position: .center)
                self.descriptionTextView.text = ""
            } else {
                self.showOkayAlert(title: "", message: "Error while adding a Have. Error: \(error!.localizedDescription)", handler: nil)
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
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == headlineTextField {
            currentPurpose.setHeadline(headlineTextField.text, description: descriptionTextView.text)
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
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == descriptionTextView {
            currentPurpose.setHeadline(headlineTextField.text, description: descriptionTextView.text)
        }
    }
}
