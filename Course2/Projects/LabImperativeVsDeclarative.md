---
id: A3B3FB2A-B426-4EF5-A762-141B37C98DBB
name: Imperative vs Declarative
type: lab
assignDay: TP11
dueDay: TP12
location: 
---

# Imperative vs Declarative Lab Requirements - Due Oct 24, 2025

To prepare for job interviews where you may be asked about this topic, write one paragraph summarizing what Declarative Programming is. Answer the following questions in your paragraph:
What is declarative programming?
How does it compare to imperative?
Why do people often prefer it?
What is an analogy (NOT one of the examples already in the slides) for imperative and declarative programming?
How does it relate to SwiftUI?
How can you write code that matches this pattern?

Declarative and imperative programming are two different styles of programming. In the context of what we are learning, it is referring to the difference between UIKit which is imparative, and SwiftUI which is declarative. 
The way I keep track of which is which is because the word imparative means giving an authoritative command. I think of it more like you have to spell it out and tell the compiler everything it needs to do. Imperative is like when an artist composes a painting of a landscape. They decide exactly what color the sky will be and what the clouds will look like in the sky, then they decide if the background will have mountains or trees, then what is going to be the point of interest in the foreground- will it be an animal, or will it be an interesting plant? Each piece is decided on and executed by the artist. In UIKit, you must be much more explicit in construting your UI, which tends to lead to longer code comparative to SwiftUI.
I think of declarative more like in football when an offensive coordinater gives a play number from the sideline to the quarterback and then the quarterback looks at the list of plays on the cheat cheet on his wrist and then executes that play. The coach didn't spell out exactly what the play was, he just 'declared' the play number and the quarterback figured out what needed to be done. This style of writing code for UI allows for much shorter code. In SwiftUI, one way of writing declarative code would be using higher-order functions like .map(), .filter(), .reduce(), and so on. Although I'm not familiar with this yet, I understand that the Combine framework is another declarative element in SwiftUI. You can also make your own functions to use later to declare something you want to happen.
