/*:
## Exercise - Create a Protocol
 
 Create a protocol called `Vehicle` with two requirements: a nonsettable `numberOfWheels` property of type `Int`, and a function called `drive()`.
 */
protocol Vehicle {
    var numberOfWheels: Int { get }
    func drive()
}

//:  Define a `Car` struct that implements the `Vehicle` protocol. `numberOfWheels` should return a value of 4, and `drive()` should print "Vroom, vroom!" Create an instance of `Car`, print its number of wheels, then call `drive()`.
struct Car: Vehicle {
    var isThreeWheeler: Bool = false
    var numberOfWheels: Int { isThreeWheeler ? 3 : 4 }
    func drive() {
        print("Vroom, vroom!")
    }
}
let myJalopy = Car()
print(myJalopy.numberOfWheels)
print(myJalopy.drive())
//:  Define a `Bike` struct that implements the `Vehicle` protocol. `numberOfWheels` should return a value of 2, and `drive()` should print "Begin pedaling!". Create an instance of `Bike`, print its number of wheels, then call `drive()`.
struct Bike: Vehicle {
    var numberOfWheels: Int { 2 }
    func drive() {
        print("Begin pedaling!")
    }
}
let notMyUnicycle = Bike()
print(notMyUnicycle.numberOfWheels)
print(notMyUnicycle.drive())

var vehicle: Vehicle

//vehicle = Bike()
//print(vehicle.numberOfWheels)
//var car = Car()
//car.isThreeWheeler = true
//vehicle = car
//print(vehicle.numberOfWheels)
/*:
[Previous](@previous)  |  page 3 of 5  |  [Next: App Exercise - Similar Workouts](@next)
 */
