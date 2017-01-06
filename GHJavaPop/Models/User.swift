//
//  User.swift
//  GHJavaPop
//
//  Created by Fredyson Costa Marques Bentes on 05/01/17.
//  Copyright © 2017 home. All rights reserved.
//

import Foundation
import ObjectMapper

class User: Mappable {
    
    var username: String?
    var urlPhoto: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        username    <- map["login"]
        urlPhoto    <- map["avatar_url"]
    }
    
}
