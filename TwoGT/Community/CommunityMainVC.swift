//
//  CommunityMainVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 11/4/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import CoreData

class CommunityMainVC: UIViewController {
    @IBOutlet weak var whereTextField: UITextField!
    @IBOutlet weak var communityNameField: UITextField!
    @IBOutlet weak var newGuildButton: UIButton!
    
    var myGuildsTVC: MyGuildsTVC?
    var availableGuildsTVC: AvailableGuildsTVC?
    
    @IBOutlet weak var myGuildsContainer: UIView!
    @IBOutlet weak var availableGuildsContainer: UIView!
    
    var loc: CityStateSearchVC.Loc?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    private func setInitialValues() {
        if let loc = UserDefaults.standard.dictionary(forKey: DefaultsKeys.lastUsedLocation.rawValue) as? [String: String] {
            guard let city = loc[DefaultsSavedLocationKeys.city.rawValue], let state = loc[DefaultsSavedLocationKeys.state.rawValue] else { return }
            let newLoc = CityStateSearchVC.Loc()
            newLoc.city = city
            newLoc.state = state
            DispatchQueue.main.async {
                self.whereTextField.text = newLoc.displayName()
            }
            self.loc = newLoc
        }
    }
    

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCityState" {
            segue.destination.presentationController?.delegate = self
            guard let vc = segue.destination as? CityStateSearchVC else { fatalError() }
            vc.unwindSegueIdentifier = .searchGuilds
        } else if segue.identifier == "toAvailableGuilds" {
            guard let vc = segue.destination as? AvailableGuildsTVC else { return }
            vc.delegate = self
            availableGuildsTVC = vc
        } else if segue.identifier == "toMyGuilds" {
            guard let vc = segue.destination as? MyGuildsTVC else { return }
            vc.delegate = self
            myGuildsTVC = vc
        } else if segue.identifier == "toGuild" {
            guard let mine = sender as? Bool else {
                devNotReady()
                return
            }
            if mine {
                // populate myGuild
            } else {
                // populate notMyGuild
            }
        }
    }
   
 /// Currently only effectivey used by CityStateSearchVC
    @IBAction func unwindToMainGuilds( _ segue: UIStoryboardSegue) {
        if let s = segue.source as? CityStateSearchVC {
            whereTextField.text = s.loc.displayName()
            availableGuildsTVC?.tableView.reloadData()
            let dict = ["city": s.loc.city, "state": s.loc.state]
            UserDefaults.standard.setValue(dict, forKey: DefaultsKeys.lastUsedLocation.rawValue)
            loc = s.loc
        }
    }
}

extension CommunityMainVC: GuildSelectionDelegate {
    func empty(_ empty: Bool, mine: Bool) {
        if mine {
            myGuildsContainer.isHidden = empty
        } else {
            availableGuildsContainer.isHidden = empty
        }
        view.layoutIfNeeded()
    }
    
    func selected(name: String, mine: Bool) {
        if mine {
            performSegue(withIdentifier: "toGuild", sender: mine)
        } else {
            performSegue(withIdentifier: "toGuild", sender: mine)
        }
    }
}

protocol GuildSelectionDelegate {
    func selected(name: String, mine: Bool)
    func empty(_ empty: Bool, mine: Bool)
}

class MyGuildsTVC: UITableViewController {
    private var list: [String]  = []
//    private var keys: [String] = [] { didSet { tableView.reloadData() } }
    var delegate: GuildSelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetchRequest: NSFetchRequest<Community> = Community.fetchRequest()
        do {
            let u = try CoreDataGod.managedContext.fetch(fetchRequest)
            print("Successfully fetched Communities")
            var firstList = u.map { $0.name! }
            firstList = firstList.filter( { $0 != "" })
            delegate?.empty(firstList.isEmpty, mine: true)
            configure(list: firstList)
        } catch {
            devNotReady()
        }
    }
    
    func configure(list: [String]) {
//        var dict: [String: [String]] = [:]
//        var firstLettersArray: [String] = []
//        for string in list {
//            if let firstChar = string.first {
//                if var array = dict[String(firstChar)] {
//                    array.append(string)
//                    dict[String(firstChar)] = array
//                } else { // first time
//                    firstLettersArray.append(String(firstChar))
//                    dict[String(firstChar)] = [string]
//                }
//            } else { fatalError() }
//        }
//        self.list = dict
//        self.keys = firstLettersArray.sorted()
        self.list = list.sorted()
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return list.count
    }
    
//    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
//        return keys
//    }
    
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return keys[section]
//    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "header") as! SimpleSearchCell
        return cell.contentView
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        let key = keys[section]
//        guard let array = list[key] else { return 0 }
        return list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SimpleSearchCell
        cell.basicLabel.text = list[indexPath.row]
        // cell.colorBar
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.selected(name: list[indexPath.row], mine: true)
    }
}

class AvailableGuildsTVC: UITableViewController {
    private var list: [String]  = []
//    private var keys: [String] = [] { didSet { tableView.reloadData() } }
    var delegate: GuildSelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get communities from server, for selected location
        
//        let fetchRequest: NSFetchRequest<Community> = Community.fetchRequest()
//        do {
//            let u = try CoreDataGod.managedContext.fetch(fetchRequest)
//            print("Successfully fetched Communities")
//            var firstList = u.map { $0.name! }
//            firstList = firstList.filter( { $0 != "" })
//            configure(list: firstList)
//        } catch {
//            devNotReady()
//        }
        delegate?.empty(true, mine: false)
    }
    
//    func configure(list: [String]) {
//        var dict: [String: [String]] = [:]
//        var firstLettersArray: [String] = []
//        for string in list {
//            if let firstChar = string.first {
//                if var array = dict[String(firstChar)] {
//                    array.append(string)
//                    dict[String(firstChar)] = array
//                } else { // first time
//                    firstLettersArray.append(String(firstChar))
//                    dict[String(firstChar)] = [string]
//                }
//            } else { fatalError() }
//        }
//        self.list = dict
//        self.keys = firstLettersArray.sorted()
//
//        tableView.reloadData()
//    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "header") as! SimpleSearchCell
        return cell.contentView
    }
    
//    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
//        return keys
//    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SimpleSearchCell
        cell.basicLabel.text = list[indexPath.row]
        // cell.colorBar
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.selected(name: list[indexPath.row], mine: false)
    }
}
