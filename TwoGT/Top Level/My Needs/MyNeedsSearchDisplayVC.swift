//
//  MyNeedsSearchDisplayVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/18/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import SwiftDate
import CoreData

class MyNeedsSearchDisplayVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageHeader: PageHeader!

    let spacer = CGFloat(1)
    let numberOfItemsInRow = CGFloat(1)
    
    var needs: [Need] = []
    
     // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 2
        
        getNeeds()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        populateUI()
    }
    
    func getNeeds() {
        
        let fetchRequest: NSFetchRequest<Need> = Need.fetchRequest()
        do {
            let u = try CoreDataGod.managedContext.fetch(fetchRequest)
            needs = u.filter {
                return $0.owner == CoreDataGod.user.handle
            }
        } catch {
          fatalError()
        }
        if isViewLoaded {
            collectionView.reloadData()
            populateUI()
        }
    }
    
    func populateUI() {
        pageHeader.setTitleText("All \(needs.count) of My Needs") 
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewNeed" {
            guard let vc = segue.destination as? ViewMyNeedVC, let n = sender as? Need else { fatalError() }
            vc.need = n
        }
    }
    
    @IBAction func unwindToMyNeeds( _ segue: UIStoryboardSegue) {
        getNeeds()
    }

}

extension MyNeedsSearchDisplayVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int { return 1 }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return needs.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MyNeedCell
        let need = needs[indexPath.item]
        managedObjectContext.refresh(need, mergeChanges: true)
        cell.configure(need, indexPath: indexPath)
       
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "viewNeed", sender: needs[indexPath.item])
    }
}

extension MyNeedsSearchDisplayVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width = UIScreen.main.bounds.width
        width = (width - spacer)/numberOfItemsInRow
        return CGSize(width: width, height: 75.0)
    }
}

class MyNeedCell: UICollectionViewCell {
    
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var joinedLabel: UILabel?
    
    func configure(_ need: Need, indexPath: IndexPath) {
        categoryImage.image = UIImage(named: (need.category?.lowercased())!)
        titleLabel.text = need.headline 
        locationLabel.text = need.location?.displayName() ?? "Saved before location worked"
        let formatter = DateFormatter.sharedFormatter(forRegion: nil, format: "MMMM d, yyyy")
        createdAtLabel.text = formatter.string(from: need.createdAt ?? Date())
        
        var bgColor: UIColor = .white
        switch indexPath.row%2 {
        case 0:
            bgColor = UIColor.hex("EAB1FF")
        case 1:
            bgColor = UIColor.hex("AAD6A0")
        default:
            print("somehow, the remainder of dividing by two is larger than one")
        }
        contentView.backgroundColor = bgColor
        
        var color: UIColor = .darkGray
        switch indexPath.row%2 {
        case 0:
            color = UIColor.hex("717F6E")
        case 1:
            color = UIColor.hex("5D2126")
        default:
            print("somehow, the remainder of dividing by two is larger than one")
        }
        categoryImage.tintColor = color

        if let cn = need.childNeeds, !cn.isEmpty {
                if cn.count > 1 {
                    joinedLabel?.text = "\(cn.count) people watching"
                } else {
                    joinedLabel?.text = "1 person watching"
                }
        } else {
            joinedLabel?.text = "nobody's watching yet"
        }
    }
}
