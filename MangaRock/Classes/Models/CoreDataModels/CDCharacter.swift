//
//  CDCharacter.swift
//  MangaRock
//
//  Created by giang tran on 7/13/19.
//  Copyright © 2019 Vien Tran. All rights reserved.
//

import Foundation
import CoreData

extension MRCharacter: CoreDataServerUpdatable, ManagedObject {
    

    var serverID: ServerID {
        return cid
    }
    
    @discardableResult
    func updateIfNeededWith(serverModel: SVCharacter, with action: ChangeAction) -> Self? {
        guard action == .create || needUpdate(with: serverModel) else { return nil }
        
        self.avatarImage = serverModel.avatarImage
        self.name        = serverModel.name
        self.cid         = serverModel.serverID
        self.updateTime  = serverModel.updateTime
        
        return self
    }
    
    func updateIfNeededWith(serverModel: SVCharacter, with action: ChangeAction, on context: NSManagedObjectContext) throws -> Self? {
        return updateIfNeededWith(serverModel: serverModel, with: action) 
    }
}

extension MRCharacter {
    var viewModel: CharacterViewModel {
        return CharacterViewModel(objectID    : opaqueObjectID,
                                  avatarImage : avatarImage ?? "",
                                  name        : name ?? "")
    }
}
