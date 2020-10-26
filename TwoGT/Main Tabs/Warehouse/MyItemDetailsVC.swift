//
//  MyItemDetailsVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 10/21/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit

extension NeedDetailModel {
    
    /// specifically for needs/haves owned by this person
    func configureMy(_ c: MyItemDetailsVC, have: Have?, need: Need?) {
        // get rating
        self.getPopularContactRating(c, uid: CoreDataGod.user.uid!)
        if need == nil && have == nil { return }
        // get watchers
        if let n = need {
            let fetcher = NeedsDbFetcher()
            fetcher.fetchNeed(id: n.id!, completion: { [weak self] (item, error) in
                guard let self = self else { return }
                if let childNeeds = item?.watchers, !childNeeds.isEmpty {
                    self.handlesArray = childNeeds.map { $0.handle }
                }
                self.need = item
            })
        } else if let h = have {
            let fetcher = HavesDbFetcher()
            fetcher.fetchHave(id: h.id!, completion: { [weak self] (item, error) in
                guard let self = self else { return }
                if let childNeeds = item?.watchers, !childNeeds.isEmpty {
                    self.handlesArray = childNeeds.map { $0.handle }
                }
                self.have = item
            })
        }
    }
    
    // populate initial values while we get the backend data
    func populate(controller c: MyItemDetailsVC, have: Have?, need: Need?) {
        if let n = need {
            DispatchQueue.main.async {
                c.descriptionTextView.text = n.desc
                c.personalNotesTextView.text = n.personalNotes
                c.header.configure(need: n)
            }
        } else if let h = have {
            DispatchQueue.main.async {
                c.descriptionTextView.text = h.desc
                c.personalNotesTextView.text = h.personalNotes
                c.header.configure(have: h)
            }
        }
    }
    
    func deleteCurrentHave(controller c: MyItemDetailsVC, have: Have) {
        HavesDbWriter().deleteHave(id: have.id!, creator: CoreDataGod.user.uid!) { error in
            if error == nil {
                c.successfullyDeletedHaveFromBackend()
            } else {
                c.hideSpinner()
                c.showOkayAlert(title: "Error", message: "Error while deleting have. Error: \(error!.localizedDescription)", handler: nil)
            }
        }
    }
    
    func deleteCurrentNeed(controller c: MyItemDetailsVC, need: Need) {
        NeedsDbWriter().deleteNeed(id: need.id!, userHandle: CoreDataGod.user.handle!) { error in
            if error == nil {
                c.successfullyDeletedNeedFromBackend()
            } else {
                c.hideSpinner()
                c.showOkayAlert(title: "Error", message: "Error while deleting need. Error: \(error!.localizedDescription)", handler: nil)
            }
        }
    }
}

class MyItemDetailsVC: ItemDetailsVC {
    
    @IBOutlet weak var personalNotesTextView: UITextView!
    private var have: Have? {
        didSet {
            if let h = have {
                CoreDataGod.managedContext.refresh(h, mergeChanges: false)
                model.populate(controller: self, have: h, need: nil)
            }
        }
    }
    private var need: Need? {
        didSet {
            if let n = need {
                CoreDataGod.managedContext.refresh(n, mergeChanges: false)
                model.populate(controller: self, have: nil, need: n)

            }
        }
    }
    
    func configure(have: Have?, need: Need?) {
        self.have = have
        self.need = need
        model.configureMy(self, have: have, need: need)
    }
    
    @IBAction func notifyWatchers(_ sender: UIButton) {
        devNotReady()
    }
    
    @IBAction func deleteItem(_ sender: UIButton) {
        if let h = have {
            showSpinner()
            model.deleteCurrentHave(controller: self, have: h)
        } else if let n = need {
            showSpinner()
            model.deleteCurrentNeed(controller: self, need: n)
        }
    }
    
    @IBAction func updateItem(_ sender: UIButton) {
        // TODO: save personal notes and update description
        devNotReady()
    }
    
    func successfullyDeletedHaveFromBackend() {
        if let h = have {
            h.deleteHave()
            hideSpinner()
            makeToast("You have Deleted the Have", duration: 0.5) {_ in
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func successfullyDeletedNeedFromBackend() {
        if let n = need {
            n.deleteNeed()
            hideSpinner()
            makeToast("You have Deleted the Need", duration: 0.5) {_ in
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}

 // MARK: - UITextViewDelegate
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
