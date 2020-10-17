//
//  SelectorPopoverVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 10/16/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit

class CityStateModel {
    
    private var relevantList: [String] = []
    private var states: [USState] = []
    var list: [String: [String]]  = [:]
    var keys: [String] = []
    
    func configure(state s: String?) {
        load(state: s)
    }
    
    private func load(state s: String?) {
        var allStates: [String] = []
        let path = Bundle.main.path(forResource: "citiesAndStates", ofType: "json")
        let url = URL.init(fileURLWithPath: path!)
        do {
            let jsonData = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let container = try decoder.decode([String: [String]].self, from: jsonData) as [String: [String]]
            container.forEach { (key, value) in
                let st = USState(name: key, cities: value)
                states.append(st)
                allStates.append(key)
            }
            if let st = s {
                guard let state = states.first(where: { $0.name == st }) else { fatalError() }
                relevantList = state.cities
            } else {
                allStates.sort{ $0 < $1 }
                relevantList = allStates
            }
            sort()
        } catch { print(error.localizedDescription) }
    }
    
    private func sort() {
        var dict: [String: [String]] = [:]
        var firstLettersArray: [String] = []
        for string in relevantList {
            if let firstChar = string.first {
                if var array = dict[String(firstChar)] {
                    array.append(string)
                    dict[String(firstChar)] = array
                } else { // first time
                    firstLettersArray.append(String(firstChar))
                    dict[String(firstChar)] = [string]
                }
            } else { fatalError() }
        }
        self.list = dict
        self.keys = firstLettersArray.sorted()
    }
}

class SelectorPopoverVC: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    private var model = CityStateModel()
    private var label: UILabel?
    private var titleText: String = ""
    
    func configure(state: String?, label l: UILabel) {
        model.configure(state: state)
        label = l
        if let _ = state {
            titleText = "select your state"
        } else {
            titleText = "select your city"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        titleLabel.text = titleText
        tableView.reloadData()
    }
}

extension SelectorPopoverVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return model.keys.count
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return model.keys
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return model.keys[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = model.keys[section]
        guard let array = model.list[key] else { return 0 }
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SimpleSearchCell
        let key = model.keys[indexPath.section]
        guard let v = model.list[key] else { fatalError() }
        cell.basicLabel.text = v[indexPath.row]
        // cell.colorBar
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key = model.keys[indexPath.section]
        guard let array = model.list[key] else { fatalError() }
        label?.text = array[indexPath.row]
        dismiss(animated: true) { self.presentationController?.delegate?.updateUI() }
    }
}
