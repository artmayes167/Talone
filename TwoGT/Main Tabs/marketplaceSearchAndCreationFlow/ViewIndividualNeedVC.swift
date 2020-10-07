//
//  ViewIndividualNeedVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/10/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import Firebase
import Toast_Swift
import CoreData

class ViewIndividualNeedVC: UIViewController {
     // MARK: - Accessors
    public var needItem: NeedsBase.NeedItem? { didSet { if isViewLoaded { populateUI() } } }
    public var creationManager: PurposeCreationManager?

     // MARK: - Outlets
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var needTypeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var needDescriptionTextView: UITextView!
    @IBOutlet weak var personalNotesTextView: UITextView!

     // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        populateUI()
    }

     // MARK: - private configuration
    private func populateUI() {
        guard let n = needItem, let cityState = creationManager?.getLocationOrNil() else { return }
        needTypeLabel.text = n.category
        locationLabel.text = cityState.displayName()
        needDescriptionTextView.text = n.description
        if let owner = needItem?.owner {
            let text = n.headline ?? ""
            headerTitleLabel.text = String(format: "%@: \(text)", owner)
        }
    }

     // MARK: - Actions
    // Link in storyboard, if nothing else is done here
    @IBAction func joinThisNeed(_ sender: Any) {
        performSegue(withIdentifier: "toAddHeadline", sender: nil)
    }
    
    @IBAction func sendCard(_ sender: Any) {
        if let _ = CoreDataGod.user.cardTemplates, let n = needItem {
            showCompleteAndSendCardHelper(needItem: n)
        } else {
            showOkayAlert(title: "hmm".taloneCased(), message: "you don't seem to have created any templates yet, or else there's a developer issue.", handler: nil)
        }
    }
    
    @IBAction func saveNotes(_ sender: Any) {} // TODO: 
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddHeadline" {
            guard let vc = segue.destination as? AddNeedToWatchVC else { fatalError() }
            vc.creationManager = creationManager
            vc.needItem = needItem
        }
    }

    @IBAction func unwindToViewIndividualNeedVC( _ segue: UIStoryboardSegue) {}
}

 // MARK: - UITextViewDelegate
extension ViewIndividualNeedVC: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        showTextViewHelper(textView: personalNotesTextView, displayName: "personal notes".taloneCased(), initialText: personalNotesTextView.text)
        return false
    }
}
