//
//  MarketplaceSearchAndCreationVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 8/9/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import Firebase
import Toast_Swift
import CoreData
import FirebaseFirestore
import FirebaseFirestoreSwift

enum DefaultsSavedLocationKeys: String {
    case country, state, city, community, display
}

class MarketplaceSearchAndCreationVC: UIViewController, NeedSelectionDelegate {

     // MARK: - Outlets
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var categoriesPopOver: UIView!
//    @IBOutlet weak var whereTextLabel: UILabel!
    @IBOutlet weak var whereTextField: UITextField!
    @IBOutlet weak var buttonsAndDescriptionView: UIView!
    @IBOutlet weak var seeMatchingHavesButton: DesignableButton!
    @IBOutlet weak var seeMatchingNeedsButton: DesignableButton!
    @IBOutlet weak var headlineTextField: DesignableTextField!
    @IBOutlet weak var descriptionTextView: DesignableTextView!
    @IBOutlet weak var createNewNeedHaveButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!

     // MARK: - Variables
    var creationManager: PurposeCreationManager = PurposeCreationManager()
    var model: MarketplaceModel?

    var searchLocation: SearchLocation?

    var currentNeedHaveSelectedSegmentIndex = 0 {
        didSet {
            creationManager.setCreationType(CurrentCreationType(rawValue: currentNeedHaveSelectedSegmentIndex )!)
            let title = currentNeedHaveSelectedSegmentIndex == 0 ? "Create a New Need".taloneCased() : "Create a New Have".taloneCased()
            createNewNeedHaveButton.setTitle(title.taloneCased(), for: .normal)
//            let whereText = currentNeedHaveSelectedSegmentIndex == 0 ? "Where Do You Need It?".taloneCased() : "Where Do You Have It?".taloneCased()
//            whereTextLabel.text = whereText.taloneCased()
        }
    }

    override func getKeyElements() -> [String] {
        return ["Category selection:", "Location Selection:", "Overall Functionality:"]
    }

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        //dismissTapGesture.isEnabled = false
        setInitialValues()

        if Auth.auth().currentUser?.isAnonymous ?? true {
            // SignIn Anonymously
            Auth.auth().signInAnonymously { (authResult, _) in
                guard let user = authResult?.user else { return }
                let isAnonymous = user.isAnonymous  // true
                let uid = user.uid
                print("User: isAnonymous: \(isAnonymous); uid: \(uid)")
            }
        }

        // Start observing any Card receptions or card updates.
        // We do this late in the flow to ensure user has signed in.
        AppDelegate.cardObserver.startObserving()
        AppDelegate.linkedNeedsObserver.startObservingHaveChanges()

