//
//  MainView.swift
//  GitHub-Headway
//
//  Created by Yevhenii Orenchuk on 07.09.2022.
//

import SwiftUI

struct MainView: View {
    typealias ViewModel = MainViewModel<GitHubAPI>
    
    @ObservedObject var viewModel: ViewModel
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [], animation: .default)
    private var results: FetchedResults<AccessTokenEntity>
    
    var body: some View {
        if let _ = results.first {
            TabView(selection: $viewModel.selectedTab) {
                SearchView(viewModel: viewModel.searchViewModel)
                    .tag(ViewModel.Tab.search)
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                
                HistoryView(viewModel: viewModel.historyViewModel)
                    .tag(ViewModel.Tab.history)
                    .tabItem {
                        Label("History", systemImage: "clock")
                    }
            }
        } else {
            AuthView(viewModel: viewModel.authViewModel)
        }
    }
    
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(viewModel: .mock)
    }
}
