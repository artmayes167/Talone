//
//  IntroChooseHomeVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 10/16/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import CoreData

/// This controller sets the initial search value, and first saved search location as home
class IntroChooseHomeVC: UIViewController {
    
    let popOverSegue = "toPopover"
    
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var showStateAndCityField: UIView!
    @IBOutlet weak var showCityAndButtonsField: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.setValue(State.addHome.rawValue, forKey: State.stateDefaultsKey.rawValue)
        updateUI()
    }
    
    // called by UIAdaptivePresentationControllerDelegate, routed through UIViewController parent
    override func updateUI() {
        if let t = stateLabel.text, !t.isEmpty {
            showStateAndCityField.isHidden = false
            if let te = cityLabel.text, !te.isEmpty {
                showCityAndButtonsField.isHidden = false
            }
        } else {
            showStateAndCityField.isHidden = true
            showCityAndButtonsField.isHidden = true
        }
        view.layoutIfNeeded()
    }
    
     // MARK: - Triggered Actions
    @IBAction func showStateSelector() {
        if cityLabel.text != nil {
            cityLabel.text = nil
            updateUI()
        }
        /// sender being nil  here determines that we are searching for a state
        performSegue(withIdentifier: popOverSegue, sender: nil)
    }
    
    @IBAction func showCitySelector() {
        /// sender being a string here determines that we are searching for a city
        performSegue(withIdentifier: popOverSegue, sender: stateLabel.text)
    }
    
    @IBAction func saveAndContinue() {
        guard let city = cityLabel.text, let state = stateLabel.text else { return }
        SearchLocation.createSearchLocation(city: city, state: state, country: "USA", community: "", type: "home")
        let dict = ["city": city, "state": state]
        UserDefaults.standard.setValue(dict, forKey: DefaultsKeys.lastUsedLocation.rawValue)
        performSegue(withIdentifier: "toImport", sender: nil)
    }
    
    @IBAction func resetBoard() {
        cityLabel.text = nil
        stateLabel.text = nil
        updateUI()
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == popOverSegue {
            let vc = segue.destination as! SelectorPopoverVC
            vc.presentationController?.delegate = self
            if let s = sender as? String {
                vc.configure(state: s, label: cityLabel)
            } else {
                vc.configure(state: nil, label: stateLabel)
            }
        }
    }
}
