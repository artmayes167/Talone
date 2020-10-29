//
//  NeedDetailsVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 10/17/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import Firebase

extension MarketplaceRepThemeManager {
    /// Configures for personal rating
    func configure(_ header: ConfigurableHeader, rating: ContactRating?) {
        let count = getMyCountFor(rating)
        self.configure(header, count: count)
    }
    
    func configure(_ header: ConfigurableHeader, count: Float) {
        setTheme(header: header, color: themeFor(count))
    }

    private func setTheme(header: ConfigurableHeader, color: UIColor) {
        header.bottomView.borderColor = color
        header.leftView.backgroundColor = color
        header.categoryImageView.backgroundColor = color
        header.borderWidth = 0
        header.borderColor = color
    }

}

class ConfigurableHeader: UIView {
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var firstLetterLabel: UILabel!
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var mainView: UIView!

    func configure(needItem: NeedsBase.NeedItem) {
        categoryImageView.image = UIImage(named: needItem.category.lowercased())
        headlineLabel.text = needItem.headline
        dateLabel.text = needItem.createdAt?.dateValue().stringFromDate()
        firstLetterLabel.text = "N"
        mainView.layoutIfNeeded()
    }
    func configure(haveItem: HavesBase.HaveItem) {
        categoryImageView.image = UIImage(named: haveItem.category.lowercased())
        headlineLabel.text = haveItem.headline
        dateLabel.text = haveItem.createdAt?.dateValue().stringFromDate()
        firstLetterLabel.text = "H"
        mainView.layoutIfNeeded()
    }
    
    func configure(need: Need) {
        categoryImageView.image = UIImage(named: need.category!.lowercased())
        headlineLabel.text = need.headline
        dateLabel.text = need.createdAt?.stringFromDate()
        firstLetterLabel.text = "N"
        mainView.layoutIfNeeded()
    }
    func configure(have: Have) {
        categoryImageView.image = UIImage(named: have.category!.lowercased())
        headlineLabel.text = have.headline
        dateLabel.text = have.createdAt?.stringFromDate()
        firstLetterLabel.text = "H"
        mainView.layoutIfNeeded()
    }

}

/// Extension in MyItemDetailsVC, so check there too before changing anything
class NeedDetailModel {
    /// Model maintains references to FiB objects, and updates them for watcher information
    /// This model handles things relevant to Marketplace, which deals with FiB objects.  The `NeedDetailModel` extension includes support for the CD Items, which are used for initial display of owned Items.  The update process proceeds after they are set
    internal var have: HavesBase.HaveItem?
    internal var need: NeedsBase.NeedItem?
    internal var rating: ContactRating?
    internal var contact: Contact?
    internal var popularContactRating: Double = 0.5

    var handlesArray: [String] = []
    var stubsArray: [FirebaseGeneric.UserStub] = []
    var endRefreshCycle = false

    func configure(_ c: ItemDetailsVC, needItem: NeedsBase.NeedItem?, haveItem: HavesBase.HaveItem?) {
        if needItem == nil && haveItem == nil { fatalError() }
        if let n = needItem {
            need = n
            if let childNeeds = n.watchers, !childNeeds.isEmpty {
                stubsArray = childNeeds
                handlesArray = childNeeds.map { $0.handle }
            }
            getPopularContactRating(c, uid: n.createdBy)
        } else if let h = haveItem {
            have = h
            if let childNeeds = h.watchers, !childNeeds.isEmpty {
                stubsArray = childNeeds
                handlesArray = childNeeds.map { $0.handle }
            }
            getPopularContactRating(c, uid: h.createdBy)
        }
        endRefreshCycle = false
    }
    
    func getPopularContactRating(_ c: ItemDetailsVC, uid: String) {
        RatingsDbHandler.fetchRating(uid: uid) { (rating, error) in
            if rating >= 0 {
                self.popularContactRating = rating
            } else {
                self.popularContactRating = 0.5
            }
            let manager = MarketplaceRepThemeManager()
            manager.configure(c.header, count: Float(self.popularContactRating))
        }
    }

