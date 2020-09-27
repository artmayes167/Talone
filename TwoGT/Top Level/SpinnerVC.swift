//
//  SpinnerVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/27/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit

class SpinnerVC: UIViewController {
    
    @IBOutlet weak var spinner: DesignableImage!
    @IBOutlet weak var spinnerWidthConstraint: NSLayoutConstraint!

    func animate() {

        let alphaPulseAnimation = CABasicAnimation(keyPath: "opacity")
        alphaPulseAnimation.duration = 1
        alphaPulseAnimation.fromValue = 1
        alphaPulseAnimation.toValue = 0.5
        alphaPulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        alphaPulseAnimation.autoreverses = true
        alphaPulseAnimation.repeatCount = .greatestFiniteMagnitude
        spinner.layer.add(alphaPulseAnimation, forKey: "opacityAnimation")
        
//        let sizePulseAnimation = CABasicAnimation(keyPath: "transform.scale.x")
//        sizePulseAnimation.duration = 25
//        sizePulseAnimation.fromValue = 1
//        sizePulseAnimation.toValue = 0.4
//        sizePulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
//        sizePulseAnimation.autoreverses = true
//        sizePulseAnimation.repeatCount = .greatestFiniteMagnitude
//        spinner.layer.add(sizePulseAnimation, forKey: "sizeAnimation")
        
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 1
        rotation.isCumulative = true
        rotation.repeatCount = .greatestFiniteMagnitude
        spinner.layer.add(rotation, forKey: "rotationAnimation")
    }
    
    override func didMove(toParent parent: UIViewController?) {
        if parent == nil {
            spinner.layer.removeAllAnimations()
        } else {
            animate()
        }
    }
    
    @IBAction func dismiss(_ sender: UISwipeGestureRecognizer?) {
        self.willMove(toParent: nil)
        self.view.removeFromSuperview()
        self.removeFromParent()
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
