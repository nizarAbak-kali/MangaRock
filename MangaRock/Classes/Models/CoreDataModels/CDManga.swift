//
//  CDManga.swift
//  MangaRock
//
//  Created by giang tran on 7/13/19.
//  Copyright © 2019 Vien Tran. All rights reserved.
//

import Foundation
import CoreData

extension MRManga: CoreDataServerUpdatable {
    typealias ServerModel = SVManga
    
    var serverID: ServerID {
        return mid
    }
    
    @discardableResult
    func updateIfNeededWith(serverModel: SVManga, with action: ChangeAction) -> Bool {
        guard action == .create || action == .none || needUpdate(with: serverModel) else { return false }
        
        self.authorName       = serverModel.authorName
        self.coverImage       = serverModel.coverImage
        self.thumbnailImage   = serverModel.thumbnailImage
        self.mangaDescription = serverModel.mangaDescription
        self.mid              = serverModel.serverID
        self.name             = serverModel.name
        self.updateTime       = serverModel.updateTime
        
        return true
    }
    
    func updateIfNeededWith(serverModel: SVManga, with action: ChangeAction, on context: NSManagedObjectContext) -> Bool {
        guard updateIfNeededWith(serverModel: serverModel, with: action) else {
            return false
        }
        
        // process relationship
        let characterServerIDMap = Dictionary(serverModel.characters.lazy.map({ ($0.serverID, $0) }),
                                              uniquingKeysWith: { lhs, _ in
                                                return lhs // never happend when serverID isn't duplicated
        })
        
        
        for character in characters?.lazy.compactMap({ ($0 as? MRCharacter) }) ?? [] {
            guard let serverCharacter = characterServerIDMap[character.serverID] else {
                context.delete(character)
                continue
            }
            
            character.updateIfNeededWith(serverModel: serverCharacter, with: .none)
        }
        
        return true
    }
}

extension MRManga {
    var viewModel: MangaViewModel {
        let characterViewModels = characters?.compactMap({ ($0 as? MRCharacter)?.viewModel }) ?? []
        
        return MangaViewModel(objectID         : opaqueObjectID,
                              authorName       : authorName ?? "",
                              coverImage       : coverImage ?? "",
                              mangaDescription : mangaDescription ?? "",
                              name             : name ?? "",
                              thumbnailImage   : thumbnailImage ?? "",
                              characters       : characterViewModels)
    }
}


extension MRManga: ManagedObject {
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: #keyPath(MRManga.updateTime),
                                 ascending: false),
                NSSortDescriptor(key: #keyPath(MRManga.mid),
                                 ascending: false)
        ]
    }
}
