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
    let spacer = CGFloat(12 * 2)
    @IBOutlet weak var collectionView: UICollectionView!
    var uiTuple: (String, String, String)?
    var needs: [NeedsBase.NeedItem] = [] {
        didSet {
            if isViewLoaded {
                collectionView.reloadData()
            }
        }
    }
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var cityStateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = 12
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let (category, city, state) = uiTuple else { return }
        categoryLabel.text = category
        cityStateLabel.text = city + ", " + state
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    

}

extension NeedsSearchDisplayVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return needs.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PurposeCell
       
        cell.configure(needs[indexPath.item])
       
        return cell
    }
}

extension NeedsSearchDisplayVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width = UIScreen.main.bounds.width
        width = (width - spacer)/3
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
        titleLabel.text = need.owner // different identifier needed?
    }
}