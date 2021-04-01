//
//  CoreDataService.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 19.03.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import CoreData

final class CoreDataService {
    
    // MARK: - Properties
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelName)
        
        container.viewContext.mergePolicy = NSMergePolicy.overwrite
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    private let modelName: String
    
    // MARK: - Initializers
    
    init(modelName: String) {
        self.modelName = modelName
    }
    
    // MARK: - Public methods
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func save(context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func createObject<T: NSManagedObject> (from entity: T.Type) -> T {
        let object = NSEntityDescription.insertNewObject(forEntityName: String(describing: entity),
                                                         into: context) as! T
        return object
    }
    
    func delete(object: NSManagedObject) {
        print(String(describing: object.entity.name!), "Deleting", Thread.current)
        context.delete(object)
        save(context: context)
    }
    
    func fetchData<T: NSManagedObject>(for entity: T.Type,
                                       predicate: NSCompoundPredicate? = nil) -> [T] {
        let request: NSFetchRequest<T>
        var fetchedResult = [T]()
        
        if #available(iOS 10.0, *) {
            request = entity.fetchRequest() as! NSFetchRequest<T>
        } else {
            let entityName = String(describing: entity)
            request = NSFetchRequest(entityName: entityName)
        }
        request.predicate = predicate
        
        do {
            fetchedResult = try self.context.fetch(request)
        } catch {
            debugPrint("Could not fetch: \(error.localizedDescription)")
        }
        return fetchedResult
    }
}
