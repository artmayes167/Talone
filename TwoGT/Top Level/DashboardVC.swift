//
//  DashboardVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/9/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//
/// I'm preserving this class for the vigilance implimentation, and the data creation methods at the bottom
import UIKit

class DashboardVC: UIViewController {

    @IBOutlet weak var vigilantSwitch: UISwitch!
    @IBOutlet weak var reachabilityStackView: UIStackView!
    
    @IBOutlet weak var newHandleTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let def = UserDefaults.standard
        vigilantSwitch.isOn = def.bool(forKey: "vigilant")
        switchedBetweenNormalAndVigilant(vigilantSwitch)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func unwindToDashboard( _ segue: UIStoryboardSegue) {
        
    }
    
    let str = String(format: "\nThis app behaves like a normal app by default, hunting down any way to get to the interwebs, then sending and grabbing as much data as possible. \n\n You have the option of setting the app so that it will only communicate with the interwebs when you say so. \n\n Turning this setting on will enable an interface in the app that gives you full control over any networking activity performed herein. \n\n Hopefully this will reduce costs associated with data plans and untrusted networks.")

    @IBAction func showVigilanceInfo() {
        showOkayAlert(title: "Vigilance", message: str, handler: nil)
    }
    
    @IBAction func switchedBetweenNormalAndVigilant(_ sender: UISwitch) {
        let def = UserDefaults.standard
        if sender.isOn {
            def.set(true, forKey: "vigilant")
            reachabilityStackView.isHidden = false
        } else {
            def.set(false, forKey: "vigilant")
            reachabilityStackView.isHidden = true
        }
        view.layoutIfNeeded()
    }
    
    @IBAction func submitHandle() {
        let _ = newHandleTextField.text
        
    }
    
    var timer: Timer?
    var adminCounter = 0
    @IBAction func adminTapped(_ sender: Any) {
        adminCounter += 1
        if let t = timer, t.isValid {
            if adminCounter == 5 {
                self.adminCounter = 0
                self.timer?.invalidate()
                
                showAdminPasswordAlert(title: "Admin", message: "") { _ in
                    self.dismiss(animated: true) {
                        self.performSegue(withIdentifier: "toAdmin", sender: nil)
                    }
                }
            }
        } else {
            timer = Timer.init(timeInterval: Date().timeIntervalSince1970 + 60, repeats: false, block: { _ in
                self.adminCounter = 0
                self.timer?.invalidate()
            })
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}
