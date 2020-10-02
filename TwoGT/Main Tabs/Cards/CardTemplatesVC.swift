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
            let cards = AppDelegate.user.cardTemplates ?? [] // [Card]
            return cards.isEmpty ? [] : cards.sorted { return $0.title! < $1.title! }
        }
    }
    
    @IBOutlet weak var cardHeaderView: CardPrimaryHeader!
    
    let spacer = CGFloat(0)
    let numberOfItemsInRow = CGFloat(3)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cardHeaderView.setTitleText("templates")
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTemplateDisplay" {
            guard let vc = segue.destination as? ViewMyTemplateVC, let index = sender as? IndexPath else { fatalError() }
            let template = cardTemplates[index.row]
            vc.card = template
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
        
        cell.nameLabel.text = cardTemplates[indexPath.item].title
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toTemplateDisplay", sender: indexPath)
    }
}

extension CardTemplatesVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width = UIScreen.main.bounds.width
        width = (width - spacer)/numberOfItemsInRow
        return CGSize(width: width, height: width)
    }
}

class TemplatesCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
}
