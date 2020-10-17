//
//  NeedHaveTabControllerView.swift
//  TwoGT
//
//  Created by Arthur Mayes on 10/15/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit

class NeedHaveTabControllerView: UIView {
    
    @IBOutlet weak var leftTabButton: UIButton! // need
    @IBOutlet weak var rightTabButton: UIButton! // have
    
    @IBOutlet weak var tableView: UITableView!
    
    var left = true
    
//    @IBOutlet weak var leftContainerView: UIView!
//    @IBOutlet weak var rightContainerView: UIView!
//
    @IBAction func selectedLeftTab(_ sender: UIButton) {
        bringSubviewToFront(leftTabButton)
        left = true
        tableView.backgroundColor = sender.backgroundColor?.withAlphaComponent(0.44)
    }

    @IBAction func selectedRightTab(_ sender: UIButton) {
        bringSubviewToFront(rightTabButton)
        left = false
        tableView.backgroundColor = sender.backgroundColor?.withAlphaComponent(0.44)
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
