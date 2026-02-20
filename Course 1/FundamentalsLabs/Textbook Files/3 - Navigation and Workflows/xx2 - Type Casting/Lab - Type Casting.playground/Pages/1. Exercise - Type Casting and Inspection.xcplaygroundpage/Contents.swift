/*:
## Exercise - Type Casting and Inspection

 Create a collection of type [Any], including a few doubles, integers, strings, and booleans within the collection. Print the contents of the collection.
 */
var junk : [Any] = ["motor cars", "handlebars", "bicycles", 4, 2.0, "broken-hearted", "jubilee", true, 1970, "McCartney"]
print(junk)

//:  Loop through the collection. For each integer, print "The integer has a value of ", followed by the integer value. Repeat the steps for doubles, strings and booleans.
for item in junk {
    if let s = item as? String {
        print("The junk string says \(s)")
    } else if let i = item as? Int {
        print("The integer has a value of \(i)")
    } else if let b = item as? Bool {
        print("The bool items in junk are \(b)")
    } else if let d = item as? Double {
        print("The double in junk has a value of \(d)")
    } else {
        print("Unknown type \(item)")
    }
}

//:  Create a [String : Any] dictionary, where the values are a mixture of doubles, integers, strings, and booleans. Print the key/value pairs within the collection
var songDictionary : [String : Any] = ["When I'm" : 64, "Is It" : true, "No." : 4.0, "Cool Song No." : 2, "Say It Ain't" : "So", "Rhythm" : false]
print(songDictionary)
//:  Create a variable `total` of type `Double` set to 0. Then loop through the dictionary, and add the value of each integer and double to your variable's value. For each string value, add 1 to the total. For each boolean, add 2 to the total if the boolean is `true`, or subtract 3 if it's `false`. Print the value of `total`.
var total : Double = 0

for value in songDictionary.values {
    if let d = value as? Double {
        total += d
    } else if let i = value as? Int {
        total += Double(i)
    } else if value is String {
        total += 1
    } else if let b = value as? Bool {
        total += b ? 2 : -3
    }
}
print("total = \(total).")
//:  Create a variable `total2` of type `Double` set to 0. Loop through the collection again, adding up all the integers and doubles. For each string that you come across during the loop, attempt to convert the string into a number, and add that value to the total. Ignore booleans. Print the total.

var total2 : Double = 0
for newValue in songDictionary.values {
    if let d = newValue as? Double {
        total2 += d
    } else if let i = newValue as? Int {
        total2 += Double(i)
    } else if let s = newValue as? String {
        total2 += Double(s.count)
    } else {
    }
}
print("total2 = \(total2)")
/*:
page 1 of 2  |  [Next: App Exercise - Workout Types](@next)
 */
