//
//  GitHubAPI.swift
//  GitHub-Headway
//
//  Created by Yevhenii Orenchuk on 07.09.2022.
//

import Combine
import Foundation

protocol GitHubAuthAPIRequestable {
    var authorizationURL: URL { get }
    func requestAccessToken(callbackURL: URL) -> AnyPublisher<String, Error>
}

protocol GitHubRepositoriesSearchItem: Codable, Hashable, Identifiable {
    var id: Int { get }
    var name: String { get }
    var fullname: String { get }
    var htmlURL: URL { get }
    var descriptionInfo: String? { get }
    var url: URL { get }
    var language: String? { get }
    var watchersCount: Int { get }
    var stargazersCount: Int { get }
    var forksCount: Int { get }
}

protocol GitHubSearchAPIRequestable {
    associatedtype SearchItem: GitHubRepositoriesSearchItem
    func requestRepositories(matching name: String, page: Int) -> AnyPublisher<[SearchItem], Error>
}

protocol GitHubAPIRequestable: GitHubAuthAPIRequestable, GitHubSearchAPIRequestable {}

final class GitHubAPI: GitHubAPIRequestable {
    
    private let session: URLSession
    private let clientID: String
    private let clientSecret: String
    private let storage: AccessTokenStorage
    
    init(session: URLSession, clientID: String, clientSecret: String, storage: AccessTokenStorage) {
        self.session = session
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.storage = storage
    }
    
}

extension GitHubAPI {
    
    typealias SearchItem = RepositoriesSearchItem
    
    struct RepositoriesSearchItem: GitHubRepositoriesSearchItem {
        let id: Int
        let name: String
        let fullname: String
        let htmlURL: URL
        let descriptionInfo: String?
        let url: URL
        let language: String?
        let watchersCount: Int
        let stargazersCount: Int
        let forksCount: Int
        
        private enum CodingKeys: String, CodingKey {
            case id
            case name
            case fullname = "full_name"
            case htmlURL = "html_url"
            case descriptionInfo = "description"
            case url
            case language
            case watchersCount = "watchers_count"
            case stargazersCount = "stargazers_count"
            case forksCount = "forks_count"
        }
    }
    
    func requestRepositories(matching name: String, page: Int) -> AnyPublisher<[RepositoriesSearchItem], Error> {
        _requestRepositories(matching: name, page: page)
            .zip(_requestRepositories(matching: name, page: page + 1))
            .map({ $0 + $1 })
            .map({ $0.sorted { $0.stargazersCount > $1.stargazersCount} })
            .eraseToAnyPublisher()
    }
    
}

private extension GitHubAPI {
    
    func _requestRepositories(matching name: String, page: Int) -> AnyPublisher<[RepositoriesSearchItem], Error> {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: "https://api.github.com/search/repositories?q=\(name)&sort=stars&order=desc&page=\(page)&per_page=15") else { return Fail(error: Issue.urlParsingFailed).eraseToAnyPublisher() }
        let accessToken: String
        do {
            guard let token = try storage.fetchValue() else { throw Issue.accessTokenAbsent }
            accessToken = token
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: Payload.Response.SearchResult.self, decoder: JSONDecoder())
            .map(\.items)
            .eraseToAnyPublisher()
    }
    
    func parse(parameter: String, from url: URL) -> String? {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let component = components?.queryItems?.first(where: { $0.name == parameter })
        return component?.value
    }
    
}

extension GitHubAPI {
    
    var authorizationURL: URL {
        URL(string: "https://github.com/login/oauth/authorize?client_id=\(clientID)")!
    }
    
    func requestAccessToken(callbackURL url: URL) -> AnyPublisher<String, Error> {
        guard let code = parse(parameter: "code", from: url) else { return Fail(error: Issue.urlParsingFailed).eraseToAnyPublisher() }
        guard let url = URL(string: "https://github.com/login/oauth/access_token") else { return Fail(error: Issue.urlParsingFailed).eraseToAnyPublisher() }
        let payload = Payload.Request.AccessToken(clientID: clientID, clientSecret: clientSecret, code: code)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        do {
            request.httpBody = try JSONEncoder().encode(payload)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: Payload.Response.AccessToken.self, decoder: JSONDecoder())
            .map(\.value)
            .eraseToAnyPublisher()
    }
    
}

extension GitHubAPI {
    
    enum Issue: Error {
        case urlParsingFailed
        case accessTokenAbsent
    }
    
}

extension GitHubAPI {
    
    enum Payload {
        
        enum Request {
            
            struct Identity: Encodable {
                let clientID: String
                
                private enum CodingKeys: String, CodingKey {
                    case clientID = "client_id"
                }
            }
            
            struct AccessToken: Encodable {
                let clientID: String
                let clientSecret: String
                let code: String
                
                private enum CodingKeys: String, CodingKey {
                    case clientID = "client_id"
                    case clientSecret = "client_secret"
                    case code
                }
            }
            
        }
        
        enum Response {
            
            struct AccessToken: Decodable {
                let value: String
                let scope: String
                let tokenType: String
                
                private enum CodingKeys: String, CodingKey {
                    case value = "access_token"
                    case scope
                    case tokenType = "token_type"
                }
            }
            
            struct SearchResult: Decodable {
                let totalCount: Int
                let incompleteResults: Bool
                let items: [SearchItem]
                
                private enum CodingKeys: String, CodingKey {
                    case totalCount = "total_count"
                    case incompleteResults = "incomplete_results"
                    case items
                }
            }
            
        }
        
    }
    
}

extension Repository {
    
    init<T: GitHubRepositoriesSearchItem>(from model: T) {
        self.init(
            id: model.id,
            name: model.name,
            fullname: model.fullname,
            htmlURL: model.htmlURL,
            descriptionInfo: model.descriptionInfo,
            url: model.url,
            language: model.language,
            watchersCount: model.watchersCount,
            stargazersCount: model.stargazersCount,
            forksCount: model.forksCount,
            lastVisited: nil
        )
    }
    
}

extension GitHubAPI {
    
    static let mock = GitHubAPI(session: .shared, clientID: APIKeys.GitHub.clientID, clientSecret: APIKeys.GitHub.clientSecret, storage: .coreData)
    
}
