//
//  SearchView.swift
//  GitHub-Headway
//
//  Created by Yevhenii Orenchuk on 08.09.2022.
//

import SwiftUI

struct SearchView<SearchAPI: GitHubSearchAPIRequestable>: View {
    
    @ObservedObject var viewModel: SearchViewModel<SearchAPI>
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.results) { result in
                    Button {
                        viewModel.select(item: result)
                    } label: {
                        RepositoryView(repository: result)
                    }
                }
                
                if !viewModel.results.isEmpty, !viewModel.searchQuery.isEmpty {
                    ProgressView("Fetching more results")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .onAppear {
                            viewModel.performPagination()
                        }
                }
            }
            .searchable(text: $viewModel.searchQuery, placement: .navigationBarDrawer(displayMode: .always))
            .navigationTitle("Repositories")
            .onSubmit(of: .search) {
                viewModel.performSearch()
            }
            .sheet(item: $viewModel.selectedSearchItem) { item in
                SafariWebView(url: item.htmlURL)
                    .ignoresSafeArea()
            }
            .alert(
                title: { alert in
                    Text(alert.title)
                },
                presenting: $viewModel.alert,
                actions: { alert in
                    Button("Dismiss", role: .destructive, action: {})
                },
                message: { alert in
                    Text(alert.message)
                }
            )
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView<GitHubAPI>(viewModel: .init(api: .mock, storage: .coreData))
    }
}
