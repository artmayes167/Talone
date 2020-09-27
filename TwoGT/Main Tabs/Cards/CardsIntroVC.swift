//
//  CardsIntroVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/8/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit

class CardsIntroVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func navigateToCards(_ sender: UIButton) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        DispatchQueue.main.async() {
            appDelegate.window = UIWindow(frame: UIScreen.main.bounds)
            let mainStoryboard = UIStoryboard(name: "Cards", bundle: nil)
            let mainVC = mainStoryboard.instantiateViewController(withIdentifier: "Main Card VC") as! CardsBaseSwipeVC

            appDelegate.window?.rootViewController = mainVC
            appDelegate.window?.makeKeyAndVisible()
        }
    }
    
    @IBAction func unwindToCardIntro( _ segue: UIStoryboardSegue) {
    
    }

}
