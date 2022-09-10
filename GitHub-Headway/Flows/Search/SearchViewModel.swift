//
//  SearchViewModel.swift
//  GitHub-Headway
//
//  Created by Yevhenii Orenchuk on 09.09.2022.
//

import Foundation
import Combine

final class SearchViewModel<SearchAPI: GitHubSearchAPIRequestable>: ObservableObject {
    
    @Published var results: [Repository] = []
    @Published var searchQuery: String = ""
    @Published var alert: Alert?
    @Published var selectedSearchItem: Repository?
    
    private var subscriptions: Set<AnyCancellable> = []
    
    private let api: SearchAPI
    private let storage: GitHubSearchResultsStorage
    
    init(api: SearchAPI, storage: GitHubSearchResultsStorage) {
        self.api = api
        self.storage = storage
        
        $searchQuery
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .filter({ !$0.isEmpty })
            .flatMap { [api] query in
                api.requestRepositories(matching: query, page: 1)
            }
            .receive(on: RunLoop.main)
            .handleEvents(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.alert = .error(message: error.localizedDescription)
                case .finished:
                    return
                }
            })
            .replaceError(with: [])
            .map({ $0.map(Repository.init(from:)) })
            .assign(to: &$results)
    }
    
    func performSearch() {
        guard !searchQuery.isEmpty else { return }
        api.requestRepositories(matching: searchQuery, page: 1)
            .receive(on: RunLoop.main)
            .handleEvents(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.alert = .error(message: error.localizedDescription)
                case .finished:
                    return
                }
            })
            .replaceError(with: [])
            .map({ $0.map(Repository.init(from:)) })
            .assign(to: &$results)
    }
    
    func performPagination() {
        guard !searchQuery.isEmpty else { return }
        api.requestRepositories(matching: searchQuery, page: currentPage + 1)
            .receive(on: RunLoop.main)
            .map({ $0.map(Repository.init(from:)) })
            .map({ [results] values -> [Repository] in
                let values = Set(values)
                let intersection = values.intersection(results)
                let set = values.subtracting(intersection)
                return Array(set).sorted { $0.stargazersCount > $1.stargazersCount }
            })
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .failure(let error):
                        self?.alert = .error(message: error.localizedDescription)
                    case .finished:
                        return
                    }
                },
                receiveValue: { [weak self] values in
                    self?.results.append(contentsOf: values)
                }
            )
            .store(in: &subscriptions)
    }
    
    func select(item: Repository) {
        selectedSearchItem = item
        do {
            try storage.save(repository: item)
        } catch {
            alert = .error(message: error.localizedDescription)
        }
    }
    
}

extension SearchViewModel {
    
    var currentPage: Int {
        results.count / 15
    }
    
}

extension SearchViewModel {
    
    enum Alert {
        case error(message: String)
    }
    
}

extension SearchViewModel.Alert: Identifiable {
    
    var id: String {
        switch self {
        case .error(let message):
            return message
        }
    }
    
    var title: String {
        switch self {
        case .error:
            return "Error"
        }
    }
    
    var message: String {
        switch self {
        case .error(let message):
            return message
        }
    }
    
}
