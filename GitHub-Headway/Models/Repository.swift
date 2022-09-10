//
//  Repository.swift
//  GitHub-Headway
//
//  Created by Yevhenii Orenchuk on 10.09.2022.
//

import Foundation

struct Repository: Codable, Hashable, Identifiable {
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
    let lastVisited: Date?
}
