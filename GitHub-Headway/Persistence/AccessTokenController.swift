//
//  AccessTokenController.swift
//  GitHub-Headway
//
//  Created by Yevhenii Orenchuk on 10.09.2022.
//

import CoreData

protocol AccessTokenStorage {
    func fetchValue() throws -> String?
    func save(_ value: String) throws
}

final class AccessTokenController: AccessTokenStorage {
    
    private let persistence: CoreDataPersistence
    
    init(persistence: CoreDataPersistence) {
        self.persistence = persistence
    }
    
    func fetchValue() throws -> String? {
        let fetchRequest = AccessTokenEntity.fetchRequest()
        let results = try persistence.container.viewContext.fetch(fetchRequest)
        return results.first?.value
    }
    
    func save(_ value: String) throws {
        let context = persistence.container.viewContext
        let token = AccessTokenEntity(context: context)
        token.value = value
        if context.hasChanges {
            try context.save()
        }
    }
    
}

extension AccessTokenStorage where Self == AccessTokenController {
    
    static var coreData: AccessTokenController {
        AccessTokenController(persistence: PersistenceController.shared)
    }
    
}
