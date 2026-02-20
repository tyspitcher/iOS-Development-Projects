/*:
## App Exercise - Fitness Tracker: Constant or Variable?
 
 >These exercises reinforce Swift concepts in the context of a fitness tracking app.
 
 There are all sorts of things that a fitness tracking app needs to keep track of in order to display the right information to the user. Similar to the last exercise, declare either a constant or a variable for each of the following items, and assign each a sensible value. Be sure to use proper naming conventions.
 
- Name: The user's name
- Age: The user's age
- Number of steps taken today: The number of steps that a user has taken today
- Goal number of steps: The user's goal for number of steps to take each day
- Average heart rate: The user's average heart rate over the last 24 hours
 */
let userName : String
print("I used a constant because people's names don't typically change, and a string because that type works best for a name.")
var age : Int
print("I used a variable because people's ages change as they get older and an integer because that works best for age.")
var dailySteps : Int
print("I used a variable because throughout the day the steps will increase and the total will be different each day, and an integer will be the best value to use for counting steps.")
let dailyGoal : Int
print("I used a constant because people typically have a goal in mind that stays the same, and an integer is the best way to track the number of steps.")
var avgHeartRate : Int
print("I used a variable because heart rates change frequently, and I used an integer because the value will be a whole number.")

/*:
 Now go back and add a line after each constant or variable declaration. On those lines, print a statement explaining why you chose to declare the piece of information as a constant or variable.
 
[Previous](@previous)  |  page 6 of 10  |  [Next: Exercise - Types and Type Safety](@next)
 */
