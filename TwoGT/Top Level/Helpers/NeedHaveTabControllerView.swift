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
    
    @IBOutlet weak var leftPost: UIView!
    @IBOutlet weak var rightPost: UIView!
    
    @IBOutlet weak var leftCreateButton: UIButton!
    @IBOutlet weak var rightCreateButton: UIButton!
    
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var bottomCap: UIImageView!
    
    var left = true
    
    func configure() {
        //selectedRightTab(rightTabButton)
        selectedLeftTab(leftTabButton)
    }

    @IBAction func selectedLeftTab(_ sender: UIButton) {
        bringSubviewToFront(leftFolderLine)
        bringSubviewToFront(leftTabButton)
        leftTabVerticalConstraint.constant = 0
        rightTabVerticalConstraint.constant = 6
        
        sender.doGlowAnimation(withColor: .white)
        self.rightTabButton.endGlowAnimation()
        self.leftCreateButton.doGlowAnimation(withColor: .white)
        self.rightCreateButton.endGlowAnimation()
        tableView.alpha = 0.5
        
        left = true
        UIView.animate(withDuration: 0.2) {
            self.tableView.alpha = 1.0
            self.headerImage.tintColor = sender.backgroundColor!.withAlphaComponent(0.77)
            self.tableView.backgroundColor = sender.backgroundColor!.withAlphaComponent(0.77)
            self.bottomCap.tintColor = sender.backgroundColor!.withAlphaComponent(0.77)
            self.leftPost.backgroundColor = sender.backgroundColor!.withAlphaComponent(1.0)
            
            self.leftCreateButton.borderColor = sender.backgroundColor!.withAlphaComponent(1.0)
            self.rightCreateButton.borderColor = self.rightTabButton.backgroundColor!.withAlphaComponent(1.0)
            self.leftCreateButton.titleLabel?.textColor = sender.backgroundColor!.withAlphaComponent(1.0)
            self.rightCreateButton.titleLabel?.textColor = self.rightTabButton.backgroundColor!.withAlphaComponent(1.0)
            
            self.leftTabButton.backgroundColor = sender.backgroundColor!.withAlphaComponent(0.90)
            self.rightTabButton.backgroundColor = self.rightTabButton.backgroundColor!.withAlphaComponent(0.44)
            self.mainView.layoutIfNeeded()
        }
        tableView.reloadData()
    }

    @IBAction func selectedRightTab(_ sender: UIButton) {
        bringSubviewToFront(rightFolderLine)
        bringSubviewToFront(rightTabButton)
        leftTabVerticalConstraint.constant = 6
        rightTabVerticalConstraint.constant = 0
        
        sender.doGlowAnimation(withColor: .white)
        self.leftTabButton.endGlowAnimation()
        self.rightCreateButton.doGlowAnimation(withColor: .white)
        self.leftCreateButton.endGlowAnimation()
        self.tableView.alpha = 0.5
        left = false
        
        UIView.animate(withDuration: 0.2) {
            self.tableView.alpha = 1.0
            self.bottomCap.tintColor = sender.backgroundColor!.withAlphaComponent(0.77)
            self.headerImage.tintColor = sender.backgroundColor!.withAlphaComponent(0.77)
            self.tableView.backgroundColor = sender.backgroundColor!.withAlphaComponent(0.77)
            
            self.rightTabButton.backgroundColor = sender.backgroundColor!.withAlphaComponent(0.90)
            self.leftTabButton.backgroundColor = self.leftTabButton.backgroundColor!.withAlphaComponent(0.44)
            self.mainView.layoutIfNeeded()
        }
        tableView.reloadData()
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
