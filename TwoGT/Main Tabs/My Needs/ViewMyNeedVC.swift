//
//  ViewMyNeedVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/19/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit

class ViewMyNeedVC: UIViewController {

    var need: Need? {
        didSet {
            if isViewLoaded {
                populateUI()
            }
        }
    }
    
    // Manages live activity in the app
    var creationManager: PurposeCreationManager?
    
    @IBOutlet weak var headerTitleLabel: UILabel!

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var needTypeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var needDescriptionTextView: UITextView!
    @IBOutlet weak var personalNotesTextView: UITextView!
    
     // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Notifications
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        if let owner = need?.needItem?.owner ?? AppDelegate.user().handle {
            headerTitleLabel.text = String(format: "%@'s Need", owner)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        populateUI()
        
    }
    
    func populateUI() {
        guard let n = need?.needItem?.category, let cityState = need?.purpose?.cityState else { return }
        locationLabel.text = n + " in " + cityState.displayName()
    }
    
    // MARK: - Keyboard Notifications
    @objc func keyboardWillShow(notification: NSNotification){
        let userInfo = notification.userInfo!
        var keyboardFrame: CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)

        var contentInset: UIEdgeInsets = scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 20
        scrollView.contentInset = contentInset
    }

    @objc func keyboardWillHide(notification: NSNotification){
        let contentInset: UIEdgeInsets = UIEdgeInsets()
        scrollView.contentInset = contentInset
    }

}
