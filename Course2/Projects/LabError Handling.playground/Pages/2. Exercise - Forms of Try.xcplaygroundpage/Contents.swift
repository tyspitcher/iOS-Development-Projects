/*:
## Exercise - Forms of Try
 
 The throwing function below produces an error if the user attempts to divide by zero. Call the function using `try` in a `do`/`catch` statement, printing the error to the console. Test using valid and invalid inputs to see the result.
 */

 enum MathError: Error {
    case divideByZero
 }

func divide(_ numerator: Double, by denominator: Double) throws -> Double {
    guard denominator != 0 else { throw MathError.divideByZero }
    return numerator / denominator
}

do {
    try divide(12, by: 3)
} catch {
    MathError.divideByZero
}
do {
    try divide(12, by: 0)
} catch {
    MathError.divideByZero
}

//:  Now call the function using `try?`. Since errors are not handled when using `try?`, you do not need a `do`/`catch` statement. Test using valid and invalid inputs, printing the result.
try? divide(12, by: 6)
try? divide(12, by: 0) //returns nil


//:  Finally, call the function using `try!` and test it with an invalid input. What happens if the input is invalid? Write a comment explaining your answer, then set a valid input.
try! divide(12, by: 6)
//try! divide(12, by: 0) //crashes app

/*:
[Previous](@previous)  |  page 2 of 4  |  [Next: Exercise - Associated Values](@next)
 */
