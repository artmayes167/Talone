//
//  MyHavesSearchDisplayVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/18/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import CoreData

class MyHavesSearchDisplayVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    let spacer = CGFloat(2)
    let numberOfItemsInRow = CGFloat(1)

    var haves: [Have] = []

     // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 2
        getHaves()
        AppDelegate.linkedNeedsObserver.registerForUpdates(self)    // register to receive any updates in linked needs.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        populateUI()
    }
    
    func getHaves() {
        
        let fetchRequest: NSFetchRequest<Have> = Have.fetchRequest()
        do {
            let u = try CoreDataGod.managedContext.fetch(fetchRequest)
            haves = u.filter {
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
//        pageHeader.setTitleText("All \(haves.count) of My Haves")
        collectionView.reloadData()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewHave" {
            guard let vc = segue.destination as? ViewMyHaveVC, let h = sender as? Have else { fatalError() }
            vc.have = h
        }
    }

//    @IBAction func unwindToMyHaves( _ segue: UIStoryboardSegue) {
//        getHaves()
//    }
}

extension MyHavesSearchDisplayVC: UICollectionViewDelegate, UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return haves.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let managedObjectContext = CoreDataGod.managedContext
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MyHaveCell
        let have = haves[indexPath.item]
        managedObjectContext.refresh(have, mergeChanges: true)

        cell.configure(have, indexPath: indexPath)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "viewHave", sender: haves[indexPath.item])
    }
}

extension MyHavesSearchDisplayVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width = UIScreen.main.bounds.width
        width = (width - spacer)/numberOfItemsInRow
        return CGSize(width: width, height: 75.0)
    }
}

/**
 Observe if any linked needs are removed or added while user is on this ViewController. Not likely to happen, but useful during testing.
 */
extension MyHavesSearchDisplayVC: LinkedNeedsCountChangeDetectable {
    func havesLinkedNeedsCountChanged() {
        collectionView.reloadData()
    }
}

class MyHaveCell: UICollectionViewCell {

    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var joinedLabel: UILabel?

    func configure(_ have: Have, indexPath: IndexPath) {
        categoryImage.image = UIImage(named: (have.category?.lowercased())!)
        titleLabel.text = have.headline
        locationLabel.text = have.location?.displayName()
        let formatter = DateFormatter.sharedFormatter(forRegion: nil, format: "MMMM d, yyyy")
        createdAtLabel.text = formatter.string(from: have.createdAt ?? Date())
        
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

        if let cn = have.childNeeds, !cn.isEmpty {
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
