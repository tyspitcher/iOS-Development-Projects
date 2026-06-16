//
//  TestingLabTests.swift
//  TestingLabTests
//
//  Created by Tyson Pitcher on 6/5/26.
//

import Testing
@testable import TestingLab

struct CarTests {
    let car = Car(year: 1988, make: "Volkswagen", model: "Jetta", doorNumber: 4)
    
    @Test func engineStartTest() {
        car.startEngine()
        #expect(car.engineStarted == true)
    }
    
    @Test func speedTest() {
        car.increaseSpeed(by: 10)
        #expect(car.currentSpeed == 10)
    }
    
    @Test func carSlowing() {
        car.currentSpeed = 10
        car.decreaseSpeed(by: 10)
        #expect(car.currentSpeed == 0)
    }

}
