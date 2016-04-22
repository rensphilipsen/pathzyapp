//
//  Location.swift
//  Pathzy
//
//  Created by Rens Philipsen on 21-04-16.
//  Copyright © 2016 ExstoDigital. All rights reserved.
//

import Foundation

class Location {
    var id: Int
    var user : User
    var title: String
    var latitude: Double
    var longitude: Double
    var radius: Double
    
    init(id: Int, user: User, title: String, latitude: Double, longitude: Double, radius: Double) {
        self.id = id
        self.user = user
        self.title = title
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
    }
}
