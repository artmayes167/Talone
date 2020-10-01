//
//  RatingVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/30/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit

class RatingVC: UIViewController {
    
    @IBOutlet weak var badLabel: UILabel!
    @IBOutlet weak var justLabel: UILabel!
    @IBOutlet weak var goodLabel: UILabel!
    
    @IBOutlet weak var badButton: UIButton!
    @IBOutlet weak var justButton: UIButton!
    @IBOutlet weak var goodButton: UIButton!
    
    var badCount: Int = 0 {
        didSet {
            badLabel.text = String(badCount)
        }
    }
    var justCount: Int = 0 {
        didSet {
            justLabel.text = String(justCount)
        }
    }
    var goodCount: Int = 0 {
        didSet {
            goodLabel.text = String(goodCount)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func touched(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        switch sender {
        case badButton:
            badCount += (sender.isSelected ? 1 : -1)
        case justButton:
            justCount += (sender.isSelected ? 1 : -1)
        case goodButton:
            goodCount += (sender.isSelected ? 1 : -1)
        default:
            fatalError()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
