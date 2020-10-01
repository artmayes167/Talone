//
//  ViewContactVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/30/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit

class ViewContactVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var messageTextView: InactiveTextView!
    @IBOutlet weak var notesView: ActiveTextView!
    @IBOutlet weak var saveNotesButton: DesignableButton!
    @IBOutlet weak var sendCardButton: DesignableButton!
    
    var dataSource: InteractionDataSource? {
        didSet {
            if isViewLoaded {
                updateUI()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    func updateUI() {
        // Strings are formatted in dataSource `ContactTabBarController`
        handleLabel.text = dataSource?.getHandle()
        notesView.text = dataSource?.getNotes()
        messageTextView.text = dataSource?.getMessage(sender: true)
    }
    
     // MARK: - IBActions
    @IBAction func saveNotes(_ sender: UIButton) {
        if let t = notesView.text?.pure() {
            dataSource?.saveNotes(t)
        }
    }
    
    @IBAction func sendCard(_ sender: UIButton) {
        // TODO: - Show card creation view, with template selector and message textView
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

extension ViewContactVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
}

extension ViewContactVC: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        func textViewDidBeginEditing(_ textView: UITextView) {
            textView.resignFirstResponder()
            
            let s = UIStoryboard.init(name: "Helper", bundle: nil)
            guard let vc = s.instantiateViewController(identifier: "TextView Helper") as? TextViewHelperVC else { fatalError() }
            vc.configure(textView: textView, displayName: "personal notes", initialText: notesView.text)
            present(vc, animated: true, completion: nil)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
    }
    
}


