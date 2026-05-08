/*:
## Exercise - Generic Types
 
 While most collections involve working with values at the beginning, end, or a specific index or the collection, this array only allows you to retrieve items from the center of the array. You know when you look at a stack of plates in the cupboard and the top one didn't get clean enough or it's a little bit dusty, but getting the bottom one would be too hrd to fish out, so you grab one from the middle of the stack? So this will be our "StackOfPlates" collection type.
 */

struct StackOfPlates<Value> {
    private var array = [Value]()
    init(array: [Value]) {
        self.array = array
    }
    
    mutating func push(_ value: Value) {
        array.append(value)
    }

    mutating func pop() -> Value? {
        guard !array.isEmpty else { return nil }
        let middleIndex = (array.count - 1) / 2
        return array.remove(at: middleIndex)
    }
}

//:  Convert the StackOfPlates struct to be a generic type so that it can hold any type, not just String. Test it below by creating several StackOfPlates instances using different types.
var bluePlates = StackOfPlates(array: ["Ezra", "Howard", "Gordon", "Thomas", "Russell"])
var redPlates = StackOfPlates(array: [21, 35, 631, 463, 75])
var greenPlates = StackOfPlates(array: [234.6, 34.4, 66.8, 43.43, 412.9])
print(bluePlates.pop())
redPlates.push(4567)
print(redPlates)
print(greenPlates.pop())
//: Use an extension of StackOfPlates to conform it to Identifiable so that one stack of plates has a separate ID than another.
extension StackOfPlates: Identifiable where Value: Hashable {
    var id: Int { array.hashValue }
}

/*:
[Previous](@previous)  |  page 2 of 4  |  [Next: Exercise - Associated Types](@next)
 */
