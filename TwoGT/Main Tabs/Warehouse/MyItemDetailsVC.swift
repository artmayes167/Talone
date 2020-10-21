//
//  MyItemDetailsVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 10/21/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit

class MyItemDetailsVC: ItemDetailsVC {
    
    @IBOutlet weak var personalNotesTextView: UITextView!
    
    func configure(have: Have?, need: Need?) {
        model.configure(have: have, need: need)
    }
    
    @IBAction func notifyWatchers(_ sender: UIButton) {
        devNotReady()
    }
    
    @IBAction func deleteItem(_ sender: UIButton) {
        devNotReady()
    }
    
    @IBAction func updateItem(_ sender: UIButton) {
        devNotReady()
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


extension MyItemDetailsVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        switch textView {
        case personalNotesTextView:
            showTextViewHelper(textView: personalNotesTextView, displayName: "personal notes", initialText: personalNotesTextView.text)
        case descriptionTextView:
            showTextViewHelper(textView: descriptionTextView, displayName: "description", initialText: descriptionTextView.text)
        default:
            return
        }
    }
}
