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
    func configure(_ header: ConfigurableHeader, rating: ContactRating?) {
        guard let r = rating else {
            setTheme(header: header, color: colorFor(.justSo))
            return
        }
        let bad = Float(r.bad)
        let justSo = Float(r.justSo)
        let good = Float(r.good)

        let denominator = bad + justSo + good
        if denominator == 0.0 {
            setTheme(header: header, color: colorFor(.justSo))
        }

        let justSoCount = Float(justSo) * 0.5
        let count = (good + justSoCount) / denominator
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

}

class NeedDetailModel {
    internal var have: HavesBase.HaveItem?
    internal var need: NeedsBase.NeedItem?
    internal var rating: ContactRating?

    var handlesArray: [String] = []
    var endRefreshCycle = false

    func configure(needItem: NeedsBase.NeedItem?, haveItem: HavesBase.HaveItem?) {
        if needItem == nil && haveItem == nil { fatalError() }
        if let n = needItem {
            need = n
            if let childNeeds = n.watchers, !childNeeds.isEmpty {
                handlesArray = childNeeds.map { $0.handle }
            }
            let contact = CoreDataGod.user.contacts?.first( where: { $0.contactHandle == n.owner })
            rating = contact?.rating?.last

        } else if let h = haveItem {
            have = h
            if let childNeeds = h.watchers, !childNeeds.isEmpty {
                handlesArray = childNeeds.map { $0.handle }
            }
            let contact = CoreDataGod.user.contacts?.first( where: { $0.contactHandle == h.owner })
            rating = contact?.rating?.last
        }
        endRefreshCycle = false
    }

    func populate(controller c: ItemDetailsVC) {
        DispatchQueue.global().async {
            var success = false
            if let n = self.need {
                DispatchQueue.main.async {
                    c.handleLabel?.text = n.owner
                    c.descriptionTextView.text = n.description
                    c.manager.configure(c.header, rating: self.rating)
                    c.header.configure(needItem: n)
                }
                success = true
            } else if let h = self.have {
                DispatchQueue.main.async {
                    c.handleLabel?.text = h.owner
                    c.descriptionTextView.text = h.description
                    c.manager.configure(c.header, rating: self.rating)
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

    func sendCard(_ c: UIViewController) {
        if let n = need {
            c.showCompleteAndSendCardHelper(needItem: n)
        } else if let h = have {
            c.showCompleteAndSendCardHelper(haveItem: h)
        } else {
            c.devNotReady()
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
            fatalError()
        }

        if add {
            handlesArray.append(CoreDataGod.user.handle!)
        } else if let index = handlesArray.indexOf(CoreDataGod.user.handle!) {
            handlesArray.remove(at: index)
        }
    }
}

class ItemDetailsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var header: ConfigurableHeader!
    @IBOutlet weak var handleLabel: UILabel?
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var watchButton: UIButton?

    var model = NeedDetailModel()
    /// called from model
    let manager = MarketplaceRepThemeManager()
    
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
        model.configure(needItem: needItem, haveItem: haveItem)
    }

    @IBAction func touchedWatch(_ sender: UIButton) {
        if sender.title(for: .normal) == "watch" {
            model.watcherAction(add: true, vc: self)
            sender.setTitle("unwatch", for: .normal)
            tableView.reloadData()
        } else if sender.title(for: .normal) == "unwatch" {
            model.watcherAction(add: false, vc: self)
            sender.setTitle("watch", for: .normal)
            tableView.reloadData()
        }
    }

    @IBAction func sendCard(_ sender: UIButton) {
        model.sendCard(self)
    }

    @IBAction func report(_ sender: UIButton) {
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

 // MARK: - TableView Used In MyItemDetailsVC
extension ItemDetailsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        devNotReady()
        // send card?  modify:
//        showCompleteAndSendCardHelper(haveItem: h)
        // go to contact?
        
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
