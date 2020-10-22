////
////  MarketplaceSearchAndCreationVC.swift
////  TwoGT
////
////  Created by Arthur Mayes on 8/9/20.
////  Copyright © 2020 Arthur Mayes. All rights reserved.
////
//
//import UIKit
//import Firebase
//import Toast_Swift
//import CoreData
//import FirebaseFirestore
//import FirebaseFirestoreSwift
//
//enum DefaultsSavedLocationKeys: String {
//    case country, state, city, community, display
//}
//
//class MarketplaceSearchAndCreationVC: UIViewController, NeedSelectionDelegate {
//
//     // MARK: - Outlets
//    @IBOutlet weak var categoryTextField: UITextField!
//    @IBOutlet weak var categoriesPopOver: UIView!
////    @IBOutlet weak var whereTextLabel: UILabel!
//    @IBOutlet weak var whereTextField: UITextField!
//    @IBOutlet weak var buttonsAndDescriptionView: UIView!
//    @IBOutlet weak var seeMatchingHavesButton: DesignableButton!
//    @IBOutlet weak var seeMatchingNeedsButton: DesignableButton!
//    @IBOutlet weak var headlineTextField: DesignableTextField!
//    @IBOutlet weak var descriptionTextView: DesignableTextView!
//    @IBOutlet weak var createNewNeedHaveButton: UIButton!
//    @IBOutlet weak var scrollView: UIScrollView!
//
//     // MARK: - Variables
//    var creationManager: PurposeCreationManager = PurposeCreationManager()
//    var model: MarketplaceModelOld?
//
//    var currentNeedHaveSelectedSegmentIndex = 0 {
//        didSet {
//            creationManager.setCreationType(CurrentCreationType(rawValue: currentNeedHaveSelectedSegmentIndex )!)
//            let title = currentNeedHaveSelectedSegmentIndex == 0 ? "Create a New Need".taloneCased() : "Create a New Have".taloneCased()
//            createNewNeedHaveButton.setTitle(title.taloneCased(), for: .normal)
////            let whereText = currentNeedHaveSelectedSegmentIndex == 0 ? "Where Do You Need It?".taloneCased() : "Where Do You Have It?".taloneCased()
////            whereTextLabel.text = whereText.taloneCased()
//        }
//    }
//
//    override func getKeyElements() -> [String] {
//        return ["Category selection:", "Location Selection:", "Overall Functionality:"]
//    }
//
//    // MARK: - View Life Cycle
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        //dismissTapGesture.isEnabled = false
//        setInitialValues()
//
//        if Auth.auth().currentUser?.isAnonymous ?? true {
//            // SignIn Anonymously
//            Auth.auth().signInAnonymously { (authResult, _) in
//                guard let user = authResult?.user else { return }
//                let isAnonymous = user.isAnonymous  // true
//                let uid = user.uid
//                print("User: isAnonymous: \(isAnonymous); uid: \(uid)")
//            }
//        }
//        
//         // MARK: Moved this to BaseSwipeVC
////        AppDelegate.cardObserver.startObserving()
////        AppDelegate.linkedNeedsObserver.startObservingHaveChanges()
//
//        model = MarketplaceModelOld(creationManager: creationManager)
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        view.endEditing(true)
//        setUIForCurrents()
//    }
//
//     // MARK: Utility Functions
//    /// This will add to and pull from user defaults, for purposes of app operation.  It is simply a reference to the last-used location.
//
//    private func setInitialValues() {
//        creationManager.setCreationType(CurrentCreationType(rawValue: currentNeedHaveSelectedSegmentIndex)!)
//        categoryTextField.text = creationManager.getCategory()?.rawValue
//        if let loc = UserDefaults.standard.dictionary(forKey: DefaultsKeys.lastUsedLocation.rawValue) as? [String: String] {
//            guard let city = loc[DefaultsSavedLocationKeys.city.rawValue], let state = loc[DefaultsSavedLocationKeys.state.rawValue] else { return }
//            let newLoc = CityStateSearchVC.Loc()
//            newLoc.city = city
//            newLoc.state = state
//            creationManager.setLocation(newLoc)
//            DispatchQueue.main.async {
//                self.whereTextField.text = self.creationManager.getLocationOrNil()?.displayName()
//            }
//        }
//        setSearchButtons()
//        checkSaveButton()
//    }
//
//    private func setUIForCurrents() {
//        if let loc = creationManager.getLocationOrNil() {
//            whereTextField.text = loc.displayName()
//            setSearchButtons()
//            checkSaveButton()
//        }
//        // Get last saved location from defaults?
//        /// Country is USA by default
//    }
//
//     // MARK: - IBActions
//
//    @IBAction func selectedNeedOrHave(_ sender: UISegmentedControl) {
//        // UI and CoreData elements are handled in didSet()
//        currentNeedHaveSelectedSegmentIndex = sender.selectedSegmentIndex
//    }
//
//     // MARK: - IBActions
//
//    @IBAction func createNeedHaveTouched(_ sender: Any) {
//        let success = creationManager.setHeadline(headlineTextField.text, description: descriptionTextView.text)
//        if !success {
//            showOkayAlert(title: "hold on", message: String(format: "you need these three things: a headline, a description, and a category. \n\nif you added a headline and description... you can search with the 'any' category, but it doesn't make much sense to create something as vague as that. pick a different category up top."), handler: nil)
//            return
//        } else {
//            switch creationManager.currentCreationType() {
//            case .need:
//                model?.storeNeedToDatabase(controller: self)
//            case .have:
//                model?.storeHaveToDatabase(controller: self)
//            default:
//                print("Got to joinThisNeed in Marketplace, without setting a creation type")
//            }
//        }
//    }
//
//    @IBAction func seeMatchingNeeds(_ sender: Any) {
//        fetchMatchingNeeds()
//    }
//
//    @IBAction func seeMatchingHaves(_ sender: Any) {
//        fetchMatchingHaves()
//    }
//
//    // MARK: - NeedSelectionDelegate
//    func didSelect(_ need: NeedType) {
//        categoryTextField.text = need.rawValue.capitalized
//        categoriesPopOver.isHidden = true
//
//        creationManager.setCategory(need)
//        setSearchButtons()
//        checkSaveButton()
//        view.layoutIfNeeded()
//    }
//
//     // MARK: - Navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        switch segue.identifier {
//        case "needsPO":
//            let needsTVC = segue.destination as! NeedTypeTVC
//            needsTVC.delegate = self
//        case "toNeedsCollection":
//            guard let n = sender as? [NeedsBase.NeedItem] else { fatalError() }
//            guard let _ = creationManager.getLocationOrNil() else { fatalError() }
//            let vc = segue.destination as! NeedsSearchDisplayVC
//            vc.configure(needItems: n, creationManager: creationManager)
//        case "toHavesCollection":
//            guard let h = sender as? [HavesBase.HaveItem] else { fatalError() }
//            guard let _ = creationManager.getLocationOrNil() else { fatalError() }
//            let vc = segue.destination as! HavesSearchDisplayVC
//            vc.configure(haveItems: h, creationManager: creationManager)
//        default:
//            print("toSearchLocation")
//        }
//    }
//
//    /// Unwind segue here is responsible for dealing with creating and saving the search location
//   @IBAction func unwindToMarketplaceSearchAndCreationVC( _ segue: UIStoryboardSegue) {
//        if let s = segue.source as? CityStateSearchVC {
//            creationManager.setLocation(s.loc)
//            whereTextField.text = s.loc.displayName()
//            let dict = ["city": s.loc.city, "state": s.loc.state]
//            UserDefaults.standard.setValue(dict, forKey: DefaultsKeys.lastUsedLocation.rawValue)
//            setSearchButtons()
//        }
//    }
//
//     // MARK: - Private Functions
//
//    private func fetchMatchingNeeds() {
//        guard let loc = creationManager.getLocationOrNil() else { fatalError() }
//        showSpinner()
//        guard let cat = self.creationManager.getCategory()?.rawValue else { fatalError() }
//        let msg = cat.lowercased() == "any" ?
//            "There are no needs for any category, in this city." :
//            "There are no results for this category, in this city."
//
//        NeedsDbFetcher().fetchNeedsFor(category: cat, city: loc.city, state: loc.state, country: loc.country, maxCount: 20, filterOutThisUser: true) { array, error in
//            self.hideSpinner()
//
//            if error != nil { self.showOkayAlert(title: "", message: error!.localizedDescription) {_ in } }
//            if array.isEmpty {
//                self.showOkayAlert(title: "".taloneCased(), message: msg.taloneCased()) { (_) in
//                }
//            } else {
//                self.performSegue(withIdentifier: "toNeedsCollection", sender: array)
//            }
//        }
//    }
//
//    private func fetchMatchingHaves() {
//        showSpinner()
//        guard let loc = creationManager.getLocationOrNil() else { fatalError() }
//        guard let v = creationManager.getCategory()?.firebaseValue() else { fatalError() }
//
//        if v.lowercased() == "any" {
//            let msg = "There are no results for any categories in this city. If you have anything, please share"
//            HavesDbFetcher().fetchAllHaves(city: loc.city, loc.state, loc.country, maxCount: 10) { array, error in
//                handleResults(array, msg, error)
//            }
//        } else {
//            let msg = "There are no results for \(v.lowercased()), in this city. If you have anything, please share"
//            HavesDbFetcher().fetchHaves(matching: [v], loc.city, loc.state, loc.country) { array, error in
//                handleResults(array, msg, error)
//            }
//        }
//
//        func handleResults(_ array: [HavesBase.HaveItem], _ message: String, _ error: Error?) {
//            let finalArray = array.filter { $0.owner != AppDelegateHelper.user.handle }
//            if finalArray.isEmpty {
//                self.showOkayAlert(title: "".taloneCased(), message: message.taloneCased()) { (_) in
//                    self.hideSpinner()
//                }
//            } else {
//                self.performSegue(withIdentifier: "toHavesCollection", sender: finalArray)
//                self.hideSpinner()
//            }
//        }
//
//    }
//
//    private func checkSaveButton() {
//        createNewNeedHaveButton.isEnabled = true
//    }
//
//    private func setSearchButtons() {
//        let success = creationManager.getLocationOrNil() != nil ? true : false
//        seeMatchingHavesButton.isEnabled = success
//        seeMatchingNeedsButton.isEnabled = success
//    }
//}
//
// // MARK: - UITextFieldDelegate, UITextViewDelegate
//extension MarketplaceSearchAndCreationVC: UITextViewDelegate {
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        if textField == categoryTextField {
//            categoriesPopOver.isHidden = false
//            textField.resignFirstResponder()
//            view.layoutIfNeeded()
//        } else if textField == whereTextField {
//            textField.resignFirstResponder()
//            performSegue(withIdentifier: "toSearchLocation", sender: nil)
//        }
//    }
//
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        if textField == headlineTextField {
//            checkSaveButton()
//        }
//    }
//
//     // MARK: TextView
//    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
//        showTextViewHelper(textView: descriptionTextView, displayName: "description", initialText: descriptionTextView.text)
//        return false
//    }
//
//    func textViewDidEndEditing(_ textView: UITextView) {
//        print("-----------------ended editing called")
//        checkSaveButton()
//    }
//}
