//
//  EventsSearchAndCreationVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/16/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import Firebase
import Toast_Swift

class EventsSearchAndCreationVC: UIViewController, NeedSelectionDelegate {

     // MARK: - Outlets
        @IBOutlet weak var categoryTextField: UITextField!
        @IBOutlet weak var categoriesPopOver: UIView!
        @IBOutlet weak var whereTextField: UITextField!
        @IBOutlet weak var buttonsAndDescriptionView: UIView!

        @IBOutlet weak var headlineTextField: DesignableTextField!
        @IBOutlet weak var descriptionTextView: DesignableTextView!
        @IBOutlet var dismissTapGesture: UITapGestureRecognizer!
        @IBOutlet weak var createNewNeedHaveButton: UIButton!
        @IBOutlet weak var scrollView: UIScrollView!

         // MARK: - Variables
        var creationManager: PurposeCreationManager?

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
            if let loc = creationManager?.getLocationOrNil() {
                whereTextField.text = loc.displayName()
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
            setUIForCurrents() // sets needType, and populates location label
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
            
            if let c = creationManager {
               c.setCategory(need)
            } else {
                creationManager = PurposeCreationManager.init(withType: need, state: "")
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
            default:
                print("Different segue")
            }
        }

       @IBAction func unwindToEventsSearchAndCreationVC( _ segue: UIStoryboardSegue) {
        
            if let s = segue.source as? CityStateSearchVC {
                
                if creationManager == nil {
                    creationManager = PurposeCreationManager.init(locationInfo: s.selectedLocation)
                }
                
                guard let c = creationManager else { fatalError() }
                   
                c.setLocation(location: s.selectedLocation)
                
                whereTextField.text = c.getLocationOrNil()?.displayName()
                // TODO: -
                saveFor(s.saveType)
            }
        }

         // MARK: - Save Functions
        func saveFor(_ type: SaveType) {
            guard let c = creationManager, let loc = c.getLocationOrNil() else { fatalError() }
            // store values
            switch type {
            case .home:
                if let u = Saves.shared.user?.user, var searches = u.searches {
                
                    if var d = searches["home"], !d.contains(loc.displayName()) {
                        d.append(loc.displayName())
                        searches["home"] = d
                    }
                }
                Saves.saveSaves().printDescription()
                print("---------- FOR HOME")
            case .alternate:
                if let u = Saves.shared.user?.user, var searches = u.searches {
                
                    if var d = searches["alternate"], !d.contains(loc.displayName()) {
                        d.append(loc.displayName())
                        searches["alternate"] = d
                    }
                }
                Saves.saveSaves().printDescription()
                print("---------- FOR HOME")
            case .none:
                print("No Save Is Not Complete!!!!!")
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
            guard let c = creationManager, let loc = c.getLocationOrNil()?.locationInfo else { fatalError() }
            
            NeedsDbFetcher().fetchNeeds(city: loc.city, state: loc.state, loc.country) { array in
                let newArray = array.filter { $0.category.lowercased() == c.getCategory().rawValue }
                if newArray.isEmpty {
                    self.showOkayAlert(title: "", message: "There are no results for this category, in this city.  Try creating one!", handler: nil)
                } else {
                    self.performSegue(withIdentifier: "toNeedsCollection", sender: newArray)
                }
            }
        }

        private func fetchMatchingHaves() {
            guard let c = creationManager, let loc = c.getLocationOrNil()?.locationInfo else { fatalError() }

            HavesDbFetcher().fetchHaves(matching: [c.getCategory().databaseValue()], loc.city, loc.state, loc.country) { array in
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
            guard checkPreconditionsAndAlert(light: true) == true else { return }
            guard let c = creationManager, let loc = c.getLocationOrNil()?.locationInfo else { fatalError() }
            
            // if need-type nor location is not selected, display an error message
            guard let user = Auth.auth().currentUser else { print("ERROR!!!!"); return } // TODO: proper error message / handling here.
            let cat = c.getCategory()
            let need = NeedsDbWriter.NeedItem(category: cat.databaseValue(),
                                              description: descriptionTextView.text.trimmingCharacters(in: [" "]),
                                              validUntil: Int(Date().timeIntervalSince1970) + 7*24*60*60, //valid until next 7 days
                                              owner: UserDefaults.standard.string(forKey: "userHandle") ?? "Anonymous",
                                              createdBy: user.uid,
                                              locationInfo: FirebaseGeneric.LocationInfo(locationInfo: loc))

            let needsWriter = NeedsDbWriter()       // TODO: Decide if this needs to be stored in singleton

            needsWriter.addNeed(need, completion: { error in
                if error == nil {
                    self.view.makeToast("You have successfully created a Need!", duration: 2.0, position: .center)
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
                                              locationInfo: FirebaseGeneric.LocationInfo(locationInfo: loc))

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
    extension EventsSearchAndCreationVC {
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
    extension EventsSearchAndCreationVC: UITextViewDelegate {

        func textViewDidBeginEditing(_ textView: UITextView) {
            dismissTapGesture.isEnabled = true
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            if textView == descriptionTextView {
                creationManager?.setHeadline(headlineTextField.text, description: descriptionTextView.text)
            }
        }
}
