//
//  BaseSwipeVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/8/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit

class BaseSwipeVC: UIViewController {

    var baseTabBar: UITabBarController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func showFeedbackPage(_ sender: Any) {
        let vc = baseTabBar?.selectedViewController?.restorationIdentifier ?? "No identifier available"
        performSegue(withIdentifier: "toFeedback", sender: vc)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toBaseTabBar" {
            baseTabBar = segue.destination as? UITabBarController
        } else if segue.identifier == "toFeedback" {
            if let vc = segue.destination as? FeedbackVC, let title = sender as? String {
                vc.topViewControllerIdentifier = title
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
