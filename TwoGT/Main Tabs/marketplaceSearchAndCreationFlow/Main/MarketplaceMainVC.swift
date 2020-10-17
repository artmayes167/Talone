//
//  MarketplaceMainVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 10/16/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import Firebase

class MarketplaceMainVC: UIViewController {
    
    @IBOutlet weak var categoriesPopOver: UIView!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var needHaveTabController: NeedHaveTabControllerView!
    @IBOutlet weak var whereTextField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    var category: NeedType = .any
    var loc: CityStateSearchVC.Loc?
    
    private let model = MarketplaceMainModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
        setInitialValues()
    }
    
    private func setInitialValues() {
        if let loc = UserDefaults.standard.dictionary(forKey: DefaultsKeys.lastUsedLocation.rawValue) as? [String: String] {
            guard let city = loc[DefaultsSavedLocationKeys.city.rawValue], let state = loc[DefaultsSavedLocationKeys.state.rawValue] else { return }
            let newLoc = CityStateSearchVC.Loc()
            newLoc.city = city
            newLoc.state = state
            DispatchQueue.main.async {
                self.whereTextField.text = newLoc.displayName()
            }
            self.loc = newLoc
            model.configure(for: self)
        }
    }
    
    @IBAction func createANeed() {
        showOkayAlert(title: "Greetings, Tester!", message: "This hasn't been rewired yet, so cool your jets.", handler: nil)
    }
    
    @IBAction func createAHave() {
        showOkayAlert(title: "Greetings, Tester!", message: "This hasn't been rewired yet, so cool your jets.", handler: nil)
    }
    
    @IBAction func chooseCategory(_ sender: UIButton) {
        categoriesPopOver.isHidden = !categoriesPopOver.isHidden
        view.layoutIfNeeded()
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "needsPO":
            let needsTVC = segue.destination as! NeedTypeTVC
            needsTVC.delegate = self
        case "toDetails":
            guard let vc = segue.destination as? ItemDetailsVC else { fatalError() }
            if let n = sender as? NeedsBase.NeedItem {
                vc.configure(needItem: n, haveItem: nil)
            } else if let h = sender as? HavesBase.HaveItem {
                vc.configure(needItem: nil, haveItem: h)
            }
        default:
            print("toSearchLocation")
        }
    }
    
    @IBAction func unwindToMarketplaceSearchAndCreationVC( _ segue: UIStoryboardSegue) {
         if let s = segue.source as? CityStateSearchVC {
            whereTextField.text = s.loc.displayName()
            let dict = ["city": s.loc.city, "state": s.loc.state]
            UserDefaults.standard.setValue(dict, forKey: DefaultsKeys.lastUsedLocation.rawValue)
            loc = s.loc
            model.configure(for: self)
         }
     }
 // MARK: - UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == whereTextField {
            textField.resignFirstResponder()
            performSegue(withIdentifier: "toSearchLocation", sender: nil)
        }
    }
}

// MARK: - NeedSelectionDelegate
extension MarketplaceMainVC: NeedSelectionDelegate {
    func didSelect(_ need: NeedType) {
        categoriesLabel.text = need.rawValue.capitalized
        categoriesPopOver.isHidden = true
        category = need
        model.configure(for: self)
        view.layoutIfNeeded()
    }
}

extension MarketplaceMainVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.relevantCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! MarketplaceCell
        model.populateCell(cell: cell, row: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        model.selectedCell(at: indexPath.row, controller: self)
    }
}
 
 // MARK: - MarketplaceCell configuration
extension MarketplaceRepThemeManager {
    func configure(_ cell: MarketplaceCell, rating: ContactRating?) {
        guard let r = rating else {
            setTheme(cell: cell, color: colorFor(.justSo))
            return
        }
        let bad = Float(r.bad)
        let justSo = Float(r.justSo)
        let good = Float(r.good)
        
        let denominator = bad + justSo + good
        if denominator == 0.0 {
            setTheme(cell: cell, color: colorFor(.justSo))
        }
        
        let justSoCount = Float(justSo) * 0.5
        let count = (good + justSoCount) / denominator
        setTheme(cell: cell, color: themeFor(count))
    }
    
    private func setTheme(cell: MarketplaceCell, color: UIColor) {
        cell.bottomView.backgroundColor = color
        cell.leftView.backgroundColor = color
        cell.topView.borderColor = color
        cell.categoryImageView.backgroundColor = color
    }
    
}

class MarketplaceCell: UITableViewCell {
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var categoryImageView: UIImageView!
    
    @IBOutlet weak var letterLabel: UILabel!
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var watchersLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    let manager = MarketplaceRepThemeManager()
    
    func configure(rating: ContactRating?, needItem: NeedsBase.NeedItem) {
        letterLabel.text = "N"
        manager.configure(self, rating: rating)
        headlineLabel.text = needItem.headline
        handleLabel.text = needItem.owner
        dateLabel.text = needItem.createdAt?.dateValue().stringFromDate()
        watchersLabel.text = ""
    }
    
    func configure(rating: ContactRating?, haveItem: HavesBase.HaveItem) {
        letterLabel.text = "H"
        manager.configure(self, rating: rating)
        headlineLabel.text = haveItem.headline
        handleLabel.text = haveItem.owner
        dateLabel.text = haveItem.createdAt?.dateValue().stringFromDate()
        watchersLabel.text = "no watchers yet"
        if let count = haveItem.needs?.count {
            if count == 0 { return }
            if count == 1 {
                watchersLabel.text = "1 watcher"
                return
            } else {
                watchersLabel.text = String(count) + " watchers"
            }
        }
    }
}
