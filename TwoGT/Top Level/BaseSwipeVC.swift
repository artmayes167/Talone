//
//  BaseSwipeVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/8/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit

class ViewControllerElements {
       var identifier: String?
       var elements: [String]?
   }

class BaseSwipeVC: UIViewController {

    var baseTabBar: UITabBarController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func showFeedbackPage(_ sender: Any) {
        guard let vc = baseTabBar?.selectedViewController else { fatalError() }
        let identifier = vc.restorationIdentifier ?? "No identifier available"
        let keyElements = vc.getKeyElements()
        let elements = ViewControllerElements()
        elements.identifier = identifier
        elements.elements = keyElements
        performSegue(withIdentifier: "toFeedback", sender: elements)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toBaseTabBar" {
            baseTabBar = segue.destination as? UITabBarController
        } else if segue.identifier == "toFeedback" {
            if let vc = segue.destination as? FeedbackVC, let e = sender as? ViewControllerElements {
                vc.elements = e
            }
        }
    }
    

    @IBAction func unwindToMainFlow( _ segue: UIStoryboardSegue) {
    
    }
}

class CardsBaseSwipeVC: UIViewController {
    @IBAction func unwindToCardMainFlow( _ segue: UIStoryboardSegue) {
    
    }
}
