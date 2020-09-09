//
//  DashboardVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/9/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit

class DashboardVC: UIViewController {

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
    
    let str = String(format: "This app behaves like a normal app by default, hunting down any way to get to the interwebs, then sending and grabbing as much data as possible. \n You have the option of setting the app so that it will only communicate with the interwebs when you say so. /n Turning this setting on will enable an interface in the app that gives you full control over any networking activity performed herein. /n Hopefully this will reduce costs associated with data plans and untrusted networks.")

    @IBAction func showVigilanceInfo() {
        showOkayAlert(title: "Vigilance", message: str, handler: nil)
    }
}
