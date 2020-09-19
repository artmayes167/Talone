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
import CoreData

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
    var currentNeedHaveSelectedSegmentIndex = 0
    var creationManager: PurposeCreationManager? {
        didSet {
            creationManager?.setCreationType(CurrentCreationType(rawValue: currentNeedHaveSelectedSegmentIndex )!) 
        }
    }

    override func getKeyElements() -> [String] {
        return ["Category selection:", "Location Selection:", "Overall Functionality:"]
    }

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        //dismissTapGesture.isEnabled = false
        setUIForCurrents()

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
        let contentInset: UIEdgeInsets = UIEdgeInsets()
        scrollView.contentInset = contentInset
    }

     // MARK: - Utility Functions
    /// This will add to and pull from user defaults, for purposes of app operation.  It is simply a reference to the last-used location.
    /// Saved locations for selection are saved in the keychain, using the Saves.shared object
    func setUIForCurrents() {
        creationManager?.setCreationType(CurrentCreationType(rawValue: currentNeedHaveSelectedSegmentIndex) ?? .unknown)
        if let loc = creationManager?.getLocationOrNil() {
            whereTextField.text = loc.displayName()
        }
        // Get last saved location from defaults?
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
        setUIForCurrents() // sets needType, and populates location label
    }

    @IBAction func createNeedHaveTouched(_ sender: Any) {
        guard let c = creationManager else { fatalError() }
        
        switch currentNeedHaveSelectedSegmentIndex {
               case 1:
                let haveItem = createHaveItem()
                haveItem.headline = headlineTextField.text
                haveItem.desc = descriptionTextView.text
                c.setHaveItem(item: haveItem)
                if checkPreconditionsAndAlert(light: false) { storeHaveToDatabase() }
               default:
                let needItem = createNeedItem()
                needItem.headline = headlineTextField.text
                needItem.desc = descriptionTextView.text
                c.setNeedItem(item: needItem)
                if checkPreconditionsAndAlert(light: false) { storeNeedToDatabase() }
               }
    }
    
    private func createNeedItem() -> NeedItem {
        /// create new needs
        guard let c = creationManager, let loc = c.getLocationOrNil(), let city = loc.city, let state = loc.state, let country = loc.country else { fatalError() }
        let locData = NeedsDbWriter.LocationInfo(city: city, state: state, country: country, address: nil, geoLocation: nil)
        let cat = c.getCategory().databaseValue()
        var emailString: String = "artmayes167@gmail.com"
        if let emails = AppDelegate.user().emails {
            if let primaryEmail: Email = emails.first(where: {
                if let e = ($0 as? Email) {
                    return e.name == "primary"
                }
                return false
            }) as? Email {
                if let pEmail = primaryEmail.emailString {
                    emailString = pEmail
                }
            }
        }
        
        let need = NeedsDbWriter.NeedItem(category: cat, description: String(format: "\(city), \(state), \(cat)"), validUntil: 4124045393, owner: AppDelegate.user().handle ?? "AnonymousUser", createdBy: emailString, locationInfo: locData)
        let newNeed = NeedItem.createNeedItem(item: need)
        return newNeed
    }
    
    private func createHaveItem() -> HaveItem {
        /// create new needs
        guard let c = creationManager, let loc = c.getLocationOrNil(), let city = loc.city, let state = loc.state, let country = loc.country else { fatalError() }
        let locData = HavesDbWriter.LocationInfo(city: city, state: state, country: country, address: nil, geoLocation: nil)
        let cat = c.getCategory().databaseValue()
        let primaryEmail: Email = AppDelegate.user().emails?.first(where: { ($0 as! Email).name == "primary"} ) as! Email
        let have = HavesDbWriter.HaveItem(category: cat, description: String(format: "\(city), \(state), \(cat)"), validUntil: 4124045393, owner: AppDelegate.user().handle ?? "AnonymousUser", createdBy: primaryEmail.emailString ?? "artmayes167@gmail.com", locationInfo: locData)
        let newHave = HaveItem.createHaveItem(item: have)
        return newHave
    }

    @IBAction func seeMatchingNeeds(_ sender: Any) {
        fetchMatchingNeeds()
    }

    @IBAction func seeMatchingHaves(_ sender: Any) {
        fetchMatchingHaves()
    }

    // MARK: - NeedSelectionDelegate
    func didSelect(_ need: NeedType) {
        categoryTextField.text = need.rawValue.capitalized
        categoriesPopOver.isHidden = true
        
        if let c = creationManager {
           c.setCategory(need)
        } else {
            creationManager = PurposeCreationManager(type: need, city: "", state: "")
        }
        
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
            guard let _ = creationManager?.getLocationOrNil() else { fatalError() }
            let vc = segue.destination as! NeedsSearchDisplayVC
            vc.needs = s
            vc.creationManager = creationManager
        case "toHavesCollection":
            guard let h = sender as? [HavesBase.HaveItem] else { fatalError() }
            guard let _ = creationManager?.getLocationOrNil() else { fatalError() }
            let vc = segue.destination as! HavesSearchDisplayVC
            vc.haves = h
            vc.creationManager = creationManager
        default:
            print("Different segue")
        }
    }

   @IBAction func unwindToMarketplaceSearchAndCreationVC( _ segue: UIStoryboardSegue) {
    
        if let s = segue.source as? CityStateSearchVC {
            
            let loc = s.selectedLocation
            guard let city = loc["city"], let state = loc["state"] else { fatalError() }
            if let c = creationManager {
                c.setLocation(city: city, state: state, country: loc["country"] ?? "USA")
            } else {
                var type: NeedType = .none
                if let t = categoryTextField.text?.lowercased() {
                    type = NeedType(rawValue: t) ?? type
                }
                creationManager = PurposeCreationManager(type: type, city: city, state: state)
            }
            
            whereTextField.text = creationManager!.getLocationOrNil()?.displayName()
            // TODO: -
            saveFor(s.saveType)
        }
    }

     // MARK: - Save Functions
    func saveFor(_ type: SaveType) {
        guard let c = creationManager, let loc = c.getLocationOrNil() else { fatalError() }
        if !(type == .none) {
            let user = AppDelegate.user()
            // Use core data
            guard let city = loc.city, let state = loc.state, let country = loc.country else { fatalError() }
            let s: SearchLocation = SearchLocation.createSearchLocation(city: city, state: state, country: country)
            s.type = ["home", "alternate"][type.rawValue]
            user.addToSearchLocations(s)
        }
    }

     // MARK: - Private Functions
    private func checkPreconditionsAndAlert(light: Bool) -> Bool {
        guard let c = creationManager else {
            showOkayAlert(title: "", message: "Please complete all fields before trying to search", handler: nil)
            return false
        }
        if !c.areAllRequiredFieldsFilled(light: light) {
            showOkayAlert(title: "", message: "Please complete all fields before trying to search", handler: nil)
            return false
        }
        return true
    }

    private func fetchMatchingNeeds() {
        guard let c = creationManager, let loc = c.getLocationOrNil(), let city = loc.city, let state = loc.state else { fatalError() }
        
        NeedsDbFetcher().fetchNeeds(city: city, state: state, loc.country) { array in
            let newArray = array.filter { $0.category.lowercased() == c.getCategory().rawValue }
            if newArray.isEmpty {
                self.showOkayAlert(title: "", message: "There are no results for this category, in this city.  Try creating one!", handler: nil)
            } else {
                self.performSegue(withIdentifier: "toNeedsCollection", sender: newArray)
            }
        }
    }

    private func fetchMatchingHaves() {
        guard let c = creationManager, let loc = c.getLocationOrNil(), let city = loc.city, let state = loc.state, let country = loc.country else { fatalError() }

        HavesDbFetcher().fetchHaves(matching: [c.getCategory().databaseValue()], city, state, country) { array in
            if array.isEmpty {
                self.showOkayAlert(title: "", message: "There are no results for this category, in this city.  Try creating one!", handler: nil)
            } else {
                self.performSegue(withIdentifier: "toHavesCollection", sender: array)
                //self.showOkayAlert(title: "", message: "Arthur will implement Matching Haves view!", handler: nil)
            }
        }
    }

    /// Call `checkPreconditionsAndAlert(light:)` first, to ensure proper conditions are met
    private func storeNeedToDatabase() {
        guard let c = creationManager, let loc = c.getLocationOrNil()?.locationInfo() else { fatalError()
        }
        
        // if need-type nor location is not selected, display an error message
        guard let user = Auth.auth().currentUser else { print("ERROR!!!!"); return } // TODO: proper error message / handling here.
        
        let cat = c.getCategory()
        let need = NeedsDbWriter.NeedItem(category: cat.databaseValue(),
                                          description: c.getDescription(),
                                          validUntil: Int(Date().timeIntervalSince1970) + 7*24*60*60, //valid until next 7 days
                                          owner: UserDefaults.standard.string(forKey: "userHandle") ?? "Anonymous",
                                          createdBy: user.uid,
                                          locationInfo: FirebaseGeneric.LocationInfo(locationInfo: loc))

        let needsWriter = NeedsDbWriter()       // TODO: Decide if this needs to be stored in singleton

        needsWriter.addNeed(need, completion: { error in
            if error == nil {
                self.view.makeToast("You have successfully created a Need!", duration: 2.0, position: .center) {_ in
                    // TODO: - Create unwind segue to my needs
                    //self.performSegue(withIdentifier: "bob", sender: nil)
                }
            } else {
                self.showOkayAlert(title: "", message: "Error while adding a Need. Error: \(error!.localizedDescription)", handler: nil)
            }
        })
    }

    /// Call `checkPreconditionsAndAlert(light:)` first, to ensure proper conditions are met
    private func storeHaveToDatabase() {
        guard checkPreconditionsAndAlert(light: true) == true else { return }
        guard let c = creationManager, let loc = c.getLocationOrNil()?.locationInfo else { fatalError() }
        // if need-type nor location is not selected, display an error message
        guard let user = Auth.auth().currentUser else { print("ERROR!!!!"); return } // TODO: proper error message / handling here.
        let cat = c.getCategory()
        let have = HavesDbWriter.HaveItem(category: cat.databaseValue(),
                                          description: descriptionTextView.text.trimmingCharacters(in: [" "]),
                                          validUntil: Int(Date().timeIntervalSince1970) + 7*24*60*60, //valid until next 7 days
                                          owner: UserDefaults.standard.string(forKey: "userHandle") ?? "Anonymous",
                                          createdBy: user.uid,
                                          locationInfo: FirebaseGeneric.LocationInfo(locationInfo: loc()))

        let havesWriter = HavesDbWriter()       // TODO: Decide if this needs to be stored in singleton

        havesWriter.addHave(have, completion: { error in
            if error == nil {
                self.view.makeToast("You have successfully created a Have!", duration: 2.0, position: .center)
                self.descriptionTextView.text = ""
            } else {
                self.showOkayAlert(title: "", message: "Error while adding a Have. Error: \(error!.localizedDescription)", handler: nil)
            }
        })
    }

}

 // MARK: - UITextFieldDelegate
extension MarketplaceSearchAndCreationVC {
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
            creationManager?.setHeadline(headlineTextField.text, description: descriptionTextView.text)
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

 // MARK: -
extension MarketplaceSearchAndCreationVC: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        dismissTapGesture.isEnabled = true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == descriptionTextView {
            creationManager?.setHeadline(headlineTextField.text, description: descriptionTextView.text)
        }
    }
}
