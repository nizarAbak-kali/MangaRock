//
//  SVCharacter.swift
//  MangaRock
//
//  Created by giang tran on 7/13/19.
//  Copyright © 2019 Vien Tran. All rights reserved.
//

import Foundation

struct SVCharacter: ServerModelProtocol {
    let serverID: ServerID
    let updateTime: Int64
    
    let avatarImage: String
    let name: String    
}
