//
//  ViewIndividualNeedVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/10/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit

class ViewIndividualNeedVC: UIViewController {
    var need: Need? {
        didSet {
            if isViewLoaded {
                populateUI(with: need)
            }
        }
    }
    
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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        populateUI(with: need)
        
    }
    
    func populateUI(with need: Need?) {
        guard let n = need else { return }
        needTypeLabel.text = n.type?.rawValue.capitalized
        locationLabel.text = n.city + ", " + n.state
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
    
    @IBAction func joinThisNeed(_ sender: Any) {
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

extension ViewIndividualNeedVC: UITextViewDelegate {
    
    
}
