//
//  ServerUpdatable.swift
//  MangaRock
//
//  Created by giang tran on 7/13/19.
//  Copyright © 2019 Vien Tran. All rights reserved.
//

import Foundation
import CoreData

enum ChangeAction {
    case update
    case delete
    case create
    case none
}

protocol ServerUpdatable: class, ServerModelProtocol {
    associatedtype ServerModel: ServerModelProtocol
    
    @discardableResult func updateIfNeededWith(serverModel: ServerModel, with action: ChangeAction) -> Self?
}

extension ServerUpdatable {
    func needUpdate(with serverModel: ServerModelProtocol) -> Bool {
        guard serverModel.serverID == serverID else {  // ensure this object matches with serverModel
            assertionFailure(); return false
        }
        
        return serverModel.updateTime > updateTime
    }
}

protocol CoreDataServerUpdatable: ServerUpdatable {
    @discardableResult func updateIfNeededWith(serverModel: ServerModel, with action: ChangeAction, on context: NSManagedObjectContext) throws -> Self?
}
