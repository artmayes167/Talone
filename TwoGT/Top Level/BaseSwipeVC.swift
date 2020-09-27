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
    
//    @IBAction func showFeedbackPage(_ sender: Any) {
//        guard let vc = baseTabBar?.selectedViewController else { fatalError() }
//        let identifier = vc.restorationIdentifier ?? "No identifier available"
//        let keyElements = vc.getKeyElements()
//        let elements = ViewControllerElements()
//        elements.identifier = identifier
//        elements.elements = keyElements
//        performSegue(withIdentifier: "toFeedback", sender: elements)
//    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toBaseTabBar" {
            baseTabBar = segue.destination as? UITabBarController
        } else if segue.identifier == "toFeedback" {
            if let vc = segue.destination as? FeedbackVC {
                guard let vc2 = baseTabBar?.selectedViewController else { fatalError() }
                let identifier = vc2.restorationIdentifier ?? "No identifier available"
                let keyElements = vc2.getKeyElements()
                let elements = ViewControllerElements()
                elements.identifier = identifier
                elements.elements = keyElements
                vc.elements = elements
            }
        }
    }

    @IBAction func unwindToMainFlow( _ segue: UIStoryboardSegue) { }
}

class CardsBaseSwipeVC: BaseSwipeVC {
    @IBAction func unwindToCardMainFlow( _ segue: UIStoryboardSegue) { }
    
    @IBAction func exitCardsFlow(_ sender: Any) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        DispatchQueue.main.async() {
            appDelegate.window = UIWindow(frame: UIScreen.main.bounds)
            let mainStoryboard = UIStoryboard(name: "NoHome", bundle: nil)
            let mainVC = mainStoryboard.instantiateViewController(withIdentifier: "Main App VC") as! BaseSwipeVC

            appDelegate.window?.rootViewController = mainVC
            appDelegate.window?.makeKeyAndVisible()
        }
    }
    
}
