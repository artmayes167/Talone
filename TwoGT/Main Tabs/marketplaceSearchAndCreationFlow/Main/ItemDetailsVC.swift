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
        header.bottomView.backgroundColor = color
        header.leftView.backgroundColor = color
        header.categoryImageView.backgroundColor = color
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
    
    func configure(needItem: NeedsBase.NeedItem) {
        categoryImageView.image = UIImage(named: needItem.category.lowercased())
        headlineLabel.text = needItem.headline
        dateLabel.text = needItem.createdAt?.dateValue().stringFromDate()
    }
    func configure(haveItem: HavesBase.HaveItem) {
        categoryImageView.image = UIImage(named: haveItem.category.lowercased())
        headlineLabel.text = haveItem.headline
        dateLabel.text = haveItem.createdAt?.dateValue().stringFromDate()
    }
    
}

class NeedDetailModel {
    private var have: HavesBase.HaveItem?
    private var need: NeedsBase.NeedItem?
    private var rating: ContactRating?
    
    var handlesArray: [String] = []
    
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
            if let childNeeds = h.needs, !childNeeds.isEmpty {
                handlesArray = childNeeds.map { $0.owner }
            }
            let contact = CoreDataGod.user.contacts?.first( where: { $0.contactHandle == h.owner })
            rating = contact?.rating?.last
        }
    }
    
    func populate(controller c: ItemDetailsVC) {
        if let n = need {
            c.handleLabel.text = n.owner
            c.descriptionTextView.text = n.description
            c.manager.configure(c.header, rating: rating)
            c.header.configure(needItem: n)
        } else if let h = have {
            c.handleLabel.text = h.owner
            c.descriptionTextView.text = h.description
            c.manager.configure(c.header, rating: rating)
            c.header.configure(haveItem: h)
        }
    }
    
    func watcherAction(add: Bool) {
        // TODO: - Actually manage watchers in the DB
        if add { handlesArray.append(CoreDataGod.user.handle!) }
        else {
            if let index = handlesArray.indexOf(CoreDataGod.user.handle!) {
                handlesArray.remove(at: index)
            }
        }
    }
}

class ItemDetailsVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var header: ConfigurableHeader!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    
    let manager = MarketplaceRepThemeManager()
    let model = NeedDetailModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        model.populate(controller: self)
    }
    
    func configure(needItem: NeedsBase.NeedItem?, haveItem: HavesBase.HaveItem?) {
        model.configure(needItem: needItem, haveItem: haveItem)
    }
    
    @IBAction func touchedWatch(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        model.watcherAction(add: sender.isSelected)
        tableView.reloadData()
        /// DOES NOT SAVE YET
    }
    
    @IBAction func sendCard(_ sender: UIButton) {
        devNotReady()
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

extension ItemDetailsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // send card?
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
