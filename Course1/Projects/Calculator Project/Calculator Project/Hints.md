#  Hints

##  Hints on how to set up calculator logic

1. You should never feel limited in the number of variables you create. Good developers will try to avoid creating redundant ones, but it's better to have too many than too few, especially when you're learning.
2. A calculator is keeping track of a few different variables at any given time.
    a. What's being displayed on screen?
    b. What number (or numbers) has the user typed in?
    c. What operations have they typed in?
    d. What order do they happen in?
    
Let's reason through a set of operations to see how this plays out in code.

1. The user presses 1, and then 4.
    - Storing these as plain integers creates issues. Having 1 and 4 separately means figuring out some way to translate that into 14. Fortunately, Swift Strings can do this for us already. We can store it as "14" until we're ready to use it for math, at which point we convert it to the number 14 using `Double("14")`. This will return an optional, so you'll need to unwrap it, but this takes us from individually entered digits to full numbers we can work with.
2. The user presses +.
    - Different calculators work differently. You can make yours more resemble the iPhone's Calculator app's functionality, but it is easier to go back to an old cheap calculator, where pressing the next operation displayed the result of the previous one; that is, if you typed "1 + 3 -", at the moment you hit "-" the calculator would show "4". Since we haven't done any operations yet, the total will be whatever number you put in first, so for now nothing changes on screen. We should store that we pressed plus in a variable somewhere, maybe called `lastEnteredOperator`.
3. The user presses 5.
    - Now, the screen should only show the number 5, representing the current number being typed in. When we replace the previously entered number on the display, we should be storing it somewhere so that we don't lose it, perhaps a variable called `runningTotal`.
4. The user presses -.
    - We're now ready to actually do some math. We should display the result of the previous operation. We now use our three stored variables to carry this out: combining `runningTotal`, the operator, and `display` gives us 14 + 5. Display 19 to show the user the result before they start the next one. Since they pressed -, store that in `lastEnteredOperator`, and store 19, the result of their math, in `runningTotal`.

At this point, the logic should be the same for any of the other operators (divide, multiply), and similar for equals. 
- Decimals and the inverse sign (aka negative, aka `-`) are easy because you can simply store them in the display String like any other number entered, and Swift will properly resolve them to be negative; you'll just need to add a little extra logic to avoid multiple inputs for the decimals and toggle the negative sign.
- Backspace only needs to delete from the currently displayed number; no need to worry about undoing operations beyond that.
- Clear should just set the display to an empty string (without deleting `runningTotal`), and AC (All Clear) should also empty `lastEnteredOperator` and `runningTotal`.
- Percent is black diamond only, but as a tip, think of percent as just being a shortcut for multiplying by 1/100. To add to your confusion, on Apple's Calculator you can also use % as a modulus operator.
