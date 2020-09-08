//
//  NewsFeedFetcher.swift
//  TwoGT
//
//  Created by Jyrki Hoisko on 9/7/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import Foundation

import FirebaseFirestore
import FirebaseFirestoreSwift

class NewsFeedFetcher {

    struct NewsItem: Codable {
        var category: String
        var description: String
        var validUntil: Int
    }

    var latestNews = [NewsItem]()

    func fetchNews(completion: @escaping ([NewsItem]) -> Void) {
        let db = Firestore.firestore()

        db.collection("news").whereField("locationCity", isEqualTo: "Chicago").getDocuments { (snapshot, error) in
            if let error = error {
                print(error)
            } else if let snapshot = snapshot {
                let news = snapshot.documents.compactMap { (document) -> NewsItem? in
                    print(document)
                    var item: NewsItem?
                    do {
                        item = try document.data(as: NewsItem.self)
                    } catch {
                        print(error)
                    }
                    return item
                }
                completion(news)
            }
        }
    }
}
