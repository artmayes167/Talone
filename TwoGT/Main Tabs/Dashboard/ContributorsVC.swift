//
//  ContributorsVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/11/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

final class Contributor {
    var name: String = "None Available"
    var imageUrl: String?
    var imageName: String = "avatar"
    var role: String?
    var linkUrl: String?
    var symbolName: String = "square"
}

final class ContributorsVC: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var contributors: [Contributor] = [] {
        didSet { if isViewLoaded { collectionView.reloadData() } }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        getContributors()
    }
    
    private func getContributors() {
        let path = Bundle.main.path(forResource: "contributors", ofType: "json")
        let url = URL.init(fileURLWithPath: path!)
        do {
            let jsonData = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let container = try decoder.decode([String: [String: [String: String]]].self, from: jsonData) as [String: [String: [String: String]]]
            let dict = container["contributors"]! as NSDictionary
            let keys = dict.allKeys
            var conts: [Contributor] = []
            for key in keys {
                conts.append(makeContributor(name: ((key as? String)!), data: dict))
            }
            conts.sort { $0.name < $1.name }
            contributors = conts
        } catch {
            self.somebodyScrewedUp()
        }
    }
    
    private func makeContributor(name: String, data: NSDictionary) -> Contributor {
        let c = Contributor()
        c.name = name
        let d = data[name] as! NSDictionary
        if let n = d["imageName"] as? String, !n.isEmpty { c.imageName = n }
        if let i = d["imageUrl"] as? String, !i.isEmpty { c.imageUrl = i }
        if let l = d["linkUrl"] as? String, !l.isEmpty { c.linkUrl = l }
        if let r = d["role"] as? String, !r.isEmpty { c.role = r }
        if let s = d["symbolName"] as? String, !s.isEmpty { c.symbolName = s }
        return c
    }

    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

extension ContributorsVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int { return 1 }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contributors.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseId = "cell\(indexPath.item%2)"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as! ContributorCell
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
                    self.somebodyScrewedUp()
                }
            } else {
                self.somebodyScrewedUp()
            }
        }
    }
}

extension ContributorsVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        /// Replace this with ios14 implementation, as soon as it's viable
        let width = collectionView.frame.size.width - 10
        let x = contributors[indexPath.row].role
        var z = CGFloat(x?.count ?? 100)
        z = CGFloat(z/30 * 14)
        return CGSize(width: width, height: z + 100.0)
    }
}

final class ContributorCell: UICollectionViewCell {
    @IBOutlet weak var contributorImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!
    @IBOutlet weak var symbolImageView: DesignableImage!
    
    func configure(_ contributor: Contributor) {
        if let url = contributor.imageUrl {
            if let imageURL = URL(string: url) {
                contributorImage.af.setImage(withURL: imageURL, placeholderImage: #imageLiteral(resourceName: "avatar.png"))
            } else {
                contributorImage.image = #imageLiteral(resourceName: "avatar.png")
            }
        } else {
            if let image = UIImage(named: contributor.imageName) {
                contributorImage.image = image
            } else {
                contributorImage.image = #imageLiteral(resourceName: "avatar.png")
            }
        }
        nameLabel.text = contributor.name
        roleLabel.text = contributor.role
        symbolImageView.image = UIImage(named: contributor.symbolName)
    }
}
