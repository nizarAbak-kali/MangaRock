//
//  ParallelCoredataContext.swift
//  MangaRock
//
//  Created by giang tran on 7/13/19.
//  Copyright © 2019 Vien Tran. All rights reserved.
//

import CoreData

class ParallelCoreData: BaseCoreData, MultiContextStack {
    lazy var writeContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = psc
        
        return context
    }()
    
    lazy var viewContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = psc
        
        return context
    }()
    
    
    override func setupContexts() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(mergeChange(form:)),
                                               name: NSNotification.Name.NSManagedObjectContextDidSave,
                                               object: writeContext)
    }
    
    @objc private func mergeChange(form noti: Notification) {
        viewContext.perform {
            self.viewContext.mergeChanges(fromContextDidSave: noti)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
