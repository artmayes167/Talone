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
    @IBOutlet weak var whereTextLabel: UILabel!
    @IBOutlet weak var whereTextField: UITextField!
    @IBOutlet weak var buttonsAndDescriptionView: UIView!
    @IBOutlet weak var seeMatchingHavesButton: DesignableButton!
    @IBOutlet weak var seeMatchingNeedsButton: DesignableButton!
    @IBOutlet weak var headlineTextField: DesignableTextField!
    @IBOutlet weak var descriptionTextView: DesignableTextView!
    @IBOutlet var dismissTapGesture: UITapGestureRecognizer!
    @IBOutlet weak var createNewNeedHaveButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!

     // MARK: - Variables
    var creationManager: PurposeCreationManager = PurposeCreationManager()
    var model: MarketplaceModel?
    
    var currentNeedHaveSelectedSegmentIndex = 0 {
        didSet {
            creationManager.setCreationType(CurrentCreationType(rawValue: currentNeedHaveSelectedSegmentIndex )!)
            let title = currentNeedHaveSelectedSegmentIndex == 0 ? "Create a New Need" : "Create a New Have"
            createNewNeedHaveButton.setTitle(title, for: .normal)
            whereTextLabel.text = currentNeedHaveSelectedSegmentIndex == 0 ? "Where Do You Need It?" : "Where Do You Have It?"
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

        // Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        if Auth.auth().currentUser?.isAnonymous ?? true {
            // SignIn Anonymously
            Auth.auth().signInAnonymously { (authResult, _) in
                guard let user = authResult?.user else { return }
                let isAnonymous = user.isAnonymous  // true
                let uid = user.uid
                print("User: isAnonymous: \(isAnonymous); uid: \(uid)")
            }
        }
        
        model = MarketplaceModel(creationManager: creationManager)
    }

    override func viewDidAppear(_ animated: Bool) {
           super.viewDidAppear(animated)
           view.endEditing(true)
            setUIForCurrents()
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
        let contentInset: UIEdgeInsets = UIEdgeInsets()
        scrollView.contentInset = contentInset
    }

     // MARK: Utility Functions
    /// This will add to and pull from user defaults, for purposes of app operation.  It is simply a reference to the last-used location.
    
    private func setInitialValues() {
        if let loc = UserDefaults.standard.dictionary(forKey: DefaultsKeys.lastUsedLocation.rawValue) as? [String: String] {
            guard let city = loc[DefaultsSavedLocationKeys.city.rawValue], let state = loc[DefaultsSavedLocationKeys.state.rawValue] else { return }
            creationManager.setLocation(city: city, state: state, country: loc[DefaultsSavedLocationKeys.country.rawValue] ?? "USA", community: loc[DefaultsSavedLocationKeys.community.rawValue] ?? "")
            DispatchQueue.main.async() {
                self.whereTextField.text = self.creationManager.getLocationOrNil()?.displayName()
            }
        }
        creationManager.setCreationType(CurrentCreationType(rawValue: currentNeedHaveSelectedSegmentIndex )!)
    }
    
    private func setUIForCurrents() {
        if let loc = creationManager.getLocationOrNil() {
            whereTextField.text = loc.displayName()
        }
        // Get last saved location from defaults?
        /// Country is USA by default
    }

     // MARK: - IBActions
    @IBAction func dismissOnTap(_ sender: Any) {
        if categoriesPopOver.isHidden == false {
            categoriesPopOver.isHidden = true
            //dismissTapGesture.isEnabled = false
        }
        view.endEditing(true)
    }

    @IBAction func selectedNeedOrHave(_ sender: UISegmentedControl) {
        // UI and CoreData elements are handled in didSet()
        currentNeedHaveSelectedSegmentIndex = sender.selectedSegmentIndex
    }
    
     // MARK: - IBActions

    @IBAction func createNeedHaveTouched(_ sender: Any) {
        let success = creationManager.setHeadline(headlineTextField.text, description: descriptionTextView.text)
        if success {
            let success2 = creationManager.checkPrimaryNavigationParameters(save: true) // also creates purpose
            if success2 {
                switch creationManager.currentCreationType() {
                case .need:
                    model?.storeNeedToDatabase(controller: self)
                case .have:
                    model?.storeHaveToDatabase(controller: self)
                default:
                    print("Got to joinThisNeed in ViewIndividualNeedVC, without setting a creation type")
                }
            }
        
        } else {
            view.makeToast("Failed to create and update a purpose in MarketplaceSearchAndCreationVC -> createNeedHaveTouched")
        }
    }
    
    @IBAction func seeMatchingNeeds(_ sender: Any) {
        let success = creationManager.checkPrimaryNavigationParameters(save: true)
        if success {
            fetchMatchingNeeds()
        } else {
            view.makeToast("Failed to create and update a purpose in MarketplaceSearchAndCreationVC -> createNeedHaveTouched")
        }
    }

    @IBAction func seeMatchingHaves(_ sender: Any) {
        let success = creationManager.checkPrimaryNavigationParameters(save: true)
        if success {
            fetchMatchingHaves()
        } else {
            view.makeToast("Failed to create and update a purpose in MarketplaceSearchAndCreationVC -> createNeedHaveTouched")
        }
    }

     
    // MARK: - NeedSelectionDelegate
    func didSelect(_ need: NeedType) {
        categoryTextField.text = need.rawValue.capitalized
        categoriesPopOver.isHidden = true

        creationManager.setCategory(need)
        setSearchButtons()
        dismissTapGesture.isEnabled = false
        view.layoutIfNeeded()
    }

     // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "needsPO":
            let needsTVC = segue.destination as! NeedsTVC
            needsTVC.delegate = self
        case "toNeedsCollection":
            guard let s = sender as? [NeedsBase.NeedItem] else { fatalError() }
            guard let _ = creationManager.getLocationOrNil() else { fatalError() }
            let vc = segue.destination as! NeedsSearchDisplayVC
            vc.needs = s
            vc.creationManager = creationManager
        case "toHavesCollection":
            guard let h = sender as? [HavesBase.HaveItem] else { fatalError() }
            guard let _ = creationManager.getLocationOrNil() else { fatalError() }
            let vc = segue.destination as! HavesSearchDisplayVC
            vc.haves = h
            vc.creationManager = creationManager
        default:
            print("Different segue")
        }
    }

    /// Unwind segue here is responsible for dealing with creating and saving the search location
   @IBAction func unwindToMarketplaceSearchAndCreationVC( _ segue: UIStoryboardSegue) {

        if let s = segue.source as? CityStateSearchVC {

            var loc = s.selectedLocation
            guard let city = loc[.city], let state = loc[.state] else { fatalError() }
            creationManager.setLocation(city: city, state: state, country: loc[.country] ?? "USA", community: loc[.community] ?? "")

            loc[.display] = creationManager.getLocationOrNil()?.displayName()
            whereTextField.text = loc[.display]
            var dict: [String: String] = [:]
            for (key, value) in loc {
                dict[key.rawValue] = value
            }
            UserDefaults.standard.setValue(dict, forKey: DefaultsKeys.lastUsedLocation.rawValue)
            setSearchButtons()
            saveFor(s.saveType)
        }
    }

     // MARK: Save Functions
    /// Used by unwind segue from state/city selector
    private func saveFor(_ type: SaveType) {
        guard let loc = creationManager.getLocationOrNil() else { fatalError() }
        if !(type == .none) {
            let user = AppDelegate.user
            // Use core data
            guard let city = loc.city, let state = loc.state, let country = loc.country else { fatalError() }
            let s: SearchLocation = SearchLocation.createSearchLocation(city: city, state: state, country: country)
            s.type = ["home", "alternate"][type.rawValue]
            user.addToSearchLocations(s)
        }
    }

     // MARK: - Private Functions

    private func fetchMatchingNeeds() {
        guard let loc = creationManager.getLocationOrNil(), let city = loc.city, let state = loc.state else { fatalError() }
        showSpinner()
        NeedsDbFetcher().fetchNeeds(city: city, state: state, loc.country) { array in
            guard let cat = self.creationManager.getCategory()?.rawValue else { fatalError() }
            let newArray = array.filter { $0.category.lowercased() ==  cat}
            if newArray.isEmpty {
                self.showOkayAlert(title: "", message: "There are no results for this category, in this city.  Try creating one!") { (_) in
                    self.hideSpinner()
                }
            } else {
                self.performSegue(withIdentifier: "toNeedsCollection", sender: newArray)
                self.hideSpinner()
            }
        }
    }

    private func fetchMatchingHaves() {
        showSpinner()
        guard let loc = creationManager.getLocationOrNil(), let city = loc.city, let state = loc.state, let country = loc.country else { fatalError() }
        guard let v = creationManager.getCategory()?.firebaseValue() else { fatalError() }
        HavesDbFetcher().fetchHaves(matching: [v], city, state, country) { array in
            if array.isEmpty {
                self.showOkayAlert(title: "", message: "There are no results for this category, in this city.  Try creating one!") { (_) in
                    self.hideSpinner()
                }
            } else {
                self.performSegue(withIdentifier: "toHavesCollection", sender: array)
                self.hideSpinner()
            }
        }
    }
    
    private func checkSaveButton() {
        // Check cityState and category, but don't save
        var success = creationManager.checkPrimaryNavigationParameters(save: false)
        if success {
            // returns true if able to set both headline and description
            success = creationManager.setHeadline(headlineTextField.text, description: descriptionTextView.text)
            createNewNeedHaveButton.isEnabled = success
        }
    }
    
    private func setSearchButtons() {
        let success = creationManager.checkPrimaryNavigationParameters(save: false)
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
            dismissTapGesture.isEnabled = true
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
        if textView == descriptionTextView {
            return true
        }
        return false
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        dismissTapGesture.isEnabled = true
        let rect = scrollView.convert(textView.frame, from:buttonsAndDescriptionView)
        let newRect = rect //.offsetBy(dx: 0, dy: (textView.superview?.frame.origin.y)!)
        self.scrollView.scrollRectToVisible(newRect, animated: false)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == descriptionTextView {
            checkSaveButton()
        }
    }
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
        needs.removeFirst(1)
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

