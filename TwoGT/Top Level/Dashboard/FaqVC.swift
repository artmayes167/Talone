//
//  FaqVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 10/10/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit

class Faq {
    var question: String = "None Available"
    var answer: String = "None Available"
}

class FaqVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var faqs: [Faq] = [] {
        didSet { if isViewLoaded { tableView.reloadData() } }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        getFaqs()
    }
    
    func getFaqs() {
        let path = Bundle.main.path(forResource: "faq", ofType: "json")
        let url = URL.init(fileURLWithPath: path!)
        do {
            let jsonData = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            
            print(jsonData)
            let container = try decoder.decode([String: [[String: String]]].self, from: jsonData) as [String: [[String: String]]]
            print(container)
            let array = container["faqs"]! as Array
            var conts: [Faq] = []
            for dict in array {
                conts.append(makeFaq(data: dict))
            }
            faqs = conts
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func makeFaq(data: [String: String]) -> Faq {
        let f = Faq()
        if let i = data["question"], !i.isEmpty { f.question = i }
        if let s = data["answer"], !s.isEmpty { f.answer = s }
        return f
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

extension FaqVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return faqs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! FaqCell
        cell.configure(faqs[indexPath.row])
        return cell
    }
}

class FaqCell: UITableViewCell {
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    
    func configure(_ faq: Faq) {
        questionLabel.text = faq.question
        answerLabel.text = faq.answer
    }
}
