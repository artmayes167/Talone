//
//  ContactTabBarController.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/30/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit

protocol InteractionDataSource {
    /// Universal, at Interaction level
    func getHandle() -> String
    /// Only for received card
    func getNotes() -> String // TODO: - work on formatting
    func allContactInfo() -> CardTemplateInstance?
    func previouslySentCard() -> Bool
    func getMessage(sender: Bool) -> String
    func saveNotes(_ notes: String)
}

class ContactTabBarController: UITabBarController, InteractionDataSource {
    
    var interaction: Interaction? {
        didSet {
            if isViewLoaded {
                setDataConsumers()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setDataConsumers()
    }
    
    func setDataConsumers() {
        for vc in viewControllers! {
            if let v = vc as? ViewContactVC {
                v.dataSource = self
            }
        }
    }

     // MARK: - InteractionDataSource
    func getHandle() -> String {
        return interaction!.referenceUserHandle! // should crash only if we fucked up
    }
    func getNotes() -> String {
        return interaction?.receivedCard?.personalNotes ?? ""
    }
    func allContactInfo() -> CardTemplateInstance? {
        return interaction?.receivedCard
    }
    func previouslySentCard() -> Bool {
        if let _ = interaction?.cardTemplate { return true }
        return false
    }
    func getMessage(sender: Bool) -> String {
        return sender == true ? (interaction?.receivedCard?.comments ?? "") : (interaction?.cardTemplate?.comments ?? "")
    }
    func saveNotes(_ notes: String) {
        interaction?.receivedCard?.personalNotes = notes
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
            _ = appDelegate.save()
        }
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
