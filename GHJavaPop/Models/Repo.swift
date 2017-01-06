//
//  Repo.swift
//  GHJavaPop
//
//  Created by Fredyson Costa Marques Bentes on 04/01/17.
//  Copyright © 2017 home. All rights reserved.
//

import Foundation

private struct RepoAttributes {
    static let name = "name"
    static let fullName = "full_name"
    static let description = "description"
    static let stars = "stargazers_count"
    static let forks = "forks_count"
    static let owner = "owner"
}

class Repo {

    var name: String?
    var fullName: String?
    var description: String?
    var stars: Int?
    var forks: Int?
    var owner: [String : Any] = [:]
    
    init?(_ dictionary: [String: Any]) {
        name = dictionary[RepoAttributes.name] as? String
        fullName = dictionary[RepoAttributes.fullName] as? String
        description = dictionary[RepoAttributes.description] as? String
        stars = dictionary[RepoAttributes.stars] as? Int
        forks = dictionary[RepoAttributes.forks] as? Int
        owner = dictionary[RepoAttributes.owner] as! [String : Any]
    }
    
}
