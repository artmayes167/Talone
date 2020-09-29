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
    @IBOutlet weak var pageHeader: PageHeader!

    var purposes: Set<Purpose>? = {
        return AppDelegate.user.purposes as? Set<Purpose>
    }()

    let spacer = CGFloat(1)
    let numberOfItemsInRow = CGFloat(1)

    var haves: [Have] = []

     // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = 12

        getHaves()
        // Temporary
        HavesDbFetcher().observeMyHaves { fibHaveItems in
            for have in self.haves {
                for fibHave in fibHaveItems where fibHave.id == have.haveItem?.id {
                    if let needStubs = fibHave.needs {

                        let cdNeeds = have.childNeeds

                        for needStub in needStubs {
                            for cdNeed in cdNeeds {
                                if cdNeed.needItem?.id == needStub.id {

                                }
                            }
                            print(needStub.createdBy)
                            print(needStub.id)
                            print(needStub.owner)
                            //cdNeeds.append(createNeed) <== Need that has only three values, see above
                        }
                        have.childNeeds = cdNeeds

                    }
                }
            }

        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        populateUI()
    }

    func getHaves() {
        guard let d = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        let managedContext = d.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Have> = Have.fetchRequest()
        do {
            let u = try managedContext.fetch(fetchRequest)

            haves = u.filter {
                if let item = $0.haveItem {
                    return item.value(forKeyPath: "owner") as? String == AppDelegate.user.handle
                } else {
                    print("----------No haveItem found on have")
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
        pageHeader.setTitleText("All \(haves.count) of My Haves")
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewHave" {
            guard let vc = segue.destination as? ViewMyHaveVC, let h = sender as? Have else { fatalError() }
            vc.have = h
        }
    }

    @IBAction func unwindToMyHaves( _ segue: UIStoryboardSegue) {
        getHaves()
    }

}

extension MyHavesSearchDisplayVC: UICollectionViewDelegate, UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return haves.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        let managedObjectContext = appDelegate.persistentContainer.viewContext

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MyHaveCell
        let have = haves[indexPath.item]
        managedObjectContext.refresh(have, mergeChanges: true)

        cell.configure(have.haveItem!)

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
        return CGSize(width: width, height: 128.0)
    }
}

class MyHaveCell: UICollectionViewCell {

    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!

    func configure(_ have: HaveItem) {

        let size = CGSize(width: 128.0, height: 128.0)
        let aspectScaledToFitImage = UIImage(named: (have.category?.lowercased())!)!.af.imageAspectScaled(toFit: size)
        categoryImage.image = aspectScaledToFitImage
        titleLabel.text = have.headline
        locationLabel.text = have.have?.purpose?.cityState?.displayName()
        let formatter = DateFormatter.sharedFormatter(forRegion: nil, format: "MMMM d, yyyy")
        createdAtLabel.text = formatter.string(from: have.createdAt ?? Date())
    }
}
