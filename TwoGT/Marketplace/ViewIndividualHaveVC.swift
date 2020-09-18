//
//  ViewIndividualHaveVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/16/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit

class ViewIndividualHaveVC: UIViewController {
    var haveItem: HavesBase.HaveItem? {
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
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var doYouLabel: UILabel!
    
    @IBOutlet weak var needDescriptionTextView: UITextView!
    @IBOutlet weak var personalNotesTextView: UITextView!
    
     // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Notifications
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        if let owner = haveItem?.owner {
            headerTitleLabel.text = String(format: "%@'s Have", owner)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        populateUI()
        
    }
    
    func populateUI() {
        guard let n = haveItem?.category, let cityState = creationManager?.getLocationOrNil() else { return }
        guard let t = creationManager?.currentCreationType() else { fatalError() }
        let str = "Do you " + t + "..."
        doYouLabel.text = str
        locationLabel.text = String(format:"%@ in %@", n, cityState.displayName())
        view.layoutIfNeeded()
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
    
     // MARK: - Actions
    
    @IBAction func showLinkedNeeds(_ sender: Any) {
    }
    
    @IBAction func showLinkedHaves(_ sender: Any) {
    }
    
    @IBAction func joinThisHave(_ sender: Any) {
        // show textView for Headline and description (Required?)
        // Create a Have in the database linked to the current Have
        
        guard let c = creationManager, let h = haveItem else { fatalError() }
        
        
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

extension ViewIndividualHaveVC: UITextViewDelegate {
    
    
}
