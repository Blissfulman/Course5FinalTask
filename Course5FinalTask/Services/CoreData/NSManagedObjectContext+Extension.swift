//
//  NSManagedObjectContext+Extension.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 02.04.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    
    func addObject<T: NSManagedObject>() -> T {
        guard let entityName = T.entity().name,
            let object = NSEntityDescription.insertNewObject(forEntityName: entityName, into: self) as? T else {
                fatalError("Can't add object")
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
            if !self.hasChanges {
                return
            }
            
            do {
                print("start saving in \(Thread.isMainThread ? "view" : "background") context")
                try self.save()
                print("Changes saved successfully in \(Thread.isMainThread ? "view" : "background") context")
            } catch {
                print(error.localizedDescription)
                self.rollback()
                print("Saving changes failed in \(Thread.isMainThread ? "view" : "background") context")
            }
        }
    }
    
    func performMergeChangesFromContextDidSaveNotification(notification: Notification) {
        perform {
            print("Start merge in \(Thread.isMainThread ? "view" : "background") context")
            self.mergeChanges(fromContextDidSave: notification)
            print("End merge in \(Thread.isMainThread ? "view" : "background") context")
        }
    }
}
