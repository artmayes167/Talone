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
    @IBOutlet weak var doneEditingButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func saveNotes(_ sender: UIButton) {
    }
    
    
    @IBAction func sendCard(_ sender: UIButton) {
    }
    
    @IBAction func endEditing(_ sender: UIButton) {
        view.endEditing(true)
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


