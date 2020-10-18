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
    @IBOutlet weak var leftTabVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightTabButton: UIButton! // have
    @IBOutlet weak var rightTabVerticalConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var leftFolderLine: UIView!
    @IBOutlet weak var rightFolderLine: UIView!
    
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var bottomCap: UIImageView!
    
    var left = true
    
    func configure() {
        selectedLeftTab(leftTabButton)
    }

    @IBAction func selectedLeftTab(_ sender: UIButton) {
        bringSubviewToFront(leftFolderLine)
        bringSubviewToFront(leftTabButton)
        leftTabVerticalConstraint.constant = 0
        rightTabVerticalConstraint.constant = 6
        
        left = true
        UIView.animate(withDuration: 0.2) {
            self.bottomCap.tintColor = sender.backgroundColor!.withAlphaComponent(0.77)
            self.headerImage.tintColor = sender.backgroundColor!.withAlphaComponent(0.77)
            self.tableView.backgroundColor = sender.backgroundColor!.withAlphaComponent(0.77)
            self.leftTabButton.backgroundColor = sender.backgroundColor!.withAlphaComponent(0.90)
            self.rightTabButton.backgroundColor = self.rightTabButton.backgroundColor!.withAlphaComponent(0.44)
            self.mainView.layoutIfNeeded()
        }
        
    }

    @IBAction func selectedRightTab(_ sender: UIButton) {
        bringSubviewToFront(rightFolderLine)
        bringSubviewToFront(rightTabButton)
        leftTabVerticalConstraint.constant = 6
        rightTabVerticalConstraint.constant = 0
        left = false
        
        UIView.animate(withDuration: 0.2) {
            self.bottomCap.tintColor = sender.backgroundColor!.withAlphaComponent(0.77)
            self.headerImage.tintColor = sender.backgroundColor!.withAlphaComponent(0.77)
            self.tableView.backgroundColor = sender.backgroundColor!.withAlphaComponent(0.77)
            self.rightTabButton.backgroundColor = sender.backgroundColor!.withAlphaComponent(0.90)
            self.leftTabButton.backgroundColor = self.leftTabButton.backgroundColor!.withAlphaComponent(0.44)
            self.mainView.layoutIfNeeded()
        }
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
