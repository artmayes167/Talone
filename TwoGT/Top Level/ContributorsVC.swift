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

class Contributor {
    var name: String = "None Available"
    var imageUrl: String?
    var imageName: String = "avatar"
    var role: String?
    var linkUrl: String?
    var symbolName: String = "square"
}

class ContributorsVC: UIViewController {
    
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
        let path = Bundle.main.path(forResource: "contributors", ofType: "json")
        let url = URL.init(fileURLWithPath: path!)
        do {
            let jsonData = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            
            print(jsonData)
            let container = try decoder.decode([String: [String: [String: String]]].self, from: jsonData) as [String: [String: [String: String]]]
            print(container)
            let dict = container["contributors"]! as NSDictionary
            let keys = dict.allKeys
            var conts: [Contributor] = []
            for key in keys {
                conts.append(makeContributor(name: ((key as? String)!), data: dict))
            }
            conts.sort { $0.name < $1.name }
            contributors = conts
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func makeContributor(name: String, data: NSDictionary) -> Contributor {
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}

extension ContributorsVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


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
        if let t = c.linkUrl, let url = URL(string: t) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                showOkayAlert(title: "Oops", message: String(format: "\(c.name) has provided a bad link.  You can call them now at 867-5309"), handler: nil)
            }
        } else {
            showOkayAlert(title: "Oops", message: String(format: "\(c.name) has not provided a link to any web presence.  Maybe they're not real..."), handler: nil)
        }
    }
}

extension ContributorsVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width - 10
        return CGSize(width: width, height: 128.0)
    }
}

class ContributorCell: UICollectionViewCell {
    
    @IBOutlet weak var contributorImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!
    @IBOutlet weak var symbolImageView: DesignableImage!
    
    
    func configure(_ contributor: Contributor) {
        //let size = CGSize(width: 200.0, height: 200.0)
        
        if let url = contributor.imageUrl {
            if let imageURL = URL(string: url), let placeholder = UIImage(named: contributor.imageName) {
                contributorImage.af.setImage(withURL: imageURL, placeholderImage: placeholder)
            }
        } else {
            if let image = UIImage(named: contributor.imageName) {
                //let aspectScaledToFitImage = image.af.imageAspectScaled(toFit: size)
                contributorImage.image = image //aspectScaledToFitImage
            }
        }
        
        nameLabel.text = contributor.name
        roleLabel.text = contributor.role
        symbolImageView.image = UIImage(named: contributor.symbolName)
    }
}
