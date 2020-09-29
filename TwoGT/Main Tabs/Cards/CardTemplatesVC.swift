//
//  CardTemplatesVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/26/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit

class CardTemplatesVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var cardTemplates: [Card] {
        get {
            let cards = AppDelegate.user.cardTemplates
            return cards.sorted { return $0.title! < $1.title! }
        }
    }
    
    @IBOutlet weak var cardHeaderView: CardPrimaryHeader!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cardHeaderView.setTitleText("templates")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func unwindToCardTemplates( _ segue: UIStoryboardSegue) {
        collectionView.reloadData()
    }
}

extension CardTemplatesVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cardTemplates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseIdentifier = String(format: "cell%i", indexPath.item%2)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TemplatesCollectionViewCell
        
        cell.nameLabel.text = cardTemplates[indexPath.item].title
        return cell
    }
}

class TemplatesCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
}
