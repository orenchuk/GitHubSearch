//
//  MainViewModel.swift
//  GitHub-Headway
//
//  Created by Yevhenii Orenchuk on 10.09.2022.
//

import Foundation

final class MainViewModel<API: GitHubAPIRequestable>: ObservableObject {
    
    @Published var selectedTab: Tab = .search
    
    private let api: API
    private let accessTokenStorage: AccessTokenStorage
    private let searchResultsStorage: GitHubSearchResultsStorage
    
    init(api: API, accessTokenStorage: AccessTokenStorage, searchResultsStorage: GitHubSearchResultsStorage) {
        self.api = api
        self.accessTokenStorage = accessTokenStorage
        self.searchResultsStorage = searchResultsStorage
    }
    
    var searchViewModel: SearchViewModel<API> {
        SearchViewModel(api: api, storage: searchResultsStorage)
    }
    
    var historyViewModel: HistoryViewModel {
        HistoryViewModel(storage: searchResultsStorage)
    }
    
    var authViewModel: AuthViewModel {
        AuthViewModel(api: api, storage: accessTokenStorage)
    }
    
}

extension MainViewModel {
    
    enum Tab: Hashable {
        case search
        case history
    }
    
}

extension MainViewModel where API == GitHubAPI {
    
    static var mock: MainViewModel {
        MainViewModel(api: .mock, accessTokenStorage: .coreData, searchResultsStorage: .coreData)
    }
    
}
