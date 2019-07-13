//
//  ModelUpdater.swift
//  MangaRock
//
//  Created by giang tran on 7/13/19.
//  Copyright © 2019 Vien Tran. All rights reserved.
//

import Foundation

struct ModelUpdater<ModelType: ServerUpdatable> {
    
    private let fetchBlock: (ModelType.ServerModel) -> ModelType?
    private let createBlock: () -> ModelType?

    init(fetchBlock: @escaping (ModelType.ServerModel) -> ModelType?, createBlock: @escaping () -> ModelType?) {
        self.fetchBlock = fetchBlock
        self.createBlock = createBlock
    }

    @discardableResult
    func updateOrCreate(serverModel: ModelType.ServerModel) throws -> ModelType {
        if let model = fetchBlock(serverModel) {
            model.updateIfNeededWith(serverModel: serverModel, with: .update)
            return model
            
        } else if let model = createBlock() {
            model.updateIfNeededWith(serverModel: serverModel, with: .create)
            return model
            
        } else {
            throw CoreDataError.somethingWentWrong
            // to record error
            // could be disk error or something else
        }
    }
    
}
