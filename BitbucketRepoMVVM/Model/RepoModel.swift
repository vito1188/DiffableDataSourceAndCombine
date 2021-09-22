//
//  RepoModel.swift
//  BitbucketRepoMVVM
//
//  Created by Ta, Viet | Vito | MTSD on 2021/09/18.
//

import Foundation

struct RepoData: Decodable {
    let next: String
    let repositories: [Repository]
    
    enum CodingKeys: String, CodingKey {
        case next
        case repositories = "values"
    }
}

struct Repository: Decodable, Hashable {
    // This is for diffable data source
    var id: UUID = UUID()
    
    let owner: Owner
    let type: String
    let createdDate: String

    enum CodingKeys: String, CodingKey {
        case type
        case owner
        case createdDate = "created_on"
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct Owner: Decodable, Hashable {
    let displayName: String
    let links: Links

    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case links
    }
}

struct Links: Codable, Hashable {
    let avatar: Avatar

    enum CodingKeys: String, CodingKey {
        case avatar
    }
}

struct Avatar: Codable, Hashable {
    let href: String

    enum CodingKeys: String, CodingKey {
        case href
    }
}
