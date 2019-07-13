//
//  MangaHTTPRequestAPI.swift
//  MangaRock
//
//  Created by giang tran on 7/13/19.
//  Copyright © 2019 Vien Tran. All rights reserved.
//

import Foundation

/* This class will be implemented if the new design is approved
 *
 *
 *
 
final class MangaHTTPRequestAPI: MangaRequestAPIProtocol {
    func requestServerIDPage(from cursor: SVMangaServerIDPageCursor?,
                             completion: MangaRequestAPIProtocol.MangaIDRequestResultBlock?) {
        
        // To implement if product team agree with the changes
    }
    
    func requestMangas(from serverIDs: [ServerID],
                       completion: MangaRequestAPIProtocol.MangasRequestResultBlock?) {
        
        // To implement if product team agree with the changes
    }
}

*/


/*
 * This MOCK class work as a backend side to demonstrate new design business logic
 * It uses same interface as MangaHTTPRequestAPI by adopting MangaRequestAPIProtocol
 * So that could change to implement/use MangaHTTPRequestAPI if needed
 */

final class MOCKMangaHTTPRequestAPI: MangaRequestAPIProtocol {
    
    private let coreDataStack: ParallelCoreData
    
    
    init(with coreDataStack: ParallelCoreData) {
        self.coreDataStack = coreDataStack
    }
    
    func requestServerIDList(completion: MangaRequestAPIProtocol.MangaIDRequestResultBlock?) {
        
        // use private context in this case
        coreDataStack.writeContext.perform {
            let mangas = MRManga.fetch(in: self.coreDataStack.writeContext, configurationBlock: { (fetchRequest) in
                fetchRequest.sortDescriptors = MRManga.defaultSortDescriptors
            })
            
            completion?(.success(data: mangas.map({ $0.serverIDInfo })))
        }
        
    }
    
    func requestMangas(from serverIDs: [ServerID],
                       completion: MangaRequestAPIProtocol.MangasRequestResultBlock?) {
        
        // use private context in this case
        coreDataStack.writeContext.perform {
            let mangas = MRManga.fetch(in: self.coreDataStack.writeContext, configurationBlock: { (fetchRequest) in
                fetchRequest.predicate = NSPredicate(format: "%K IN %@", #keyPath(MRManga.mid), serverIDs)
                fetchRequest.sortDescriptors = MRManga.defaultSortDescriptors
            })
            
            completion?(.success(data: mangas.map({ $0.serverModel })))
        }
    }
    
    func hasChange(with latestUpdateTime: Int64, completion: BoolBlock?) {
        coreDataStack.writeContext.perform {
            let latestManga = MRManga.fetch(in: self.coreDataStack.viewContext) { (request) in
                request.returnsObjectsAsFaults = false
                request.fetchLimit = 1
                request.sortDescriptors = MRManga.defaultSortDescriptors
            }.first
            
            if let latestManga = latestManga {
                completion?(latestManga.updateTime > latestUpdateTime)
                return
            }
            completion?(true)
        }
    }
    
}


private extension MRManga {
    var serverIDInfo: SVMangaServerID {
        return SVMangaServerID(serverID: serverID,
                               updateTime: updateTime)
    }
    
    var serverModel: SVManga {
        let chracters = characters?.compactMap({ ($0 as? MRCharacter)?.serverModel }) ?? []
        return SVManga(serverID: serverID, updateTime: updateTime, authorName: authorName ?? "",
                       coverImage: coverImage ?? "", mangaDescription: mangaDescription ?? "",
                       name: name ?? "", thumbnailImage: thumbnailImage ?? "",
                       characters: chracters)
    }
}


private extension MRCharacter {
    var serverModel: SVCharacter {
        return SVCharacter(serverID: serverID, updateTime: updateTime, avatarImage: avatarImage ?? "", name: name ?? "")
    }
}
