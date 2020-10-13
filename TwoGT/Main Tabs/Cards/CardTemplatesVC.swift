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
    
    private var cardTemplates: [CardTemplate] {
        get {
            var cards: [CardTemplate] = []
//            AppDelegateHelper.managedContext.refreshAllObjects()
            let c: [CardTemplate] = AppDelegateHelper.user.cardTemplates ?? [] // [Card]
            
            /// Only templates, not instances
            if !c.isEmpty {
                cards = c.filter { $0.entity.name != CardTemplateInstance().entity.name }
            }
            
            return cards.isEmpty ? [] : cards.sorted { return $0.templateTitle! < $1.templateTitle! }
        }
    }
    
    @IBOutlet weak var cardHeaderView: CardPrimaryHeader!
    
    let spacer = CGFloat(5)
    let numberOfItemsInRow = CGFloat(3)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cardHeaderView.setTitleText("templates")
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets(top: spacer, left: spacer, bottom: spacer, right: spacer)
        layout.minimumInteritemSpacing = spacer
        layout.minimumLineSpacing = spacer
    }
    

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMyTemplate" {
            guard let vc = segue.destination as? MyTemplateVC, let index = sender as? IndexPath else { fatalError() }
            let template = cardTemplates[index.item]
            vc.template = template
        }
    }
    

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
        
        cell.nameLabel.text = cardTemplates[indexPath.item].templateTitle
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if cardTemplates[indexPath.item].templateTitle == "no data" {
            showOkayAlert(title: "no data template".taloneCased(), message: "this template is designed to be used to communicate without disclosing any data about yourself, except your handle. Sending someone this template will effectively block them from communicating with you.  use it wisely.".taloneCased(), handler: nil)
            return
        }
        performSegue(withIdentifier: "toMyTemplate", sender: indexPath)
    }
}

extension CardTemplatesVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width = collectionView.frame.size.width
        width = (width - (spacer * (numberOfItemsInRow + 1)))/numberOfItemsInRow
        return CGSize(width: width, height: width)
    }
}

class TemplatesCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
}
