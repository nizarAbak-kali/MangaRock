//
//  BaseCoreDataStack.swift
//  MangaRock
//
//  Created by giang tran on 7/13/19.
//  Copyright © 2019 Vien Tran. All rights reserved.
//

import CoreData

class BaseCoreData {
    class var documentUrl: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    private var modelName: String
    private var storageType: String
    
    public let psc: NSPersistentStoreCoordinator
    
    init(withModelName modelName: String, sqlName: String, storageType: String = NSSQLiteStoreType) throws {
        self.modelName = modelName
        self.storageType = storageType
        
        guard let modelUrl = Bundle.main.url(forResource: modelName, withExtension: "momd") else {
            throw CoreDataError.wrongObjectModelPath
        }
        
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelUrl) else {
            throw CoreDataError.invalidObjectModelFile
        }
        
        psc = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let storageUrl = storageType == NSSQLiteStoreType ? BaseCoreData.documentUrl.appendingPathComponent("\(sqlName).sqlite") : nil
        
        let mOptions = [NSMigratePersistentStoresAutomaticallyOption: true,
                        NSInferMappingModelAutomaticallyOption: true]
        
        try psc.addPersistentStore(ofType: storageType,
                                   configurationName: nil,
                                   at: storageUrl,
                                   options: mOptions)
        
        setupContexts()
    }
    
    func setupContexts() {
        
    }
}

