//
//  MangaManager.swift
//  MangaRock
//
//  Created by giang tran on 7/13/19.
//  Copyright © 2019 Vien Tran. All rights reserved.
//

import Foundation

protocol MangaManagerDelegate: class {
    func mangaManageDidSyncNewData(manager: MangaManager)
}

final class MangaManager {
    weak var delegate: MangaManagerDelegate?
    
    private let mangaCoreDataAPI: MangaCoredataRequestAPIProtocol
    private let mangaRequestAPI: MangaRequestAPIProtocol
    
    init(mangaCoreDataAPI: MangaCoredataRequestAPIProtocol, mangaRequestAPI: MangaRequestAPIProtocol) {
        self.mangaRequestAPI = mangaRequestAPI
        self.mangaCoreDataAPI = mangaCoreDataAPI
    }
    
    func requestMangas() -> [MangaViewModel] {
        return mangaCoreDataAPI.fetchMangas()
    }
    
    func syncIfNeeded(completion: EmptyBlock?) {
        if let latestUpdateTime = mangaCoreDataAPI.latestMangaUpdateTime() {
            print("syncIfNeeded with latestUpdateTime: \(latestUpdateTime)")
            mangaRequestAPI.hasChange(with: latestUpdateTime) { [weak self] (hasChange) in
                print("syncIfNeeded with hasChange: \(hasChange)")
                
                self?.requestSync(completion: completion)
            }
            
        } else { // empty data
            print("syncIfNeeded with latestUpdateTime nil)")
            requestSync(completion: completion)
        }
    }
    
    private func requestSync(completion: EmptyBlock?) {
        
        mangaRequestAPI.requestServerIDList { [weak self] (result) in
            guard let self = self else { return }
            print("requestSync result: \(result)")
            
            switch result {
            case .success(let serverIDList):
                
                self.outdatedServerIDList(from: serverIDList) { [weak self] (deleted, outDatedIDList) in
                    guard let self = self else { return }
                    
                    print("process serverIDList result: deleted \(deleted) \n outDatedIDList: \(outDatedIDList)")
                    
                    guard !outDatedIDList.isEmpty else {
                        if deleted {
                            self.delegate?.mangaManageDidSyncNewData(manager: self)
                        }
                        completion?()
                        return
                    }
                    
                    self.requestSyncMangas(from: outDatedIDList) { [weak self] error in
                        // recor error if needed
                        guard let self = self, error == nil else {
                            return
                        }
                        completion?()
                        self.delegate?.mangaManageDidSyncNewData(manager: self)
                    }
                }
                
                
            case .failure:
                // Record sync error if needed
                completion?()
                return
            }
        }
    }
    
    private func outdatedServerIDList(from serverIDList: [SVMangaServerID],
                                      completion: @escaping (Bool, [ServerID]) -> ()) {
        mangaCoreDataAPI.process(serverIDList: serverIDList, completion: completion)
    }
    
    
    private func requestSyncMangas(from serverIDList: [ServerID], completion: ErrorBlock?) {
        mangaRequestAPI.requestMangas(from: serverIDList, completion: { [weak self] (mangasResult) in
            guard let self = self else { return }
//            print("process serverIDList result: \(mangasResult)")
            
            switch mangasResult {
            case .success(let mangas):
                self.mangaCoreDataAPI.process(serverReplyList: mangas, completion: completion)
            
            case .failure(let error):
                completion?(error)
            }
        })
    }
}
