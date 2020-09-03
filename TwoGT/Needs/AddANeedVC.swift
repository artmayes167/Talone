//
//  AddANeedVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 8/9/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit

class Need {
    var type: NeedType?
    
}

class AddANeedVC: UIViewController, NeedSelectionDelegate {
    
    @IBOutlet weak var needTextField: UITextField!
    @IBOutlet weak var needsPopOver: UIView!
    @IBOutlet weak var whereTextField: UITextField!
    var currentNeed = Need()
    
    
    
    @IBOutlet var dismissTapGesture: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dismissTapGesture.isEnabled = false
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func dismissOnTap(_ sender: Any) {
        if needsPopOver.isHidden == false {
            needsPopOver.isHidden = true
            dismissTapGesture.isEnabled = false
        }
    }
    
    
    
    // MARK: - NeedSelectionDelegate
    func didSelect(_ need: NeedType) {
        needsPopOver.isHidden = true
        needTextField.text = need.rawValue.capitalized
        currentNeed.type = need
        dismissTapGesture.isEnabled = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "needsPO":
            let needsTVC = segue.destination as! NeedsTVC
            needsTVC.delegate = self
        default:
            print("Different segue")
        }
    }
    
   @IBAction func unwindToAddANeed( _ segue: UIStoryboardSegue) {
    if let s = segue.source as? CityStateSearchVC, let city = s.selectedCity, let state = s.selectedState {
            whereTextField.text = city.capitalized + ", " + state.capitalized
            saveFor(s.saveType)
        }
    }
    
    func saveFor(_ type: SaveType) {
        // store values
    }
}

extension AddANeedVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == needTextField {
            needsPopOver.isHidden = false
            textField.resignFirstResponder()
            dismissTapGesture.isEnabled = true
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
