//
//  ContributorsVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/11/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit

class Contributor {
    var name: String?
    //var
}

class ContributorsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

extension ContributorsVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0 //needs.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PurposeCell
       
        //cell.configure(needs[indexPath.item])
       
        return cell
    }
}

extension ContributorsVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: 128.0)
    }
}

class ContributorCell: UICollectionViewCell {
    
    @IBOutlet weak var contributorImage: UIImageView!
    @IBOutlet weak var roleLabel: UILabel!
    
    func configure(_ need: NeedsBase.NeedItem) {
        let size = CGSize(width: 100.0, height: 100.0)
        let aspectScaledToFitImage = UIImage(named: "karlMoline")!.af.imageAspectScaled(toFit: size)
        contributorImage.image = aspectScaledToFitImage
        roleLabel.text = need.description // different identifier needed?
    }
}