        model = MarketplaceModel(creationManager: creationManager)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkSaveButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.endEditing(true)
        setUIForCurrents()
    }

     // MARK: Utility Functions
    /// This will add to and pull from user defaults, for purposes of app operation.  It is simply a reference to the last-used location.

    private func setInitialValues() {
        creationManager.setCreationType(CurrentCreationType(rawValue: currentNeedHaveSelectedSegmentIndex)!)
        categoryTextField.text = creationManager.getCategory()?.rawValue
        if let loc = UserDefaults.standard.dictionary(forKey: DefaultsKeys.lastUsedLocation.rawValue) as? [String: String] {
            guard let city = loc[DefaultsSavedLocationKeys.city.rawValue], let state = loc[DefaultsSavedLocationKeys.state.rawValue] else { return }
            _ = CoreDataGod.user.sortedAddresses(clean: true)
            let locations = CoreDataGod.user.searchLocations
            guard var l = locations else {
                let newLoc = SearchLocation.createSearchLocation(city: city, state: state, type: "none")
                creationManager.setLocation(newLoc)
                searchLocation = newLoc
                DispatchQueue.main.async {
                    self.whereTextField.text = self.creationManager.getLocationOrNil()?.displayName()
                }
                setSearchButtons()
                return
            }
            l = l.filter { $0.city == city && $0.state == state }
            if !l.isEmpty {
                creationManager.setLocation(l.first!)
                searchLocation = l.first
            } else {
                let newLoc = SearchLocation.createSearchLocation(city: city, state: state, type: "none")
                creationManager.setLocation(newLoc)
                searchLocation = newLoc
            }
            DispatchQueue.main.async {
                self.whereTextField.text = self.creationManager.getLocationOrNil()?.displayName()
            }
        }
        setSearchButtons()
    }

    private func setUIForCurrents() {
        if let loc = creationManager.getLocationOrNil() {
            whereTextField.text = loc.displayName()
            setSearchButtons()
        }
        // Get last saved location from defaults?
        /// Country is USA by default
    }

     // MARK: - IBActions

    @IBAction func selectedNeedOrHave(_ sender: UISegmentedControl) {
        // UI and CoreData elements are handled in didSet()
        currentNeedHaveSelectedSegmentIndex = sender.selectedSegmentIndex
    }

     // MARK: - IBActions

    @IBAction func createNeedHaveTouched(_ sender: Any) {
        let success = creationManager.setHeadline(headlineTextField.text, description: descriptionTextView.text)
        if !success {
            showOkayAlert(title: "hold on", message: "you can search with the 'any' category, but it doesn't make much sense to create something as vague as that.  pick a different category up top.", handler: nil)
            return
        } else {
            switch creationManager.currentCreationType() {
            case .need:
                model?.storeNeedToDatabase(controller: self)
            case .have:
                model?.storeHaveToDatabase(controller: self)
            default:
                print("Got to joinThisNeed in Marketplace, without setting a creation type")
            }
        }
    }

    @IBAction func seeMatchingNeeds(_ sender: Any) {
        guard let _ = searchLocation else { return }
        fetchMatchingNeeds()
    }

    @IBAction func seeMatchingHaves(_ sender: Any) {
        guard let _ = searchLocation else { return }
        fetchMatchingHaves()
    }

    // MARK: - NeedSelectionDelegate
    func didSelect(_ need: NeedType) {
        categoryTextField.text = need.rawValue.capitalized
        categoriesPopOver.isHidden = true

        creationManager.setCategory(need)
        setSearchButtons()
        view.layoutIfNeeded()
    }

     // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "needsPO":
            let needsTVC = segue.destination as! NeedsTVC
            needsTVC.delegate = self
        case "toNeedsCollection":
            guard let n = sender as? [NeedsBase.NeedItem] else { fatalError() }
            guard let _ = creationManager.getLocationOrNil() else { fatalError() }
            let vc = segue.destination as! NeedsSearchDisplayVC
            vc.configure(needItems: n, creationManager: creationManager)
        case "toHavesCollection":
            guard let h = sender as? [HavesBase.HaveItem] else { fatalError() }
            guard let _ = creationManager.getLocationOrNil() else { fatalError() }
            let vc = segue.destination as! HavesSearchDisplayVC
            vc.configure(haveItems: h, creationManager: creationManager)
        default:
            print("Different segue")
        }
    }

    /// Unwind segue here is responsible for dealing with creating and saving the search location
   @IBAction func unwindToMarketplaceSearchAndCreationVC( _ segue: UIStoryboardSegue) {
        if let s = segue.source as? CityStateSearchVC {
            guard let loc = s.locationForSave else { fatalError() }
            searchLocation = loc
            creationManager.setLocation(loc)
            whereTextField.text = loc.displayName()
            let dict = ["city": loc.city, "state": loc.state]
            UserDefaults.standard.setValue(dict, forKey: DefaultsKeys.lastUsedLocation.rawValue)
            setSearchButtons()
            try? CoreDataGod.managedContext.save()
        }
    }

     // MARK: - Private Functions

    private func fetchMatchingNeeds() {
        guard let loc = creationManager.getLocationOrNil() else { fatalError() }
        showSpinner()
        guard let cat = self.creationManager.getCategory()?.rawValue else { fatalError() }
        let msg = cat.lowercased() == "any" ?
            "There are no needs for any category, in this city." :
            "There are no results for this category, in this city."

        NeedsDbFetcher().fetchNeedsFor(category: cat, city: loc.city, state: loc.state, country: loc.country, maxCount: 20, filterOutThisUser: true) { array in

            if array.isEmpty {
                self.showOkayAlert(title: "".taloneCased(), message: msg.taloneCased()) { (_) in
                    self.hideSpinner()
                }
            } else {
                self.performSegue(withIdentifier: "toNeedsCollection", sender: array)
                self.hideSpinner()
            }
        }
    }

    private func fetchMatchingHaves() {
        showSpinner()
        guard let loc = creationManager.getLocationOrNil() else { fatalError() }
        guard let v = creationManager.getCategory()?.firebaseValue() else { fatalError() }

        if v.lowercased() == "any" {
            let msg = "There are no results for any categories in this city. If you have anything, please share"
            HavesDbFetcher().fetchAllHaves(city: loc.city, loc.state, loc.country, maxCount: 10) { array in
                handleResults(array, msg)
            }
        } else {
            let msg = "There are no results for \(v.lowercased()), in this city. If you have anything, please share"
            HavesDbFetcher().fetchHaves(matching: [v], loc.city, loc.state, loc.country) { array in
                handleResults(array, msg)
            }
        }

        func handleResults(_ array: [HavesBase.HaveItem], _ message: String) {
            let finalArray = array.filter { $0.owner != AppDelegateHelper.user.handle }
            if finalArray.isEmpty {
                self.showOkayAlert(title: "".taloneCased(), message: message.taloneCased()) { (_) in
                    self.hideSpinner()
                }
            } else {
                self.performSegue(withIdentifier: "toHavesCollection", sender: finalArray)
                self.hideSpinner()
            }
        }

    }

    private func checkSaveButton() {
        // Check cityState and category, but don't save
        var success = creationManager.getLocationOrNil() != nil
        if success {
            // returns true if able to set both headline and description
            success = creationManager.setHeadline(headlineTextField.text, description: descriptionTextView.text)
            createNewNeedHaveButton.isEnabled = success
        }
    }

    private func setSearchButtons() {
        let success = creationManager.getLocationOrNil() != nil ? true : false
        seeMatchingHavesButton.isEnabled = success
        seeMatchingNeedsButton.isEnabled = success
    }
}

 // MARK: - UITextFieldDelegate, UITextViewDelegate
extension MarketplaceSearchAndCreationVC: UITextViewDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == categoryTextField {
            categoriesPopOver.isHidden = false
            textField.resignFirstResponder()
            view.layoutIfNeeded()
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == headlineTextField {
            checkSaveButton()
        }
    }

     // MARK: TextView
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        showTextViewHelper(textView: descriptionTextView, displayName: "description", initialText: descriptionTextView.text)
        return false
    }

    func textViewDidEndEditing(_ textView: UITextView) { }
}

 // MARK: -
protocol NeedSelectionDelegate {
    func didSelect(_ need: NeedType)
}

 // MARK: -
class NeedsTVC: UITableViewController {
    var delegate: NeedSelectionDelegate?
    var needs: [NeedType] = NeedType.allCases

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelect(needs[indexPath.row])
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return needs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SimpleSearchCell
        cell.basicLabel.text = needs[indexPath.row].rawValue.capitalized
        return cell
    }
}

class SimpleSearchCell: UITableViewCell {
    @IBOutlet weak var basicLabel: UILabel!
    @IBOutlet weak var colorBar: UIView!
}
