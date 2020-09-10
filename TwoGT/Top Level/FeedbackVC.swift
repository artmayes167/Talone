//
//  FeedbackVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/10/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit

class FeedbackVC: UIViewController {
    
    @IBOutlet weak var viewControllerNameLabel: UILabel!
    
    @IBOutlet weak var feedbackTextView: DesignableTextView!
    
    var topViewControllerIdentifier = "" {
        didSet {
            if isViewLoaded {
                viewControllerNameLabel.text = topViewControllerIdentifier
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewControllerNameLabel.text = topViewControllerIdentifier
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


extension FeedbackVC: UITextViewDelegate {
    
}
