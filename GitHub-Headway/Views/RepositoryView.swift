//
//  RepositoryView.swift
//  GitHub-Headway
//
//  Created by Yevhenii Orenchuk on 10.09.2022.
//

import SwiftUI

struct RepositoryView: View {
    
    var repository: Repository
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                Text(repository.fullname)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "star")
                    Text("\(repository.stargazersCount)")
                }
                    .foregroundColor(.gray)
            }
            
            if let description = repository.descriptionInfo {
                Text(description)
                    .font(.subheadline)
                    .lineLimit(3)
                    .foregroundColor(.primary)
            }
        }
        .padding(4)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct RepositoryView_Previews: PreviewProvider {
    static var previews: some View {
        RepositoryView(repository: .mock)
    }
}

private extension Repository {
    
    static var mock: Repository {
        .init(
            id: 31792824,
            name: "flutter",
            fullname: "flutter/flutter",
            htmlURL: URL(string: "https://github.com/flutter/flutter")!,
            descriptionInfo: "Flutter makes it easy and fast to build beautiful apps for mobile and beyond",
            url: URL(string: "https://api.github.com/repos/flutter/flutter")!,
            language: "Dart",
            watchersCount: 144790,
            stargazersCount: 144790,
            forksCount: 23180,
            lastVisited: nil
        )
    }
    
}
