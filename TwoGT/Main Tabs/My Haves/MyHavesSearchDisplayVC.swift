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
        getHaves()                  // load from CoreData
        startObservingHaveChanges() // sync with Firebase

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

    private func startObservingHaveChanges() {
        // Temporary location - TODO: Refactor. When should Have owner be notified of new links/people in need?
        HavesDbFetcher().observeMyHaves { [self] fibHaveItems in

            var addedNeedOwners = [String]()
            var changedHaves = [HaveItem]()
            var isRedrawRequired = false

            // Cross-reference needs
            for have in self.haves {
                for fibHave in fibHaveItems where fibHave.id == have.haveItem?.id {
                    if let needStubs = fibHave.needs, let haveItem = have.haveItem {
                        var isChanged = false
                        changedHaves.append(haveItem)   // for showing on UI

                        let cdNeeds = have.childNeeds

                        // First determine if there are any new needStubs that are missing from CD
                        // These are the people that have linked with this have.
                        for needStub in needStubs {
                            var found = false
                            for cdNeed in cdNeeds where cdNeed.needItem?.id == needStub.id {
                                found = true
                                break
                            }
                            if found == false {
                                // create a new need (gets appended to childItems implicitly)
                                var fibNeed = NeedsBase.NeedItem(category: fibHave.category, validUntil: fibHave.validUntil!, owner: needStub.owner, createdBy: needStub.createdBy, locationInfo: fibHave.locationInfo).self
                                fibNeed.id = needStub.id // overwrite the implicit Id to reflect existing id.
                                let n = Need.createNeed(item: NeedItem.createNeedItem(item: fibNeed))
                                n.parentHaveItemId = fibHave.id
                                addedNeedOwners.append(fibNeed.owner)
                                isChanged = true
                            }
                        }

                        // Then determine if there are needStubs being deleted requiring cleanup from CD.
                        // These are the people that have removed the link with this have.
                        for cdNeed in cdNeeds {
                            var found = false
                            for needStub in needStubs where needStub.id == cdNeed.needItem?.id {
                                found = true
                                break
                            }
                            if found == false {
                                cdNeed.deleteNeed()
                                isChanged = true
                            }
                        }
                        if isChanged { haveItem.update(); isRedrawRequired = true } // store changes to CD
                    }
                }
            }
            if isRedrawRequired { collectionView.reloadData() }
            notifyUserOfNewLinks(addedNeedOwners, changedHaves)
        }
    }

    func notifyUserOfNewLinks(_ owners: [String], _ haveItems: [HaveItem]) {
        if owners.count > 0 {
            var str = ""
            let haveDesc = haveItems.count == 1 ? (haveItems[0].headline ?? haveItems[0].desc ?? "") : "haves."
            switch owners.count {
            case 1:
                str = "\(owners[0]) is interested in your \(haveDesc)"
            case 2:
                str = "\(owners[0]) and \(owners[1]) have linked to your \(haveDesc)"
            default:
                str = "\(owners[0]), \(owners[1]) and \(owners.count-2) others have linked to your \(haveDesc)"
            }
            // Show Toast
            self.view.makeToast(str, duration: 2.0, position: .top) {_ in
            }

        }
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
    @IBOutlet weak var joinedLabel: UILabel?

    func configure(_ have: HaveItem) {

        let size = CGSize(width: 128.0, height: 128.0)
        let aspectScaledToFitImage = UIImage(named: (have.category?.lowercased())!)!.af.imageAspectScaled(toFit: size)
        categoryImage.image = aspectScaledToFitImage
        titleLabel.text = have.headline
        locationLabel.text = have.have?.purpose?.cityState?.displayName()
        let formatter = DateFormatter.sharedFormatter(forRegion: nil, format: "MMMM d, yyyy")
        createdAtLabel.text = formatter.string(from: have.createdAt ?? Date())

        // This works and returns [Need] type

        if let cn = have.have?.childNeeds, !cn.isEmpty {
            joinedLabel?.text = "\(cn.count)"
        } else {
            joinedLabel?.text = ""
        }
    }
}
