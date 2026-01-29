/*:
## Exercise - Numeric Type Conversion

 Create an integer constant `x` with a value of 10, and a double constant `y` with a value of 3.2. Create a constant `multipliedAsIntegers` equal to `x` times `y`. Does this compile? If not, fix it by converting your `Double` to an `Int` in the mathematical expression. Print the result.
 */
print()
let x = 10
let y = 3.2
// let multipliedAsIntegers = x * y
// This won't work because their value types are different.
let multipliedAsIntegers = x * Int(y)
print("10 * 3.2 is around \(multipliedAsIntegers).")
//:  Create a constant `multipliedAsDoubles` equal to `x` times `y`, but this time convert the `Int` to a `Double` in the expression. Print the result.
let multipliedAsDoubles = Double(x) * y
print("10 * 3.2 is exactly \(multipliedAsDoubles).")
//:  Are the values of `multipliedAsIntegers` and `multipliedAsDoubles` different? Print a statement to the console explaining why.
print("The values for the two multiplication values are different because when multiplied as integers the double rounds down, but when multiplied as doubles then you have accuracy at a decimal level.")

/*:
[Previous](@previous)  |  page 7 of 8  |  [Next: App Exercise - Converting Types](@next)
 */
