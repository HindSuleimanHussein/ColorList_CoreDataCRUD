//
//  CoreDataStack.swift
//  ColorsTask
//
//  Created by Foothill on 04/10/2023.
//

import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MyAppColorDataModel")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                fatalError("Unresolved error")
            }
        }
        return container
    }()

    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

