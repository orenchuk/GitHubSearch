//
//  HistoryView.swift
//  GitHub-Headway
//
//  Created by Yevhenii Orenchuk on 10.09.2022.
//

import SwiftUI

struct HistoryView: View {
    
    @ObservedObject var viewModel: HistoryViewModel
    
    var body: some View {
        NavigationView {
            List(viewModel.results) { result in
                Button {
                    viewModel.select(item: result)
                } label: {
                    RepositoryView(repository: result)
                }
            }
            .navigationTitle("History")
            .sheet(item: $viewModel.selectedItem) { item in
                SafariWebView(url: item.htmlURL)
                    .ignoresSafeArea()
            }
        }
        .onAppear {
            viewModel.fetchResults()
        }
    }
    
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView(viewModel: .init(storage: .coreData))
    }
}
