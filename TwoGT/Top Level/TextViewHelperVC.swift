//
//  TextViewHelperVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 10/1/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit

class TextViewHelperVC: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var textViewIdentifierLabel: UILabel!
    @IBOutlet weak var textView: ActiveTextView!
    
    var modifyingTextView: UITextView?
    var displayName: String = ""
    var initialText: String = ""
    
    func configure(textView: UITextView, displayName: String, initialText: String) {
        modifyingTextView = textView
        self.displayName = displayName
        self.initialText = initialText
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        textViewIdentifierLabel.text = displayName
        textView.text = initialText
        // Do any additional setup after loading the view.
    }
    
    @IBAction func endEditing(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    @IBAction func save(_ sender: Any) {
        modifyingTextView?.text = textView.text
        dismiss(animated: true, completion: nil)
    }

}
