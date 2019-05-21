//
//  CoreDataService.swift
//  NotesForEvo
//
//  Created by Alexandr Kurylenko on 5/17/19.
//  Copyright © 2019 Alexandr Kurylenko. All rights reserved.
//
//

import Foundation
import CoreData

protocol CoreDataProtocol {
    var managedObjectContext: NSManagedObjectContext { get }
    func saveContext()
}

class CoreDataService: CoreDataProtocol {
    
    static let shared: CoreDataProtocol = CoreDataService()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "NotesForEvo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var managedObjectContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        managedObjectContext.performSaveOrRollback()
    }
    
}
