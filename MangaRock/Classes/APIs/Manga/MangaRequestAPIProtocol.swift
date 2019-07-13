//
//  MangaRequestAPI.swift
//  MangaRock
//
//  Created by giang tran on 7/13/19.
//  Copyright © 2019 Vien Tran. All rights reserved.
//

import Foundation

protocol MangaRequestAPIProtocol {
    
    typealias MangaIDRequestResultBlock = (Result<[SVMangaServerID]>) -> ()
    func requestServerIDList(completion: MangaIDRequestResultBlock?)
    
    
    typealias MangasRequestResultBlock = (Result<[SVManga]>) -> ()
    func requestMangas(from serverIDs: [ServerID], completion: MangasRequestResultBlock?)
    
    func hasChange(with latestUpdateTime: Int64, completion: BoolBlock?)
}
