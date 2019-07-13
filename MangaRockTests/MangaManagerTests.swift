//
//  MangaRockTests.swift
//  MangaRockTests
//
//  Created by giang tran on 7/14/19.
//  Copyright © 2019 Vien Tran. All rights reserved.
//

import XCTest
@testable import MangaRock

class MangaManagerTests: XCTestCase {
    
    private let testLocalCoreDataName = "local-coredata-test"
    private let testMOCKCoreDataName = "mock-coredata-test"
    
    private var mangaManager: MangaManager?
    private var localCoreDataStack: ParallelCoreData?
    private var coreDataAPI: MangaCoredataRequestAPI?
    private var mockCoreDataStack: ParallelCoreData?
    private var mockHTTPAPI: MOCKMangaHTTPRequestAPI?

    
    override func setUp() {
        do {
            // coredata service
            localCoreDataStack = try ParallelCoreData(withModelName: "MangaRock", sqlName: testLocalCoreDataName)
            coreDataAPI = MangaCoredataRequestAPI(with: localCoreDataStack!)
            
            // mock server
            Bootstrap.copyDataIfNeeded(to: testMOCKCoreDataName)
            mockCoreDataStack = try ParallelCoreData(withModelName: "MangaRock", sqlName: testMOCKCoreDataName)
            mockHTTPAPI = MOCKMangaHTTPRequestAPI(with: mockCoreDataStack!)
            
            mangaManager = MangaManager(mangaCoreDataAPI: coreDataAPI!, mangaRequestAPI: mockHTTPAPI!)
        } catch {
            return
        }
        
    }

    override func tearDown() {
        [testMOCKCoreDataName, testLocalCoreDataName].forEach({ name in
            let sqlDBPath = BaseCoreData.documentUrl.path.appending("/\(name).sqlite")
            let sqlDBWalPath = BaseCoreData.documentUrl.path.appending("/\(name).sqlite-wal")
            let sqlDBShmPath = BaseCoreData.documentUrl.path.appending("/\(name).sqlite-shm")
            
            if FileManager.default.fileExists(atPath: sqlDBPath) {
                try? FileManager.default.removeItem(atPath: sqlDBPath)
            }
            
            if FileManager.default.fileExists(atPath: sqlDBShmPath) {
                try? FileManager.default.removeItem(atPath: sqlDBShmPath)
            }
            
            if FileManager.default.fileExists(atPath: sqlDBWalPath) {
                try? FileManager.default.removeItem(atPath: sqlDBWalPath)
            }
        })
    }
    
    
    
    
    func testMockDataConfigured() {
        mockCoreDataStack?.writeContext.perform {
            let numberOfMangaInServer = MRManga.count(in: self.mockCoreDataStack!.writeContext)
            XCTAssert(numberOfMangaInServer != 0, "numberOfMangaInServer = 0, setup was wrong")
        }
        
    }

    func testSyncAllDataIfEmpty() {
        guard let mangaManager = mangaManager else {
            XCTFail(); return
        }
        
        let expectation = self.expectation(description: "Sync all data")
        
        mockCoreDataStack?.writeContext.perform {
            let numberOfMangaInServer = MRManga.count(in: self.mockCoreDataStack!.writeContext)
            
            DispatchQueue.main.async {
                mangaManager.syncIfNeeded(completion: {
                    let syncedMangas = mangaManager.requestMangas()
                    
                    if syncedMangas.count == numberOfMangaInServer {
                        expectation.fulfill()
                    }
                })
            }
        }
        
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testNewMangaIsSynced() {
        guard let mangaManager = mangaManager else {
            XCTFail(); return
        }
        
        let newMangaSyncedExpectation = self.expectation(description: "New manga is synced")
        
        mockCoreDataStack?.writeContext.perform {
            let numberOfMangaInServer = MRManga.count(in: self.mockCoreDataStack!.writeContext)
            
            DispatchQueue.main.async {
                mangaManager.syncIfNeeded(completion: {
                    
                    self.mockCoreDataStack?.writeContext.performAndWait {
                        let newManga: MRManga = try! self.mockCoreDataStack!.writeContext.insertObject()
                        newManga.mid = Int32.max
                        newManga.updateTime = 1
                    }
                    
                    mangaManager.syncIfNeeded {
                        let syncedMangas = mangaManager.requestMangas()
                        
                        if syncedMangas.count == numberOfMangaInServer + 1 {
                            newMangaSyncedExpectation.fulfill()
                        }
                    }
                })
            }
        }
        
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testDeletedMangaIsSynced() {
        guard let mangaManager = mangaManager else {
            XCTFail(); return
        }
        
        let newMangaSyncedExpectation = self.expectation(description: "New manga is synced")
        
        mockCoreDataStack?.writeContext.perform {
            let numberOfMangaInServer = MRManga.count(in: self.mockCoreDataStack!.writeContext)
            
            DispatchQueue.main.async {
                mangaManager.syncIfNeeded(completion: {
                    
                    self.mockCoreDataStack?.writeContext.performAndWait {
                        let mangas = MRManga.fetch(in: self.mockCoreDataStack!.writeContext)
                        XCTAssert(mangas.count != 0, "Manga on server must not be empty")
                        self.mockCoreDataStack!.writeContext.delete(mangas[0])
                    }
                    
                    mangaManager.syncIfNeeded {
                        let syncedMangas = mangaManager.requestMangas()
                        
                        if syncedMangas.count == numberOfMangaInServer - 1 {
                            newMangaSyncedExpectation.fulfill()
                        }
                    }
                })
            }
        }
        
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testUpdatedMangaIsSynced() {
        print("\n\n\n\n\n")
        guard let mangaManager = mangaManager else {
            XCTFail(); return
        }
        
        let newName = "New Name"
        let newUpdateTime: Int64 = 1000_000
        let updatedMangaSyncedExpectation = self.expectation(description: "Updated manga is synced")
        
        mockCoreDataStack?.writeContext.perform {
            
            DispatchQueue.main.async {
                mangaManager.syncIfNeeded(completion: {
                    var mangaID: ServerID = -1
                    
                    self.mockCoreDataStack?.writeContext.perform {
                        let mangas = MRManga.fetch(in: self.mockCoreDataStack!.writeContext)
                        XCTAssert(mangas.count != 0, "Manga on server must not be empty")
                        mangas[0].updateTime = newUpdateTime
                        mangas[0].name = newName
                        
                        mangaID = mangas[0].serverID
                        
                        try? self.mockCoreDataStack?.writeContext.save()
                        
                        DispatchQueue.main.async {
                            mangaManager.syncIfNeeded(completion: {
                                let localMangaList = mangaManager.requestMangas()
                                
                                guard localMangaList.first(where: { $0.name == newName }) != nil else {
                                    return
                                }
                                
                                if let cdManga: MRManga = MRManga.fetch(in: self.localCoreDataStack!.viewContext, configurationBlock: { (request) in
                                    request.predicate = NSPredicate(format: "%K = \(mangaID)", #keyPath(MRManga.mid))
                                    request.fetchLimit = 1
                                }).first {
                                    if cdManga.name == newName && cdManga.updateTime == newUpdateTime {
                                        updatedMangaSyncedExpectation.fulfill()
                                    }
                                }
                                
                            })
                        }
                    }
                    
                    
                })
            }
        }
        
        waitForExpectations(timeout: 0.5, handler: nil)
    }
}
