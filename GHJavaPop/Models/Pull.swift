//
//  Pull.swift
//  GHJavaPop
//
//  Created by Fredyson Costa Marques Bentes on 04/01/17.
//  Copyright © 2017 home. All rights reserved.
//

import Foundation
import ObjectMapper

class Pull: Mappable {
    
    // Properties
    
    var title: String?
    var body: String?
    var creationDate: String?
    var url: String?
    var user: User?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        title           <- map["title"]
        body            <- map["body"]
        creationDate    <- map["created_at"]
        url             <- map["html_url"]
        user            <- map["user"]
    }
    
}
