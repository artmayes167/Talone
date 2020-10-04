//
//  NeedsSearchDisplayVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/9/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import AlamofireImage

class NeedsSearchDisplayVC: UIViewController {
    
    private var creationManager: PurposeCreationManager?
    private var needs: [NeedsBase.NeedItem] = []
    public func configure(needItems: [NeedsBase.NeedItem], creationManager manager: PurposeCreationManager) {
        self.needs = needItems
        self.creationManager = manager
        if isViewLoaded { collectionView.reloadData() }
    }
    
     // MARK: -
    let spacer = CGFloat(1)
    let numberOfItemsInRow = CGFloat(1)
    
    @IBOutlet weak var collectionView: UICollectionView!
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
    
    private func populateUI() {
        guard let c = creationManager else { fatalError() }
        categoryLabel.text = c.getCategory()?.rawValue.capitalized
        if c.getLocationOrNil() != nil {
            cityStateLabel.text = c.getLocationOrNil()?.displayName()
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewNeed" {
            guard let vc = segue.destination as? ViewIndividualNeedVC, let n = sender as? NeedsBase.NeedItem else { fatalError() }
            vc.needItem = n
            vc.creationManager = creationManager
        }
    }
    
    @IBAction func unwindToSearchDisplay( _ segue: UIStoryboardSegue) {}
}

extension NeedsSearchDisplayVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int { return 1 }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return needs.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PurposeCell
        cell.configure(needs[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "viewNeed", sender: needs[indexPath.item])
    }
}

extension NeedsSearchDisplayVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width = UIScreen.main.bounds.width
        width = (width - spacer)/numberOfItemsInRow
        return CGSize(width: width, height: 128.0)
    }
}

class PurposeCell: UICollectionViewCell {
    
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    func configure(_ need: NeedsBase.NeedItem) {
        let size = CGSize(width: 128.0, height: 128.0)
        let aspectScaledToFitImage = UIImage(named: need.category.lowercased())!.af.imageAspectScaled(toFit: size)
        categoryImage.image = aspectScaledToFitImage
        titleLabel.text = need.description // different identifier needed?
    }
}
