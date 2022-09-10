//
//  GitHubSearchResultsController.swift
//  GitHub-Headway
//
//  Created by Yevhenii Orenchuk on 10.09.2022.
//

import CoreData

protocol GitHubSearchResultsStorage {
    func fetchValues() throws -> [Repository]
    func save(repository: Repository) throws
}

final class GitHubSearchResultsController: GitHubSearchResultsStorage {
    
    private let persistence: CoreDataPersistence
    
    init(persistence: CoreDataPersistence) {
        self.persistence = persistence
    }
    
    func fetchValues() throws -> [Repository] {
        let results = try fetchEntities()
        return results.compactMap(Repository.init)
    }
    
    func save(repository: Repository) throws {
        let context = persistence.container.viewContext
        let entities = try fetchEntities()
        if entities.count >= 20, let firstVisited = firstVisited(form: entities) {
            context.delete(firstVisited)
        }
        
        let entity = GitHubSearchResultEntity(context: context)
        entity.id = Int64(repository.id)
        entity.name = repository.name
        entity.fullname = repository.fullname
        entity.htmlURL = repository.htmlURL
        entity.descriptionInfo = repository.descriptionInfo
        entity.url = repository.url
        entity.language = repository.language
        entity.watchersCount = Int64(repository.watchersCount)
        entity.stargazersCount = Int64(repository.stargazersCount)
        entity.forksCount = Int64(repository.forksCount)
        entity.lastVisited = Date()
        
        if context.hasChanges {
            try context.save()
        }
    }
    
}

private extension GitHubSearchResultsController {
    
    func fetchEntities() throws -> [GitHubSearchResultEntity] {
        let context = persistence.container.viewContext
        let fetchRequest = GitHubSearchResultEntity.fetchRequest()
        return try context.fetch(fetchRequest)
    }
    
    func firstVisited(form entities: [GitHubSearchResultEntity]) -> GitHubSearchResultEntity? {
        entities
            .sorted(by: {
                guard let lhs = $0.lastVisited, let rhs = $1.lastVisited else { return false }
                return lhs > rhs
            })
            .first
    }
    
}

private extension Repository {
    
    init?(from object: GitHubSearchResultEntity) {
        guard
            let name = object.name,
            let fullname = object.fullname,
            let htmlURL = object.htmlURL,
            let url = object.url
        else { return nil }
       
        self.init(
            id: Int(object.id),
            name: name,
            fullname: fullname,
            htmlURL: htmlURL,
            descriptionInfo: object.descriptionInfo,
            url: url,
            language: object.language,
            watchersCount: Int(object.watchersCount),
            stargazersCount: Int(object.stargazersCount),
            forksCount: Int(object.forksCount),
            lastVisited: object.lastVisited
        )
    }
    
}

extension GitHubSearchResultsStorage where Self == GitHubSearchResultsController {
    
    static var coreData: GitHubSearchResultsController {
        GitHubSearchResultsController(persistence: PersistenceController.shared)
    }
    
}
