//
//  MangaCoredataRequestAPI.swift
//  MangaRock
//
//  Created by giang tran on 7/13/19.
//  Copyright © 2019 Vien Tran. All rights reserved.
//

import Foundation
import CoreData

final class MangaCoredataRequestAPI: MangaCoredataRequestAPIProtocol {

    private let coreDataStack: ParallelCoreData
    private lazy var mangaUpdater: ModelUpdater<MRManga> = ModelUpdater(fetchBlock: { [weak self] (serverModel: SVManga) -> MRManga? in
        guard let self = self else { return nil }
        return MRManga.findOrFetch(in: self.coreDataStack.writeContext,
                                   matching: NSPredicate(format: "%K = \(serverModel.serverID)",
                                                         #keyPath(MRManga.mid)))

    }, createBlock: { [weak self] () -> MRManga? in
        guard let self = self else { return nil }
        
        do {
            return try self.coreDataStack.writeContext.insertObject()
        } catch {
            return nil
        }
    })
    
    init(with coreDataStack: ParallelCoreData) {
        self.coreDataStack = coreDataStack
    }
    
    func latestMangaUpdateTime() -> Int64? {
        assert(Thread.isMainThread)
        return MRManga.fetch(in: coreDataStack.viewContext) { (request) in
            request.returnsObjectsAsFaults = false
            request.fetchLimit = 1
            request.sortDescriptors = MRManga.defaultSortDescriptors
        }.first?.updateTime
    }
    
    func requestMangas(from serverIDs: [ServerID]) throws -> [MangaViewModel] {
        assert(Thread.isMainThread, "must read on main thread")
        
        return MRManga.fetch(in: coreDataStack.viewContext, configurationBlock: { (request) in
            request.returnsObjectsAsFaults = false
            request.relationshipKeyPathsForPrefetching = [#keyPath(MRManga.characters)]
            
            request.predicate = NSPredicate(format: "%K IN %@", #keyPath(MRManga.mid), serverIDs)
            
        }).map({ $0.viewModel })
    }
    
    func process(serverIDList: [SVMangaServerID], completion: MangaCoredataRequestAPIProtocol.OutDatedServerIDListBlock?) {
        coreDataStack.writeContext.perform {
            let predicate = NSPredicate(format: "NOT (%K IN %@)", #keyPath(MRManga.mid), serverIDList.map({ $0.serverID }))
            do {
                let deleted = try MRManga.delete(in: self.coreDataStack.writeContext, matching: predicate)
                self.coreDataStack.saveChange()
                
                self.recursiveProcess(serverIDList: serverIDList, processedOutDatedServerIDList: []) { outdatedServerIDList in
                    completion?(deleted, outdatedServerIDList)
                }
            } catch {
                // TODO: handle error
                print(error.localizedDescription)
                self.recursiveProcess(serverIDList: serverIDList, processedOutDatedServerIDList: []) { outdatedServerIDList in
                    completion?(false, outdatedServerIDList)
                }
            }
        }
    }
    
    func process(serverReplyList: [SVManga], completion: ErrorBlock?) {
        recursiveProcess(serverReplyList: serverReplyList, happenedError: nil, completion: completion)
    }
    
    func fetchMangas() -> [MangaViewModel] {
        assert(Thread.isMainThread)
        return MRManga.fetch(in: coreDataStack.viewContext, configurationBlock: { request in
            request.sortDescriptors = [NSSortDescriptor(key: #keyPath(MRManga.name), ascending: true)]
        }).map({ $0.viewModel })
    }
    
    
    // Helper
    private func recursiveProcess<List: Collection>(serverReplyList: List,
                                                    happenedError: Error?,
                                                    completion: ErrorBlock?)
        where List.Element == SVManga, List.Index == Int {
            
            let endIndex = serverReplyList.startIndex.advanced(by: min(51, serverReplyList.count))
            
            coreDataStack.writeContext.perform {
                var writeError: Error?
                
                autoreleasepool {
                    for i in serverReplyList.startIndex ..< endIndex {
                        do {
                            try self.mangaUpdater.updateOrCreate(serverModel: serverReplyList[i], on: self.coreDataStack.writeContext)
                            
                        } catch {
                            // Record the error, continue to write, allow partial data
                            writeError = error
                        }
                    }
                    self.coreDataStack.saveChange()
                }
                
                if endIndex != serverReplyList.endIndex {
                    // Recursive process remains
                    self.recursiveProcess(serverReplyList: serverReplyList[endIndex...],
                                           happenedError: writeError,
                                           completion: completion)
                } else {
                    DispatchQueue.main.async {
                        completion?(writeError ?? happenedError)
                    }
                }
            }
        
    }
    
    private func recursiveProcess<List: RandomAccessCollection>(serverIDList: List,
                                                                processedOutDatedServerIDList: [ServerID],
                                                                completion: @escaping ([ServerID]) -> ())
        where List.Element == SVMangaServerID, List.Index == Int {
        
            let endIndex = serverIDList.startIndex.advanced(by: min(51, serverIDList.count))
            
            coreDataStack.writeContext.perform {
                let mangas = MRManga.fetch(in: self.coreDataStack.writeContext) { request in
                    request.predicate = NSPredicate(format: "%K IN %@", #keyPath(MRManga.mid),
                                                    serverIDList[serverIDList.startIndex ..< endIndex].map({ $0.serverID })
                    )
                    request.returnsObjectsAsFaults = false
                }
                
                let mangasIDMap = Dictionary(mangas.map({ ($0.serverID, $0) }),
                                             uniquingKeysWith: { lhs, _ in return lhs })
                
                var outDatedIDList = [ServerID]()
                outDatedIDList.reserveCapacity(mangas.count / 2) // need to check the ratio to better performance
                
                for i in serverIDList.startIndex ..< endIndex {
                    if let manga = mangasIDMap[serverIDList[i].serverID] {
                        
                        if manga.needUpdate(with: serverIDList[i]) {
                            outDatedIDList.append(manga.serverID)
                        }
                        
                    } else {
                        outDatedIDList.append(serverIDList[i].serverID) // new manga
                    }
                }
                
                if endIndex != serverIDList.endIndex {
                    // Recursive process remains
                    self.recursiveProcess(serverIDList: serverIDList[endIndex...],
                                          processedOutDatedServerIDList: processedOutDatedServerIDList + outDatedIDList,
                                          completion: completion)
                    
                } else {
                    DispatchQueue.main.async {
                        completion(processedOutDatedServerIDList + outDatedIDList)
                    }
                }
            }
    }
}
