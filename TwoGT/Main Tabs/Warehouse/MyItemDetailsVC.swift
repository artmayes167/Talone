//
//  MyItemDetailsVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 10/21/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit

extension NeedDetailModel {
    
    func configure(have: Have?, need: Need?) {
        if need == nil && have == nil { fatalError() }
        if let n = need {
            let fetcher = NeedsDbFetcher()
            fetcher.fetchNeed(id: n.id!, completion: { (item, error) in
                if let childNeeds = item?.watchers, !childNeeds.isEmpty {
                    self.handlesArray = childNeeds.map { $0.handle }
                }
                self.need = item
                guard let contact = CoreDataGod.user.contacts?.first( where: { $0.contactHandle == n.owner }) else { return }
                self.rating = contact.rating?.last
            })

        } else if let h = have {
            let fetcher = HavesDbFetcher()
            fetcher.fetchHave(id: h.id!, completion: { (item, error) in
                if let childNeeds = item?.watchers, !childNeeds.isEmpty {
                    self.handlesArray = childNeeds.map { $0.handle }
                }
                self.have = item
                guard let contact = CoreDataGod.user.contacts?.first( where: { $0.contactHandle == h.owner }) else { return }
                self.rating = contact.rating?.last
            })
        }
    }
    
    func deleteCurrentHave(controller c: MyItemDetailsVC) {
        guard let have = self.have else { return }

        HavesDbWriter().deleteHave(id: have.id!, creator: have.createdBy) { error in
            if error == nil {
                c.successfullyDeletedHaveFromBackend()
            } else {
                c.showOkayAlert(title: "Error", message: "Error while deleting have. Error: \(error!.localizedDescription)", handler: nil)
            }
        }
    }
    
    func deleteCurrentNeed(controller c: MyItemDetailsVC) {
        guard let need = self.need else { return }

        NeedsDbWriter().deleteNeed(id: need.id!, userHandle: need.createdBy) { error in
            if error == nil {
                c.successfullyDeletedNeedFromBackend()
            } else {
                c.showOkayAlert(title: "Error", message: "Error while deleting need. Error: \(error!.localizedDescription)", handler: nil)
            }
        }
    }
}

class MyItemDetailsVC: ItemDetailsVC {
    
    @IBOutlet weak var personalNotesTextView: UITextView!
    var have: Have?
    var need: Need?
    
    func configure(have: Have?, need: Need?) {
        model.configure(have: have, need: need)
        self.have = have
        self.need = need
    }
    
    @IBAction func notifyWatchers(_ sender: UIButton) {
        devNotReady()
    }
    
    @IBAction func deleteItem(_ sender: UIButton) {
        if let _ = have {
            model.deleteCurrentHave(controller: self)
        } else if let _ = need {
            model.deleteCurrentNeed(controller: self)
        }
    }
    
    @IBAction func updateItem(_ sender: UIButton) {
        // TODO: save personal notes and update description
        devNotReady()
    }
    
    func successfullyDeletedHaveFromBackend() {
        if let h = have {
            h.deleteHave()
            makeToast("You have Deleted the Have", duration: 0.5) {_ in
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func successfullyDeletedNeedFromBackend() {
        if let n = need {
            n.deleteNeed()
            makeToast("You have Deleted the Need", duration: 0.5) {_ in
                self.dismiss(animated: true, completion: nil)
            }
        }
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
