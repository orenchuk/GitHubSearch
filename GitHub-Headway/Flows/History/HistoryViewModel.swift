//
//  HistoryViewModel.swift
//  GitHub-Headway
//
//  Created by Yevhenii Orenchuk on 10.09.2022.
//

import Foundation

final class HistoryViewModel: ObservableObject {
    
    @Published private(set) var results: [Repository]
    @Published var selectedItem: Repository?
    
    private let storage: GitHubSearchResultsStorage
    
    init(storage: GitHubSearchResultsStorage) {
        self.storage = storage
        self.results = (try? storage.fetchValues()) ?? []
    }
    
    func fetchResults() {
        do {
            let results = try storage.fetchValues()
            if self.results != results {
                self.results = results
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func select(item: Repository) {
        selectedItem = item
    }
    
}
