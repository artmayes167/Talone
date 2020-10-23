//
//  CreateNewContactVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 10/22/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit

class CreateContactModel {
    
    var handleNames: [String] = []
    var handles: [UserHandlesDbHandler.UserHandle] = []
    
    func checkHandle(text t: String, tableView: UITableView) {
        let handleHandler = UserHandlesDbHandler()
        handleHandler.fetchUserHandles(startingWith: t, maxCount: 100) { (userHandles) in
            self.handles = userHandles.sorted()
            self.handleNames = self.handles.map { $0.name }
            tableView.reloadData()
        }
    }
}

class CreateNewContactVC: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    let model = CreateContactModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder()
    }

    override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let t = textField.text {
            if t.count > 2 && t.count < 50 {
                if string != "" {
                    model.checkHandle(text: t+string, tableView: tableView)
                }
            }
            else if (t.count > 49) && string != "" { return false }
        }
        return true
    }
}

extension CreateNewContactVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // send card
        guard let handleObject = model.handles .first(where: { $0.name == model.handleNames[indexPath.row] }) else {
            somebodyScrewedUp()
            return
        }
        showCompleteAndSendCardHelper(handle: handleObject.name, uid: handleObject.uid!)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.handleNames.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SimpleSearchCell
        cell.basicLabel.text = model.handleNames[indexPath.row]
        return cell
    }
}
