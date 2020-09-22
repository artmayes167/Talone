//
//  DashboardDeMinimusVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/21/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit

class DashboardDeMinimusVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
                    self.performSegue(withIdentifier: "toAdmin", sender: nil)
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func unwindToDashboardDeMinimus( _ segue: UIStoryboardSegue) {
        
    }

}
