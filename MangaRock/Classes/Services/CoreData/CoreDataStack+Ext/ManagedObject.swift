//
//  ManagedObject.swift
//  MangaRock
//
//  Created by giang tran on 7/13/19.
//  Copyright © 2019 Vien Tran. All rights reserved.
//

import CoreData

public protocol ManagedObject: class, NSFetchRequestResult {
    static var entityName: String { get }
    static var defaultSortDescriptors: [NSSortDescriptor] { get }
    static var defaultPredicate: NSPredicate { get }
    var managedObjectContext: NSManagedObjectContext? { get }
}

extension ManagedObject {
    
    public static var defaultSortDescriptors: [NSSortDescriptor] { return [] }
    public static var defaultPredicate: NSPredicate { return NSPredicate(value: true) }
    
    public static var sortedFetchRequest: NSFetchRequest<Self> {
        let request = NSFetchRequest<Self>(entityName: entityName)
        request.sortDescriptors = defaultSortDescriptors
        request.predicate = defaultPredicate
        return request
    }
    
    public static func sortedFetchRequest(with predicate: NSPredicate) -> NSFetchRequest<Self> {
        let request = sortedFetchRequest
        
        var predicates = [predicate]
        if let existingPredicate = request.predicate {
            predicates.append(existingPredicate)
        }
        
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        return request
    }
    
    public static func predicate(format: String, _ args: CVarArg...) -> NSPredicate {
        let p = withVaList(args) { NSPredicate(format: format, arguments: $0) }
        return predicate(p)
    }
    
    public static func predicate(_ predicate: NSPredicate) -> NSPredicate {
        return NSCompoundPredicate(andPredicateWithSubpredicates: [defaultPredicate, predicate])
    }
    
}


extension ManagedObject where Self: NSManagedObject {
    public static var entityName: String { return description().components(separatedBy: ".").first!  }
    
    public static func delete(in context: NSManagedObjectContext, matching predicate: NSPredicate) throws -> Bool {
        if #available(iOS 9.0, *) {
            let request = NSFetchRequest<Self>(entityName: Self.entityName) as! NSFetchRequest<NSFetchRequestResult>
            request.predicate = predicate
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            let result = try context.execute(batchDeleteRequest) as? NSBatchDeleteResult
            
            let objectIDArray = result?.result as? [NSManagedObjectID]
            let changes = [NSDeletedObjectsKey : objectIDArray ?? []]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes as [AnyHashable : Any], into: [context])
            
            return !(objectIDArray?.isEmpty ?? true)
            
        } else {
            let results = fetch(in: context) { (request) in
                request.predicate = predicate
                request.returnsObjectsAsFaults = true
            }
            
            results.forEach {
                context.delete($0)
            }
            return !results.isEmpty
        }
    }
    
    public static func findOrCreate(in context: NSManagedObjectContext,
                                    matching predicate: NSPredicate,
                                    configure: (Self) -> ()) throws -> Self {
        
        guard let object = findOrFetch(in: context, matching: predicate) else {
            let newObject: Self = try context.insertObject()
            configure(newObject)
            return newObject
        }
        return object
    }
    
    
    public static func findOrFetch(in context: NSManagedObjectContext, matching predicate: NSPredicate) -> Self? {
        guard let object = materializedObject(in: context, matching: predicate) else {
            return fetch(in: context) { request in
                request.predicate = predicate
                request.returnsObjectsAsFaults = false
                request.fetchLimit = 1
                }.first
        }
        return object
    }
    
    public static func fetch(in context: NSManagedObjectContext, configurationBlock: (NSFetchRequest<Self>) -> () = { _ in }) -> [Self] {
        let request = NSFetchRequest<Self>(entityName: Self.entityName)
        configurationBlock(request)
        return try! context.fetch(request)
    }
    
    public static func count(in context: NSManagedObjectContext, configure: (NSFetchRequest<Self>) -> () = { _ in }) -> Int {
        let request = NSFetchRequest<Self>(entityName: entityName)
        configure(request)
        return (try? context.count(for: request)) ?? 0
    }
    
    public static func materializedObject(in context: NSManagedObjectContext, matching predicate: NSPredicate) -> Self? {
        for object in context.registeredObjects where !object.isFault {
            guard let result = object as? Self, predicate.evaluate(with: result) else { continue }
            return result
        }
        return nil
    }
}


extension ManagedObject where Self: NSManagedObject {
    fileprivate static func fetchSingleObject(in context: NSManagedObjectContext, configure: (NSFetchRequest<Self>) -> ()) -> Self? {
        let result = fetch(in: context) { request in
            configure(request)
            request.fetchLimit = 1
        }
        
        return result.first
    }
}
