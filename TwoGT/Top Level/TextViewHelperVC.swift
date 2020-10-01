//
//  TextViewHelperVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 10/1/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit

class TextViewHelperVC: UITabBarController, UITextViewDelegate {
    
    @IBOutlet weak var textViewIdentifierLabel: UILabel!
    @IBOutlet weak var textView: ActiveTextView!
    
    var modifyingTextView: UITextView?
    
    func configure(textView: UITextView, displayName: String, initialText: String) {
        modifyingTextView = textView
        textViewIdentifierLabel.text = displayName
        textView.text = initialText
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func save(_ sender: Any) {
        modifyingTextView?.text = textView.text
        dismiss(animated: true, completion: nil)
    }

}
