//
//  Estate.swift
//  PTestMock
//
//  Created by Alex Ooi on 5/6/17.
//  Copyright © 2017 NYP. All rights reserved.
//

import UIKit

class Estate: NSObject {
    var name : String
    var population : Int
    var latitude : Double
    var longitude : Double
    
    required init(
        name: String,
        population: Int,
        latitude: Double,
        longitude: Double) {
        self.name = name
        self.population = population
        self.latitude = latitude
        self.longitude = longitude
    }
}
