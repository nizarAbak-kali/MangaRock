//
//  MangaCoredataRequestAPIProtocol.swift
//  MangaRock
//
//  Created by giang tran on 7/13/19.
//  Copyright © 2019 Vien Tran. All rights reserved.
//

import Foundation

protocol MangaCoredataRequestAPIProtocol {
    func latestMangaUpdateTime() -> Int64?
    
    func requestMangas(from serverIDs: [ServerID]) throws -> [MangaViewModel]
    func process(serverReplyList: [SVManga], completion: ErrorBlock?)
    
    typealias OutDatedServerIDListBlock = (Bool, [ServerID]) -> ()
    func process(serverIDList: [SVMangaServerID], completion: OutDatedServerIDListBlock?)
    
    func fetchMangas() -> [MangaViewModel]
}
