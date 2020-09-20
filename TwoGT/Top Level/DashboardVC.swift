//
//  DashboardVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/9/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

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
        let handle = newHandleTextField.text
        
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
    
    var needsWriter = NeedsDbWriter()
    var havesWriter = HavesDbWriter()
    var states: [USState] = []
    var allStates: [String] = []
    @IBAction func makeNeeds() {
        
        let path = Bundle.main.path(forResource: "citiesAndStates", ofType: "json")
        let url = URL.init(fileURLWithPath: path!)
        do {
            let jsonData = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            
            print(jsonData)
            let container = try decoder.decode([String: [String]].self, from: jsonData) as [String: [String]]
            print(container)
            container.forEach { (key, value) in
                let st = USState(name: key, cities: value)
                states.append(st)
                allStates.append(key)
            }
            allStates.sort{ $0 < $1 }
            
        } catch {
            print(error.localizedDescription)
        }
        
        for s in states {
            let c = s.cities
            for city in c {
                /// create new needs
//                let locData = NeedsDbWriter.LocationInfo(city: city, state: s.name, country: "USA", address: nil, geoLocation: nil)
//                let cat = NeedType.allCases[Int(arc4random())%5].rawValue.capitalized
//                let need = NeedsDbWriter.NeedItem(category: cat, description: String(format: "\(city), \(s.name), \(cat)"), validUntil: 4124045393, owner: "artmayes167", createdBy: "artmayes167@gmail.com", locationInfo: locData)
//                self.needsWriter.addNeed(need, completion: { error in
//                    if error == nil {
//                        print("Need added!")
//                    } else {
//                        print("Error writing a need: \(error!)")
//                    }
//                })
                
                /// create new haves
                let locData = HavesDbWriter.LocationInfo(city: city, state: s.name, country: "USA", address: nil, geoLocation: nil)
                let cat = NeedType.allCases[Int(arc4random())%5].rawValue.capitalized
                let have = HavesDbWriter.HaveItem(category: cat, description: String(format: "\(city), \(s.name), \(cat)")/*, validUntil: 4124045393*/, owner: "artmayes167", createdBy: "artmayes167@gmail.com", locationInfo: locData)
                self.havesWriter.addHave(have, completion: { error in
                    if error == nil {
                        print("Need added!")
                    } else {
                        print("Error writing a need: \(error!)")
                    }
                })
            }
        }
        
    }
}
