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
    
    private let persistentContainer: NSPersistentContainer
    private var viewContext: NSManagedObjectContext!
    private var backgroundContext: NSManagedObjectContext!
    
    // MARK: - Initialization
    
    init(modelName: String) {
        self.persistentContainer = NSPersistentContainer(name: modelName)
        createStack()
    }
    
    // MARK: - Public methods
    
    func createObject<T: NSManagedObject>(from entity: T.Type, completion: @escaping (T) -> Void) {
        backgroundContext.perform {
            completion(self.backgroundContext.createObject())
        }
    }
    
    func deleteObjects(_ objects: [NSManagedObject]) {
        backgroundContext.deleteObjects(objects)
    }
    
    func saveChanges() {
        backgroundContext.saveOrRollback()
    }
    
    func fetchData<T: NSManagedObject>(for entity: T.Type, predicate: NSCompoundPredicate? = nil) -> [T] {
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
            fetchedResult = try backgroundContext.fetch(request)
        } catch {
            debugPrint("Could not fetch: \(error.localizedDescription)")
        }
        return fetchedResult
    }
    
    // MARK: - Private methods
    
    func createStack() {
        persistentContainer.loadPersistentStores { [weak self] _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            
            self?.viewContext = self?.persistentContainer.viewContext
            self?.backgroundContext = self?.persistentContainer.newBackgroundContext()
            self?.viewContext.mergePolicy = NSMergePolicy.overwrite
            self?.backgroundContext.mergePolicy = NSMergePolicy.overwrite
            
            let notificationCompletion: (_ notification: Notification) -> Void = { [weak self] notification in
                self?.viewContext.performMergeChangesFromContextDidSaveNotification(notification: notification)
            }
            
            NotificationCenter.default.addObserver(
                forName: .NSManagedObjectContextDidSave,
                object: self?.backgroundContext,
                queue: nil,
                using: notificationCompletion
            )
        }
    }
}
