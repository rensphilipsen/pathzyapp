//
//  User.swift
//  Pathzy
//
//  Created by Rens Philipsen on 21-04-16.
//  Copyright © 2016 ExstoDigital. All rights reserved.
//

import Foundation

class User {
    var id: Int
    var username: String
    var color: String
    
    init(id: Int, username: String, color: String) {
        self.id = id
        self.username = username
        self.color = color
    }
}