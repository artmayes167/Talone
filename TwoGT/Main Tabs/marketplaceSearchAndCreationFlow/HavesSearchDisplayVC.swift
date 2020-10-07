//
//  HavesSearchDisplayVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/15/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import AlamofireImage

class HavesSearchDisplayVC: UIViewController {
    let spacer = CGFloat(1)
    let numberOfItemsInRow = CGFloat(1)
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var creationManager: PurposeCreationManager?
    private var haves: [HavesBase.HaveItem] = []
    public func configure(haveItems: [HavesBase.HaveItem], creationManager manager: PurposeCreationManager) {
        self.haves = haveItems
        self.creationManager = manager
        if isViewLoaded { collectionView.reloadData() }
    }
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var cityStateLabel: UILabel!
    
     // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = 12
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        populateUI()
    }
    
    func populateUI() {
        guard let c = creationManager else { fatalError() }
        categoryLabel.text = "Have: " + c.getCategory()!.rawValue
        if c.getLocationOrNil() != nil {
            cityStateLabel.text = c.getLocationOrNil()?.displayName().taloneCased()
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewHave" {
            guard let vc = segue.destination as? ViewIndividualHaveVC, let h = sender as? HavesBase.HaveItem, let c = creationManager else { fatalError() }
            vc.configure(haveItem: h, creationManager: c)
        }
    }
    
     @IBAction func unwindToSearchDisplay( _ segue: UIStoryboardSegue) {}
}

extension HavesSearchDisplayVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int { return 1 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return haves.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! HaveCell
        cell.configure(haves[indexPath.item], row: indexPath.row)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "viewHave", sender: haves[indexPath.item])
    }
}

extension HavesSearchDisplayVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width = UIScreen.main.bounds.width
        width = (width - spacer)/numberOfItemsInRow
        return CGSize(width: width, height: 50.0)
    }
}

class HaveCell: UICollectionViewCell {
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    func configure(_ have: HavesBase.HaveItem, row: Int) {
        let aspectScaledToFitImage = UIImage(named: have.category.lowercased())
        categoryImage.image = aspectScaledToFitImage
        categoryImage.tintColor = [UIColor.red.withAlphaComponent(0.77), UIColor.blue.withAlphaComponent(0.77)][row%2]
        titleLabel.text = have.description // different identifier needed?
    }
}
