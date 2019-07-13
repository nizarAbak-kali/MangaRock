//
//  SVManaga.swift
//  MangaRock
//
//  Created by giang tran on 7/13/19.
//  Copyright © 2019 Vien Tran. All rights reserved.
//

import Foundation

struct SVManga: ServerModelProtocol {
    let serverID: ServerID
    let updateTime: Int64
    
    let authorName: String
    let coverImage: String
    let mangaDescription: String
    let name: String
    let thumbnailImage: String
    let characters: [SVCharacter]
}

struct SVMangaServerID: ServerModelProtocol {
    let serverID: ServerID
    let updateTime: Int64
}

struct SVMangaServerIDPageRequestParams {
    let cursor: SVMangaServerID?
    let limit: Int
}
