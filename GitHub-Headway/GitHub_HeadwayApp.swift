//
//  GitHub_HeadwayApp.swift
//  GitHub-Headway
//
//  Created by Yevhenii Orenchuk on 06.09.2022.
//

import SwiftUI

@main
struct GitHub_HeadwayApp: App {
    
    let api = GitHubAPI(
        session: .shared,
        clientID: APIKeys.GitHub.clientID,
        clientSecret: APIKeys.GitHub.clientSecret,
        storage: .coreData
    )

    var body: some Scene {
        WindowGroup {
//            if let _ = results.first {
                MainView(viewModel: .init(api: api, accessTokenStorage: .coreData, searchResultsStorage: .coreData))
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
//            } else {
//                AuthView(viewModel: .init(api: api, storage: .coreData))
//            }
        }
    }
}
