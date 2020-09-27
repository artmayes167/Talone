//
//  AllReceivedCardsVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/26/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit

class AllReceivedCardsVC: UIViewController {

    @IBOutlet weak var cardHeaderView: CardPrimaryHeader!
    override func viewDidLoad() {
        super.viewDidLoad()
        cardHeaderView.setTitleText("all cards")
        // Do any additional setup after loading the view.
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
