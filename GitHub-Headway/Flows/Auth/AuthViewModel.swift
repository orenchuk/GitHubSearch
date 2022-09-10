//
//  AuthViewModel.swift
//  GitHub-Headway
//
//  Created by Yevhenii Orenchuk on 08.09.2022.
//

import Foundation
import Combine

final class AuthViewModel: ObservableObject {
    
    @Published var sheet: Sheet?
    @Published var alert: Alert?
    @Published var loading = false
    
    private var subscriptions: Set<AnyCancellable> = []
    
    private let api: GitHubAuthAPIRequestable
    private let storage: AccessTokenStorage
    
    init(api: GitHubAuthAPIRequestable, storage: AccessTokenStorage) {
        self.api = api
        self.storage = storage
    }
    
    func presentGitHubAuthorization() {
        sheet = .github(url: api.authorizationURL)
    }
    
    func resolveDeeplink(url: URL) {
        sheet = nil
        loading = true
        
        api.requestAccessToken(callbackURL: url)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.alert = .error(message: error.localizedDescription)
                case .finished:
                    return
                }
            } receiveValue: { [weak self] accessToken in
                try? self?.storage.save(accessToken)
            }
            .store(in: &subscriptions)
    }
    
}

extension AuthViewModel {
    
    enum Sheet {
        case github(url: URL)
    }
    
}

extension AuthViewModel.Sheet: Identifiable {
    
    var id: String {
        switch self {
        case .github(let url):
            return url.absoluteString
        }
    }
    
}

extension AuthViewModel {
    
    static let mock = AuthViewModel(api: GitHubAPI(session: .shared, clientID: APIKeys.GitHub.clientID, clientSecret: APIKeys.GitHub.clientSecret, storage: .coreData), storage: .coreData)
    
}

extension AuthViewModel {
    
    enum Alert {
        case error(message: String)
    }
    
}

extension AuthViewModel.Alert: Identifiable {
    
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
