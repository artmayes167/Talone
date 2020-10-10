//
//  WarehouseMainVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 10/7/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit

class WarehouseMainVC: UIViewController {
    
    @IBOutlet weak var myHavesContainer: UIView!
    @IBOutlet weak var myNeedsContainer: UIView!
    
    @IBOutlet weak var myHavesTrailing: NSLayoutConstraint!
    @IBOutlet weak var myNeedsLeading: NSLayoutConstraint!
    
    @IBOutlet weak var havesHeaderImageView: UIImageView!
    @IBOutlet weak var needsHeaderImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func animateInHaves() {
        let start = myHavesTrailing.constant
        let width = UIScreen.main.bounds.width
        myHavesTrailing.constant = -1*width
        view.layoutIfNeeded()
        
        view.bringSubviewToFront(myHavesContainer)
        myHavesTrailing.constant = start
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func animateInNeeds() {
        let start = myNeedsLeading.constant
        myNeedsLeading.constant = UIScreen.main.bounds.width
        view.layoutIfNeeded()
        
        view.bringSubviewToFront(myNeedsContainer)
        myNeedsLeading.constant = start
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    
    @IBAction func switchOutViews(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            animateInHaves()
            havesHeaderImageView.tintColor = sender.selectedSegmentTintColor
            needsHeaderImageView.tintColor = sender.backgroundColor
        case 1:
            animateInNeeds()
            havesHeaderImageView.tintColor = sender.backgroundColor
            needsHeaderImageView.tintColor = sender.selectedSegmentTintColor
        default:
            print("selected an impossible index.")
        }
    }
    
    var myHavesDisplay: MyHavesSearchDisplayVC?
    var myNeedsDisplay: MyNeedsSearchDisplayVC?

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMyHaves" {
            if let vc = segue.destination as? MyHavesSearchDisplayVC {
                myHavesDisplay = vc
            }
        } else if segue.identifier == "toMyHaves" {
            if let vc = segue.destination as? MyNeedsSearchDisplayVC {
                myNeedsDisplay = vc
            }
        }
    }

    @IBAction func unwindToWarehouse( _ segue: UIStoryboardSegue) {
        myHavesDisplay?.getHaves()
        myNeedsDisplay?.getNeeds()
    }
}