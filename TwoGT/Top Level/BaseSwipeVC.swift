//
//  BaseSwipeVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/8/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
/** This is the root view for the main app, and functions as a sort of `UISingleton`.
    -   replaces the navigation controller from the login/noob flow, and manages system-wide UI responses, including management of the dashboard button (the button sits in the root view, and at the top of all controllers presented in the `baseTabBar`)
    - ` baseTabBar` is embedded as a childVC, through a containerView and segue in the storyboard.  All VCs in the main flow  that are not present in the tabBar's viewControllers array are presented modally
 */
class BaseSwipeVC: UIViewController {
    /// explicit reference to manage UI events
    var baseTabBar: UITabBarController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /// Start observing any Card receptions or card updates.
        AppDelegate.cardObserver.startObserving()
        AppDelegate.linkedNeedsObserver.startObservingHaveChanges()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toBaseTabBar" {
            // embedded segue
            baseTabBar = segue.destination as? UITabBarController
            baseTabBar?.delegate = self
        } else if segue.identifier == "toFeedback" {
            /// currently unused
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

    /// gets us back to the tab bar
    @IBAction func unwindToMainFlow( _ segue: UIStoryboardSegue) { }
}

extension BaseSwipeVC: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        viewController.updateUI()
    }
}

/// unused
class CardsBaseSwipeVC: BaseSwipeVC {
    @IBAction func unwindToCardMainFlow( _ segue: UIStoryboardSegue) { }
    
    @IBAction func exitCardsFlow(_ sender: Any) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        appDelegate.setToFlow(storyboardName: "NoHome", identifier: "Main App VC")
    }
}
