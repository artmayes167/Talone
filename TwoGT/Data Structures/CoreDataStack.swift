/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import CoreData

//protocol UsesCoreDataObjects: class {
//  var managedObjectContext: NSManagedObjectContext? { get set }
//}

class CoreDataStack {

//  private let modelName: String
//
//  init(modelName: String) {
//    self.modelName = modelName
//  }
//
//  lazy var managedContext: NSManagedObjectContext = self.storeContainer.viewContext
////  var savingContext: NSManagedObjectContext {
////    return storeContainer.newBackgroundContext()
////  }
//  
//  private lazy var storeContainer: NSPersistentCloudKitContainer = {
//    let container = NSPersistentCloudKitContainer(name: "TwoGT")
//    if let f = container.persistentStoreDescriptions.first {
//        f.shouldInferMappingModelAutomatically = true
////        f.shouldMigrateStoreAutomatically = true
//    }
//    container.loadPersistentStores { (description, error) in
//      if let error = error {
//        fatalError("Unresolved error \(error)")
//      } else {
//        print("-------------description = \(description), ------------stores = \(container.persistentStoreCoordinator)")
//      }
//    }
//    container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
//    getCoreDataDBPath()
//    return container
//  }()
//    
//    func getCoreDataDBPath() {
//        let path = FileManager
//            .default
//            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
////            .last?
////            .absoluteString
////            .replacingOccurrences(of: "file://", with: "")
////            .removingPercentEncoding
//        
//        for url in path {
//            print("----------------CoreData DB path: " + url.absoluteString)
//        }
//        //print("Core Data DB Path :: \(path ?? "Not found")")
//    }
//
//  func saveContext () {
//    guard managedContext.hasChanges else { return }
//
//    try? managedContext.save()
//  }
}