    /// Cycles on a background loop until we get a response-- poor man's KVO
    func populate(controller c: ItemDetailsVC) {
        DispatchQueue.global().async {
            var success = false
            if let n = self.need {
                DispatchQueue.main.async {
                    c.handleLabel?.text = n.owner
                    c.descriptionTextView.text = n.description
                    c.header.configure(needItem: n)
                }
                success = true
            } else if let h = self.have {
                DispatchQueue.main.async {
                    c.handleLabel?.text = h.owner
                    c.descriptionTextView.text = h.description
                    c.header.configure(haveItem: h)
                }
                success = true
            }
            if !success && !self.endRefreshCycle {
                self.populate(controller: c)
            } else if success, let b = c.watchButton {
                DispatchQueue.main.async {
                    if self.handlesArray.contains(CoreDataGod.user.handle!) {
                        b.setTitle("unwatch", for: .normal)
                    } else {
                        b.setTitle("watch", for: .normal)
                    }
                }
            }
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

    func sendCard(_ c: UIViewController) {
        if let n = need {
            c.showCompleteAndSendCardHelper(needItem: n)
        } else if let h = have {
            c.showCompleteAndSendCardHelper(haveItem: h)
        } else {
            c.somebodyScrewedUp()
        }
    }

    func watcherAction(add: Bool, vc: UIViewController) {
        endRefreshCycle = true
        let m = AddHaveToWatchModel()
        if let n = need {
            m.watcherAction(add: add, need: n, vc: vc)
        } else if let h = have {
            m.watcherAction(add: add, have: h, vc: vc)
        } else {
            vc.somebodyScrewedUp()
        }
        if add {
            handlesArray.append(CoreDataGod.user.handle!)
        } else if let index = handlesArray.indexOf(CoreDataGod.user.handle!) {
            handlesArray.remove(at: index)
        }
    }
}

/** Subclassed by MyItemDetailsVC, so check there too before changing anything
        sets the item in the model from the tableView selection in `MarketplaceMain`.  that tableView populates with needItems and haveItems from FiB, so the model populates using the values passed in.  It will update the values by calling refreshMyWatchers on certain user-initiated actions.
 */
class ItemDetailsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var header: ConfigurableHeader!
    @IBOutlet weak var handleLabel: UILabel?
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var watchButton: UIButton?

    var model = NeedDetailModel()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        model.populate(controller: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        model.endRefreshCycle = true
    }

    /// Not used in subclass MyItemDetailsVC
    func configure(needItem: NeedsBase.NeedItem?, haveItem: HavesBase.HaveItem?) {
        model.configure(self, needItem: needItem, haveItem: haveItem)
    }
    
    override func updateUI() {
        model.refreshMyWatchers(self)
        presentationController?.delegate?.updateUI()
    }

    @IBAction func touchedWatch(_ sender: UIButton) {
        if sender.title(for: .normal) == "watch" {
            model.watcherAction(add: true, vc: self)
            sender.setTitle("unwatch", for: .normal)
        } else if sender.title(for: .normal) == "unwatch" {
            model.watcherAction(add: false, vc: self)
            sender.setTitle("watch", for: .normal)
        }
        tableView.reloadData()
        updateUI()
    }

    @IBAction func sendCard(_ sender: UIButton) {
        model.sendCard(self)
    }

    @IBAction func report(_ sender: UIButton) {
        devNotReady()
    }
}

 // MARK: - TableView Also Used In MyItemDetailsVC
extension ItemDetailsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // send card
        guard let stub = model.stubsArray .first(where: { $0.handle == model.handlesArray[indexPath.row] }) else { fatalError() }
        showCompleteAndSendCardHelper(handle: stub.handle, uid: stub.uid)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.handlesArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SimpleSearchCell
        cell.basicLabel.text = model.handlesArray[indexPath.row]
        return cell
    }
}
