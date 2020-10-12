//
//  IntroYouVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 10/6/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit

class IntroYouVC: YouVC {
    
    var facebookUserId: String?
    
    var profile: Profile? {
        didSet {
            //facebookUserId = profile?.userID
            if isViewLoaded {
                setProfileData()
            }
            
            // https://developers.facebook.com/docs/swift/reference/structs/userprofile.html/
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setProfileData()
        
        showOkayAlert(title: "this is you".taloneCased(), message: String(format: "the data you input here is not shared with anyone, unless you add it to a template and send it to them.  you can access this section in the future from the dashboard. \n\nif you input any data at this time, we will create a template for you to use.  feel free to view templates and edit them in the cards section. \n\nthe 'no data' template can be used to block other users, and is uneditable.").taloneCased(), handler: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if animated {
            UserDefaults.standard.setValue(nil, forKey: State.stateDefaultsKey.rawValue)
        }
    }
    
    override func setInitialUI() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 62
        handleLabel.text = CoreDataGod.user.handle
    }
    
    func setProfileData() {
        if let p = profile {
            if let imageURL = p.imageURL(forMode: .normal, size: CGSize(width: 150.0, height: 150.0)) {
                let url = imageURL.absoluteURL
                
                imageButton.imageView?.af.setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "avatar.png"), completion:  { response in
                    print(url)
                    do {
                        if let d = response.data, let dataAsImage = UIImage(data: d), let reducedData = try? dataAsImage.heicData(compressionQuality: 0.3) {
                            CoreDataImageHelper.shared.deleteAllImages()
                            CoreDataImageHelper.shared.saveImage(data: reducedData)
                            self.setState()
                            self.showOkayAlert(title: "", message: "Image successfully saved", handler: nil)
                            
                            if let im = CoreDataImageHelper.shared.fetchAllImages() {
                                if let imageFromStorage = im.last?.image {
                                    let i = UIImage(data: imageFromStorage)!.af.imageAspectScaled(toFit: self.imageButton.bounds.size)
                                    self.imageButton.imageView?.contentMode = .scaleAspectFill
                                    self.imageButton.setImage(i, for: .normal)
                                } //
                                
                            } else {
                                self.view.makeToast("Image saving and rerendering failed")
                                self.imageButton.setImage(#imageLiteral(resourceName: "avatar.png"), for: .normal)
                            }
                        } else {
                            print("-------------image data is fucked up after profile image retrieval for url: " + imageURL.absoluteString)
                        }
                    }
                })
            } else {
                print("-------------fucked up on profile image retrieval.")
            }
            // create profile object
            
        }
    }
    
    func setState() {
        let u = UserDefaults.standard
        if u.string(forKey: State.stateDefaultsKey.rawValue) != State.youIntro.rawValue {
            u.setValue(State.youIntro.rawValue, forKey: State.stateDefaultsKey.rawValue)
        }
    }
    
    @IBAction func next(_ sender: UIButton) {
        let a = CoreDataGod.user.allAddresses()
        if a.count > 1 || imageButton.isSelected {
            var imageData: Data?
            if imageButton.imageView!.image != #imageLiteral(resourceName: "avatar.png") {
                if let im = CoreDataImageHelper.shared.fetchAllImages() {
                    if let imageFromStorage = im.first?.image {
                        imageData = imageFromStorage
                    }
                }
            }
            let _ = CardTemplate.create(cardCategory: DefaultTitles.noDataTemplate.rawValue, image: nil)
            let c = CardTemplate.create(cardCategory: "my first template", image: imageData)
            for x in a {
                if let add = x as? Address {
                    c.addToAddresses(add)
                } else if let p = x as? PhoneNumber {
                    c.addToPhoneNumbers(p)
                } else if let e = x as? Email {
                    c.addToEmails(e)
                }
            }
            _ = try? CoreDataGod.managedContext.save()
        }
        let u = UserDefaults.standard
        u.setValue(nil, forKey: State.stateDefaultsKey.rawValue)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        appDelegate.setToFlow(storyboardName: "NoHome", identifier: "Main App VC")
    }
    
    // only save this state if something has been added
    override func unwindToYouVC(_ segue: UIStoryboardSegue) {
        setState()
        tableView.reloadData()
    }
}
