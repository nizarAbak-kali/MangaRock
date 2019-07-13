//
//  MultiContextStack.swift
//  MangaRock
//
//  Created by giang tran on 7/13/19.
//  Copyright © 2019 Vien Tran. All rights reserved.
//

import CoreData

protocol MultiContextStack {
    var viewContext: NSManagedObjectContext { get }
    var writeContext: NSManagedObjectContext { get }
}

extension MultiContextStack {
    ///  Pass objects asynchronously from one context to private context
    ///
    /// - Parameters:
    ///   - objects: objects in another context
    ///   - completion: process objects in private context
    func process<T: NSManagedObject>(_ objects: [T], onPrivate completion: @escaping ([T]) -> ()) {
        process(objects, on: writeContext, completion: completion)
    }
    
    ///  Pass objects asynchronously from one context to main context
    ///
    /// - Parameters:
    ///   - objects: objects in another context
    ///   - completion: process objects in private context
    func process<T: NSManagedObject>(_ objects: [T], onMain completion: @escaping ([T]) ->()) {
        process(objects, on: viewContext, completion: completion)
    }
    
    
    /// Synchronously, return object in main context
    ///
    /// - Parameter privateObject: object in another/private context
    /// - Returns: object in mainContext
    func mainObject<T: NSManagedObject>(for privateObject: T) -> T {
        var mainObject: T!
        viewContext.performAndWait {
            mainObject = viewContext.object(with: privateObject.objectID) as? T
        }
        return mainObject
    }
    
    
    func saveChange() {
        _ = writeContext.saveOrRollback()
    }
    
    //Helper
    private func process<T: NSManagedObject>(_ objects: [T],
                                             on context: NSManagedObjectContext,
                                             completion: @escaping ([T]) ->()) {
        context.perform {
            let objectInNewCtx = objects.map({
                return context.object(with: $0.objectID) as! T
            })
            completion(objectInNewCtx)
        }
    }
}

extension NSManagedObjectContext {
    
    public func insertObject<A: NSManagedObject>() throws -> A where A: ManagedObject {
        guard let obj = NSEntityDescription.insertNewObject(forEntityName: A.entityName, into: self) as? A else {
            assertionFailure()
            throw CoreDataError.wrongObjectModelAndContext
        }
        return obj
    }
    
    public func saveOrRollback() -> Bool {
        do {
            try save()
            return true
        } catch {
            rollback()
            return false
        }
    }
    
    public func performChanges(block: @escaping () -> ()) {
        perform {
            block()
            _ = self.saveOrRollback()
        }
    }
    
}
