//
//  Bootstrap.swift
//  MangaRock
//
//  Created by giang tran on 7/14/19.
//  Copyright © 2019 Vien Tran. All rights reserved.
//

import Foundation

class Bootstrap {
    static let sharedInstance = Bootstrap()
    
    public let mangaManager: MangaManager
    
    init?() {
        // init dependencies
        
        
        do {
            // coredata service
            let localCoreDataStack = try ParallelCoreData(withModelName: "MangaRock", sqlName: "localMangaCoreData")
            let coreDataAPI = MangaCoredataRequestAPI(with: localCoreDataStack)
            
            // mock server
            Bootstrap.copyDataIfNeeded(to: "MangaRock")
            let mockCoreDataStack = try ParallelCoreData(withModelName: "MangaRock", sqlName: "MangaRock")
            let mockHTTPAPI = MOCKMangaHTTPRequestAPI(with: mockCoreDataStack)
            
            mangaManager = MangaManager(mangaCoreDataAPI: coreDataAPI,
                                        mangaRequestAPI: mockHTTPAPI)
            
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    static func copyDataIfNeeded(to newName: String) {
        // Prepare sample data
        let sqlDBPath = BaseCoreData.documentUrl.path.appending("/\(newName).sqlite")
        if !FileManager.default.fileExists(atPath: sqlDBPath) {
            
            if let sampleDBPath = Bundle.main.path(forResource: "MangaRock", ofType: "sqlite"),
                let sampleWalDBPath = Bundle.main.path(forResource: "MangaRock", ofType: "sqlite-wal") {
                
                do {
                    try FileManager.default.createDirectory(atPath: BaseCoreData.documentUrl.path, withIntermediateDirectories: true, attributes: nil)
                    try FileManager.default.copyItem(atPath: sampleDBPath, toPath: sqlDBPath)
                    try FileManager.default.copyItem(atPath: sampleWalDBPath, toPath: BaseCoreData.documentUrl.path.appending("/\(newName).sqlite-wal"))
                } catch {
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            } else {
                assertionFailure()
            }
        }
    }
}
