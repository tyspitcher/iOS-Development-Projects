//
//  VehiclesModels.swift
//  TestingLab
//
//  Created by Tyson Pitcher on 6/5/26.
//

import Foundation

class Car: CustomStringConvertible {
    var year: Int
    var make: String
    var model: String
    var engineStarted: Bool = false
    var currentSpeed: Int = 0
    var doorNumber: Int
    var description: String {
        "\(year) \(make) \(model) has \(doorNumber) doors"
    }
    
    init(year: Int, make: String, model: String, doorNumber: Int) {
        self.year = year
        self.make = make
        self.model = model
        self.doorNumber = doorNumber
    }
    
    func startEngine() {
        engineStarted = true
    }
    
    func stopEngine() {
        engineStarted = false
    }
    
    func increaseSpeed(by amount: Int) {
        currentSpeed += amount
    }
    
    func decreaseSpeed(by amount: Int) {
        currentSpeed -= amount
    }
}
