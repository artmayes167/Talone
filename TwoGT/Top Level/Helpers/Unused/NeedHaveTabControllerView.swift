//
//  NeedHaveTabControllerView.swift
//  TwoGT
//
//  Created by Arthur Mayes on 10/15/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit

class NeedHaveTabControllerView: UIView {
    
    @IBOutlet weak var leftTabButton: UIButton!
    @IBOutlet weak var rightTabButton: UIButton!
    
    @IBOutlet weak var leftContainerView: UIView!
    @IBOutlet weak var rightContainerView: UIView!
    
    @IBAction func selectedLeftTab(_ sender: UIButton) {
        bringSubviewToFront(leftTabButton)
        leftContainerView.superview?.bringSubviewToFront(leftContainerView)
    }
    
    @IBAction func selectedRightTab(_ sender: UIButton) {
        bringSubviewToFront(rightTabButton)
        rightContainerView.superview?.bringSubviewToFront(rightContainerView)
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
