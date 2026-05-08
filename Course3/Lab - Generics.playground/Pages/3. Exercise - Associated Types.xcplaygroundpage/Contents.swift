/*:
## Exercise - Associated Types
 
 The `Toolbox` type only allows one type of item to be stored in each toolbox. The `MechanicToolbox` and `ArtToolbox` both conform to `Toolbox`. `MechanicToolbox` uses an explicit typealias declaration, while `ArtToolbox` allows the compiler to infer the asosociated type from the `listTools()` function's return type. For brevity's sake, the `Wrench`, `Brush`, and `WatchmakerTools` structs have been left blank; you may add properties to them to differentiate between instances of them better if you wish.
 */

protocol Toolbox {
    associatedtype Tool
    func listTools() -> [Tool]
}

struct Wrench { }
struct Brush { }
struct WatchmakerTools { }

struct MechanicToolbox: Toolbox {
    typealias Tool = Wrench
    func listTools() -> [Wrench] {
        return [Wrench(), Wrench()]
    }
}

struct ArtToolbox: Toolbox {
    typealias Tool = Brush
    func listTools() -> [Brush] {
        return [Brush()]
    }
}

//:  Create another struct, `WatchmakersToolbox` that conforms to `Toolbox`. Use an explicit `typealias` declaration to specify the type for `Tool`.
struct WatchmakerToolbox: Toolbox {
    typealias Tool = WatchmakerTools
    func listTools() -> [WatchmakerTools] {
        return [WatchmakerTools()]
    }
}

//:  Create another protocl, `DeliveryService`. Give it the associatedtype `Parcel` and a function `deliver(parcel: Parcel`). Create two more structs, `FoodCourier` and `MailCourier` that conform to `DeliveryService`, with reasonable associated types.
protocol DeliveryService {
    associatedtype Parcel
    func deliver(parcel: Parcel)
}

struct Food { }
struct Letter { }

struct FoodCourier: DeliveryService {
    typealias Parcel = Food
    func deliver(parcel: Food) {
    }
}
struct MailCourier: DeliveryService {
    typealias Parcel = Letter
    func deliver(parcel: Letter) {
    }
}
/*:
[Previous](@previous)  |  page 3 of 4  |  [Next: App Exercise - Workout API](@next)
 */
