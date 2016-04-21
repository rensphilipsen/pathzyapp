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
    var title: String
    var latitude: Double
    var longitude: Double
    var radius: Double
    var strokeWidth: Double
    var strokeColor: String
    var fillColor: String
    
    init(id: Int, title: String, latitude: Double, longitude: Double, radius: Double, strokeWidth: Double, strokeColor: String, fillColor: String) {
        self.id = id
        self.title = title
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
        self.strokeWidth = strokeWidth
        self.strokeColor = strokeColor
        self.fillColor = fillColor
    }
}
