//
//  NSManagedObjectContext+Extension.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 02.04.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import CoreData

extension NSManagedObjectContext {
    
    func createObject<T: NSManagedObject>() -> T {
        guard let entityName = T.entity().name,
            let object = NSEntityDescription.insertNewObject(forEntityName: entityName, into: self) as? T else {
                fatalError("Can't insert new object")
        }
        return object
    }
    
    func deleteObjects(_ objects: [NSManagedObject]) {
        perform {
            objects.forEach { self.delete($0) }
        }
    }
    
    func saveOrRollback() {
        perform {
            guard self.hasChanges else { return }
            
            do {
                try self.save()
            } catch {
                print("Saving changes failed with error:", error.localizedDescription)
                self.rollback()
            }
        }
    }
    
    func performMergeChangesFromContextDidSaveNotification(notification: Notification) {
        perform {
            self.mergeChanges(fromContextDidSave: notification)
        }
    }
}
