//
//  NameNewCommunityVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 11/4/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit

class NameCommunityModel {
    var guildNames: [String] = []
    var guilds: [String] = []
    
    func checkHandle(text t: String, controller c: NameNewCommunityVC) {
//        let handleHandler = UserHandlesDbHandler()
//        handleHandler.fetchUserHandles(startingWith: t, maxCount: 100) { (userHandles) in
//            self.handles = userHandles.sorted()
//            self.handleNames = self.handles.map { $0.name }
            c.activityIndicatorView.isHidden = true
            c.tableView.reloadData()
//        }
    }
}

class NameNewCommunityVC: UIViewController {
     // MARK: - Outlets
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
     // MARK: - Model
    let model = NameCommunityModel()
    
     // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder()
    }

     // MARK: - UITextFieldDelegate
    override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let t = textField.text {
            if t.count > 2 && t.count < 50 {
                if string != "" {
                    activityIndicatorView.isHidden = false
                    model.checkHandle(text: t+string, controller: self)
                } else {
                    let s = t[..<t.endIndex]
                    if !s.isEmpty {
                        activityIndicatorView.isHidden = false
                        model.checkHandle(text: String(s), controller: self)
                    }
                }
            }
        }
        /// UIViewController checks global requirements
        return super.textField(textField, shouldChangeCharactersIn: range, replacementString: string)
    }
}

 // MARK: - UITableViewDelegate, UITableViewDataSource
extension NameNewCommunityVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // send card
//        guard let guildObject = model.guilds .first(where: { $0.name == model.guildNames[indexPath.row] }) else {
//            somebodyScrewedUp()
//            return
//        }
        devNotReady()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.guildNames.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SimpleSearchCell
        cell.basicLabel.text = model.guildNames[indexPath.row]
        return cell
    }
}

