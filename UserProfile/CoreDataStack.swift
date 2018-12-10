//
//  CoreDataStack.swift
//  UserProfile
//
//  Created by Jake Swedenburg on 12/5/18.
//  Copyright © 2018 Jake Swedenburg. All rights reserved.
//

import Foundation
import CoreData

struct CoreDataStack {
    
    static let container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "UserProfile")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    static var context: NSManagedObjectContext { return container.viewContext }
    
    // MARK: - Core Data Saving support
    static func saveContext () {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    static func executeDeleteRequest(request: NSBatchDeleteRequest) {
        do {
            try context.execute(request)
        } catch {
            fatalError("Failed to execute request: \(error)")
        }
    }
    
}
