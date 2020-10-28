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
                    self.stubsArray = childNeeds
                    self.handlesArray = childNeeds.map { $0.handle }
                }
                self.need = item
            })
        } else if let h = have {
            let fetcher = HavesDbFetcher()
            fetcher.fetchHave(id: h.id!, completion: { [weak self] (item, error) in
                guard let self = self else { return }
                if let childNeeds = item?.watchers, !childNeeds.isEmpty {
                    self.stubsArray = childNeeds
                    self.handlesArray = childNeeds.map { $0.handle }
                }
                self.have = item
            })
        }
    }
    
    func refreshMyWatchers(_ c: ItemDetailsVC) {
        if let n = need {
            let fetcher = NeedsDbFetcher()
            fetcher.fetchNeed(id: n.id!, completion: { [weak self] (item, error) in
                guard let self = self else { return }
                if let childNeeds = item?.watchers, !childNeeds.isEmpty {
                    self.stubsArray = childNeeds
                    self.handlesArray = childNeeds.map { $0.handle }
                }
                self.need = item
                //c.tableView.reloadData()
            })
        } else if let h = have {
            let fetcher = HavesDbFetcher()
            fetcher.fetchHave(id: h.id!, completion: { [weak self] (item, error) in
                guard let self = self else { return }
                if let childNeeds = item?.watchers, !childNeeds.isEmpty {
                    self.stubsArray = childNeeds
                    self.handlesArray = childNeeds.map { $0.handle }
                }
                self.have = item
                //c.tableView.reloadData()
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

/** MyItemDetailsVC subclasses ItemDetailsVC, so check there too before changing anything
        sets the item in the model from the core data model `Need` or `Have`.  when those items are set, the model makes a call to retrieve refreshed items from FiB, and sets the resulting `NeedItem` or `HaveItem`, which it uses for future refreshes.  It will update the values by calling refreshMyWatchers on certain user-initiated actions.
 */
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
        model.configureMy(self, have: have, need: need)
        self.have = have
        self.need = need
    }
    
    /// Called by UIAdaptivePresentationControllerDelegate
    override func updateUI() {
        model.refreshMyWatchers(self)
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
    
    /// Not sending a new card, just updating personal notes
    @IBAction func updateItem(_ sender: UIButton) {
        let d = descriptionTextView.text ?? ""
        let p = personalNotesTextView.text ?? ""
        if var n = model.need {
            n.description = d
            let writer = NeedsDbWriter()
            writer.updateNeedDescriptionAndHeadline(n) { (_) in
                
            }
            if let ne = need {
                ne.desc = d
                ne.personalNotes = p
                CoreDataGod.managedContext.refresh(ne, mergeChanges: true)
            }
        } else if var h = model.have {
            h.description = d
            let writer = HavesDbWriter()
            writer.updateHaveDescriptionAndHeadline(h) { (_) in
                
            }
            if let ha = have {
                ha.desc = d
                ha.personalNotes = p
                CoreDataGod.managedContext.refresh(ha, mergeChanges: true)
            }
        }
        CoreDataGod.save()
        DispatchQueue.main.async {
            self.showOkayAlert(title: "".taloneCased(), message: "successfully saved notes".taloneCased(), handler: nil)
            self.updateUI()
        }
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
