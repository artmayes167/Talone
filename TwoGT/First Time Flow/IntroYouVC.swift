//
//  IntroYouVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 10/6/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit

class IntroYouVC: YouVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showOkayAlert(title: "this is you".taloneCased(), message: String(format: "the data you input here is not shared with anyone, unless you add it to a template and send it to them.  you can access this section in the future from the dashboard. \n\nif you input any data, we will create a template for you to use.  feel free to view templates and edit them in the cards section. \n\nthe 'no data' template can be used to block other users, and is uneditable.").taloneCased(), handler: nil)
    }
    
    @IBAction func next(_ sender: UIButton) {
        let a = CoreDataGod.user.allAddresses()
        if a.count > 1 || imageButton.isSelected {
            var imageData: Data?
            if imageButton.isSelected {
                if let im = CoreDataImageHelper.shareInstance.fetchAllImages() {
                    if let imageFromStorage = im.first?.image {
                        imageData = imageFromStorage
                    }
                }
            }
            let c = CardTemplate.create(cardCategory: "new creation", image: imageData)
            for x in a {
                if let add = x as? Address {
                    c.addToAddresses(add)
                } else if let p = x as? PhoneNumber {
                    c.addToPhoneNumbers(p)
                } else if let e = x as? Email {
                    c.addToEmails(e)
                }
            }
        }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        appDelegate.setToFlow(storyboardName: "NoHome", identifier: "Main App VC")
    }
}
