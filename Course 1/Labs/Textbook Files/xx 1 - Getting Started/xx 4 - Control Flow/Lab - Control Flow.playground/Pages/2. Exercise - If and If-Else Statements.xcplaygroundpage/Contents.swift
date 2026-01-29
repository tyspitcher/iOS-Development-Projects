/*:
## Exercise - If and If-Else Statements
 
 Imagine you're creating a machine that will count your money for you and tell you how wealthy you are based on how much money you have. A variable `dollars` has been given to you with a value of 0. Write an if statement that prints "Sorry, kid. You're broke!" if `dollars` has a value of 0. Observe what is printed to the console.
 */

var dollars = 0
if dollars == 0 {
   print("Sorry, kid. You're broke!")
}
dollars = 45_000_000_000
    switch dollars {
case 0 :
    print("Sorry, kid. You're broke!")
case 1...100 :
    print("You're barely not broke.")
case 101...10_000 :
    print("Let's get you some assistance while you get on your feet.")
case 10_001...50_000 :
    print("Let's keep working hard, you'll get there.")
case 50_001...100_000 :
    print("Starting to see some daylight.")
case 100_000...150_000 :
    print("The government now thinks you're rich, bend over for the IRS.")
case 150_001...250_000 :
    print("Starting to see some daylight again.")
case 250_001...1_000_000 :
    print("Hey, I can actually put some away to retire someday!")
case 1_000_001...8_000_000 :
    print("Mo money, mo problems.")
case 8_000_001...1_000_000_000 :
    print("How does it feel to be in the top 1% of the top 1%?")
default :
    print("Good evening, Mr Musk.")
}
//:  `dollars` has been updated below to have a value of 10. Write an an if-else statement that prints "Sorry, kid. You're broke!" if `dollars` has a value of 0, but prints "You've got some spending money!" otherwise. Observe what is printed to the console.
dollars = 10
if dollars > 0 {
    print("You've got some spending money!")
} else {
    print("Sorry, kid. You're broke!")
}
//:  `dollars` has been updated below to have a value of 105. Write an an if-else-if statement that prints "Sorry, kid. You're broke!" if `dollars` has a value of 0, prints "You've got some spending money!" if `dollars` is less than 100, and prints "Looks to me like you're rich!" otherwise. Observe what is printed to the console.
dollars = 105
if dollars == 0 {
    print("Sorry, kid. You're broke!")
} else if dollars > 100 {
    print("Looks like you're rich!")
} else {
    print("You've got some spending money!")
}

/*:
[Previous](@previous)  |  page 2 of 9  |  [Next: App Exercise - Fitness Decisions](@next)
 */
