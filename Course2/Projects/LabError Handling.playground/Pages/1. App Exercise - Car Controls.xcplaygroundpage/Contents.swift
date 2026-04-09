/*:
## App Exercise - Car Controls
 
 You are building an app that allows remote control of a new car. A function `startEngine()` has been created for you. If the gas tank is empty, an error called `RemoteError.outOfGas` should be thrown. Create an enum called `RemoteError` that conforms to the Error protocol, add the `outOfGas` case, then throw it in the startEngine function.
 */

var engineRunning = false
enum RemoteError: Error {
    case outOfGas
    case doorsNotLocked
}
func startEngine(gallonsGasInTank: Int) throws {
    if gallonsGasInTank >= 0 {
        engineRunning = true
    } else {
        // Throw an error
        RemoteError.outOfGas
    }
}

//:  The second function, `turnOnClimateControl(temp:)`, should turn on the heater or A/C so that the user can adjust the climate in their car before getting in. If the engine is off, this function will turn it on automatically before running the climate controls. In the if statement, call the `startEngine` function, using a `try` keyword. Mark the `turnOnClimateControl(temp:)` function with `throws` so that errors caused by `startEngine` are passed along.

var currentTemperature: Int = 81

func turnOnClimateControl(temp: Int) throws {
    if engineRunning == false {
        // Start engine
        try startEngine(gallonsGasInTank: 10)
    }
    
    currentTemperature = temp
}

//:  Now use a `do`/`catch` statement to try calling `turnOnClimateControl(temp:)`. Print any caught errors to the log.
do {
    try turnOnClimateControl(temp: 70)
} catch {
    print(error)
}

//:  Lastly, users should be able to lock and unlock the doors of their car remotely. This function should only work if the car is currently in park. A `Gear` enum has been provided; create a throwing function called `toggleDoorLocks` that checks whether the car is in park, toggling the `locked` variable if so and throwing an error if not. Add an appropriate error to the RemoteError enum cases for this purpose.

enum Gear {
    case park, drive, neutral, reverse
}

var selectedGear: Gear = .drive
var locked = true

func toggleDoorLocks() throws {
    if selectedGear == .park {
        locked.toggle()
    } else {
        RemoteError.doorsNotLocked
    }
}
//:  Test out your `toggleDoorLocks` function in a do/catch statement.
do {
    try toggleDoorLocks()
} catch {
    print(error)
}

/*:
page 1 of 4  |  [Next: Exercise - Forms of Try](@next)
 */
