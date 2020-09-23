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
    @IBOutlet weak var categoryLabel: UILabel!
    
    var purposes: Set<Purpose>? = {
        return AppDelegate.user.purposes as? Set<Purpose>
    }()

    let spacer = CGFloat(1)
    let numberOfItemsInRow = CGFloat(1)
    
    var needs: [Need] = []
    
     // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = 12
        
        getNeeds()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        populateUI()
    }
    
    func getNeeds() {
        guard let d = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        let managedContext = d.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Need> = Need.fetchRequest()
        do {
            let u = try managedContext.fetch(fetchRequest)
            
            needs = u.filter {
                if let item = $0.needItem {
                    return item.value(forKeyPath: "owner") as? String == AppDelegate.user.handle
                } else {
                    print("----------No needItem found on Need")
                    return false
                }
            }
        } catch _ as NSError {
          fatalError()
        }
        if isViewLoaded {
            collectionView.reloadData()
            populateUI()
        }
    }
    
    func populateUI() {
        categoryLabel.text = "All \(needs.count) of My Needs"
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return needs.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MyNeedCell
        let need = needs[indexPath.item]
        managedObjectContext.refresh(need, mergeChanges: true)
        cell.configure(need.needItem!)
       
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
        return CGSize(width: width, height: 128.0)
    }
}

class MyNeedCell: UICollectionViewCell {
    
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var joinedLabel: UILabel?
    
    func configure(_ need: NeedItem) {
        
        let size = CGSize(width: 128.0, height: 128.0)
        let aspectScaledToFitImage = UIImage(named: (need.category?.lowercased())!)!.af.imageAspectScaled(toFit: size)
        categoryImage.image = aspectScaledToFitImage
        titleLabel.text = need.headline 
        locationLabel.text = need.need?.purpose?.cityState?.displayName()
        let formatter = DateFormatter.sharedFormatter(forRegion: nil, format: "MMMM d, yyyy")
        createdAtLabel.text = formatter.string(from: need.createdAt ?? Date())
        
        // This works and returns [Stat] type
        
        if let cn: Set<Need> = need.need?.childNeeds as? Set<Need> {
            joinedLabel?.text = "\(cn.count)"
        } else {
            joinedLabel?.text = ""
        }
    }
}
