//
//  ViewIndividualHaveVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/16/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import Firebase
import Toast_Swift
import CoreData

class ViewIndividualHaveVC: UIViewController {
    private var haveItem: HavesBase.HaveItem?
    private var creationManager: PurposeCreationManager?
    
    public func configure(haveItem item: HavesBase.HaveItem, creationManager manager: PurposeCreationManager) {
        haveItem = item
        creationManager = manager
    }
    
     // MARK: -
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var doYouLabel: UILabel!
    @IBOutlet weak var needDescriptionTextView: UITextView!
    @IBOutlet weak var personalNotesTextView: UITextView! // editable
    @IBOutlet weak var joinThisHaveButton: DesignableButton!

     // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if let owner = haveItem?.owner {
            headerTitleLabel.text = String(format: "%@'s Have", owner)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        populateUI()
    }

    func populateUI() {
        guard let h = haveItem, let cityState = creationManager?.getLocationOrNil() else { return }
        guard let t = creationManager?.currentCreationTypeString() else { fatalError() }
        let str = "Do you " + t + "..."
        doYouLabel.text = str
        locationLabel.text = String(format: "%@ in %@", h.category, cityState.displayName())
        needDescriptionTextView.text = haveItem?.description
        
        if let owner = haveItem?.owner {
            let text = h.headline ?? ""
            headerTitleLabel.text = String(format: "%@: \(text)", owner)
        }
        
        view.layoutIfNeeded()
    }

     // MARK: - Actions
    @IBAction func showLinkedHaves(_ sender: Any) { }

    @IBAction func joinThisHave(_ sender: Any) {
        // show textView for Headline and description (Required?)
        // Create a Have in the database linked to the current Have
        performSegue(withIdentifier: "toAddHeadline", sender: nil)
    }

    @IBAction func sendCard(_ sender: Any) {
        showCompleteAndSendCardHelper(haveItem: haveItem)
    }

    @IBAction func seeCard(_ sender: Any) { }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddHeadline" {
            guard let vc = segue.destination as? AddHaveToWatchVC else { fatalError() }
            vc.creationManager = creationManager
            vc.haveItem = haveItem
        }
    }
    
    @IBAction func unwindToViewIndividualHaveVC( _ segue: UIStoryboardSegue) {}
}

extension ViewIndividualHaveVC: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        showTextViewHelper(textView: personalNotesTextView, displayName: "personal notes", initialText: personalNotesTextView.text)
        return false
    }
}
