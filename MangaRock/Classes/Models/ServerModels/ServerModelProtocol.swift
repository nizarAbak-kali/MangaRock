//
//  ServerModelProtocol.swift
//  MangaRock
//
//  Created by giang tran on 7/13/19.
//  Copyright © 2019 Vien Tran. All rights reserved.
//

import Foundation

protocol ServerModelProtocol {
    var serverID: ServerID { get }
    var updateTime: Int64 { get }
    
}
