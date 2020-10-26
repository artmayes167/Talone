//
//  ItemsTVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 10/17/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit

// MARK: -
protocol NeedSelectionDelegate {
   func didSelect(_ need: NeedType)
}

// MARK: -
class NeedTypeTVC: UITableViewController {
   var delegate: NeedSelectionDelegate?
   var needs: [NeedType] = NeedType.allCases

   override func viewDidLoad() {
       super.viewDidLoad()
       tableView.reloadData()
   }

   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       delegate?.didSelect(needs[indexPath.row])
   }

   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return needs.count
   }

   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SimpleSearchCell
       cell.basicLabel.text = needs[indexPath.row].rawValue
       return cell
   }
}

class SimpleSearchCell: UITableViewCell {
   @IBOutlet weak var basicLabel: UILabel!
   @IBOutlet weak var colorBar: UIView!
}
