//
//  CreateNewItemVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 10/17/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit

class CreateNewItemVC: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var categoryContainer: UIView!
    
    @IBOutlet weak var headlineTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    var model: MarketplaceModel?
    
    var loc: CityStateSearchVC.Loc?
    var category: NeedType = .any
    var need = true

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = need ? "new need" : "new have"
        locationLabel.text = loc!.displayName()
    }
    
    @IBAction func touchedChooseCategory(_ sender: UIButton) {
        categoryContainer.isHidden = !categoryContainer.isHidden
        view.layoutIfNeeded()
    }
    
    @IBAction func touchedChooseLocation(_ sender: UIButton) {
        performSegue(withIdentifier: "toSearchLocation", sender: nil)
    }
    
    @IBAction func touchedCreate(_ sender: UIButton) {
        if loc == nil || category == .any || (headlineTextField.text?.isEmpty ?? true) || (descriptionTextView.text?.isEmpty ?? true) {
            showOkayAlert(title: "hold on", message: String(format: "you need these three things: a headline, a description, and a category. \n\nif you added a headline and description... you can search with the 'any' category, but it doesn't make much sense to create something as vague as that. \n\npick a different category up top, and let us know what category you want in the feedback screen."), handler: nil)
            return
        }
        
        model = MarketplaceModel(controller: self, location: loc!, category: category)
        if need == true {
            model!.storeNeedToDatabase(controller: self)
        } else {
            model!.storeHaveToDatabase(controller: self)
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSearchLocation" {
            let vc = segue.destination as! CityStateSearchVC
            vc.unwindSegueIdentifier = .createNewItem
        } else if segue.identifier == "toNeedsPO" {
            let vc = segue.destination as! NeedTypeTVC
            vc.delegate = self
        }
    }
    
    @IBAction func unwindToCreateNewItemVC( _ segue: UIStoryboardSegue) {
         if let s = segue.source as? CityStateSearchVC {
            locationLabel.text = s.loc.displayName()
            let dict = ["city": s.loc.city, "state": s.loc.state]
            UserDefaults.standard.setValue(dict, forKey: DefaultsKeys.lastUsedLocation.rawValue)
            loc = s.loc
         }
     }
}

// MARK: - NeedSelectionDelegate
extension CreateNewItemVC: NeedSelectionDelegate {
    func didSelect(_ need: NeedType) {
        categoryLabel.text = need.rawValue
        categoryContainer.isHidden = true
        category = need
        view.layoutIfNeeded()
    }
}

extension CreateNewItemVC: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        showTextViewHelper(textView: descriptionTextView, displayName: "description", initialText: descriptionTextView.text)
        return false
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
    }
}
