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

    @IBOutlet weak var lookLabel: UILabel!
    @IBOutlet weak var swipeLabel: UILabel!
    
    func animate() {

        let alphaPulseAnimation = CABasicAnimation(keyPath: "opacity")
        alphaPulseAnimation.duration = 1
        alphaPulseAnimation.fromValue = 1
        alphaPulseAnimation.toValue = 0.5
        alphaPulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        alphaPulseAnimation.autoreverses = true
        alphaPulseAnimation.repeatCount = .greatestFiniteMagnitude
        spinner.layer.add(alphaPulseAnimation, forKey: "opacityAnimation")
        
        let sizePulseAnimation = CABasicAnimation(keyPath: "transform.scale.x")
        sizePulseAnimation.duration = 3
        sizePulseAnimation.fromValue = 0.1
        sizePulseAnimation.toValue = 1
        sizePulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        sizePulseAnimation.autoreverses = false
//        sizePulseAnimation.repeatCount = .greatestFiniteMagnitude
        lookLabel.layer.add(sizePulseAnimation, forKey: "sizeAnimation")
        
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 1
        rotation.isCumulative = true
        rotation.repeatCount = .greatestFiniteMagnitude
        spinner.layer.add(rotation, forKey: "rotationAnimation")
        
        lookLabel.alpha = 0.1
        swipeLabel.alpha = 0
        UIView.animate(withDuration: 3) {
            self.lookLabel.alpha = 1
        } completion: { (_) in
            UIView.animate(withDuration: 3) {
                self.swipeLabel.alpha = 1
            }
        }
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
