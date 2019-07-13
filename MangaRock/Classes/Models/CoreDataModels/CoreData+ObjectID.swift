//
//  ObjectID.swift
//  MangaRock
//
//  Created by giang tran on 7/13/19.
//  Copyright © 2019 Vien Tran. All rights reserved.
//

import Foundation
import CoreData

struct ObjectID {
    let managedObjectID: NSManagedObjectID
}

extension NSManagedObject {
    var opaqueObjectID: ObjectID {
        return ObjectID(managedObjectID: objectID)
    }
}
