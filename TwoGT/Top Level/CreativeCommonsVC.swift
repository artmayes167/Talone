//
//  CreativeCommonsVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/24/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit

class CreativeCommonsVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var contributors: [Contributor] = [] {
        didSet {
            if isViewLoaded {
                collectionView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        getContributors()
    }
    
    func getContributors() {
        let path = Bundle.main.path(forResource: "creativeCommons", ofType: "json")
        let url = URL.init(fileURLWithPath: path!)
        do {
            let jsonData = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            
            print(jsonData)
            let container = try decoder.decode([String: [[String: String]]].self, from: jsonData) as [String: [[String: String]]]
            print(container)
            let array = container["creativeCommons"]! as Array
            var conts: [Contributor] = []
            for dict in array {
                conts.append(makeContributor(data: dict))
            }
            contributors = conts
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func makeContributor(data: [String: String]) -> Contributor {
        let c = Contributor()
        if let i = data["att"], !i.isEmpty { c.name = i }
        if let s = data["imageName"], !s.isEmpty { c.symbolName = s }
        if let l = data["linkUrl"], !l.isEmpty { c.linkUrl = l }
        return c
    }
}

extension CreativeCommonsVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contributors.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseId = "cell\(indexPath.item%2)"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as! CreativeCommonsCell
       
        cell.configure(contributors[indexPath.row])
       
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let c = contributors[indexPath.item]
        DispatchQueue.main.async {
            if let t = c.linkUrl, let url = URL(string: t) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    self.showOkayAlert(title: "Oops", message: String(format: "\(c.name) has provided a bad link.  You can call them now at 867-5309"), handler: nil)
                }
            } else {
                self.showOkayAlert(title: "Oops", message: String(format: "\(c.name) has not provided a link to any web presence.  Maybe they're not real..."), handler: nil)
            }
        }
    }
}

extension CreativeCommonsVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width - 10
        return CGSize(width: width, height: 106.0)
    }
}

class CreativeCommonsCell: UICollectionViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var symbolImageView: DesignableImage!
    
    func configure(_ contributor: Contributor) {
        if let image = UIImage(named: contributor.symbolName) {
            symbolImageView.image = image
        }
        nameLabel.text = contributor.name
    }
}
