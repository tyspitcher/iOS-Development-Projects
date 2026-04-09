import UIKit

func MadLibGenerator (
    adjective1 : String,
    noun1 : String,
    pastTenseVerb : String,
    adverb : String,
    noun2 : String,
    adjective2 : String,
    noun3 : String,
    presentTenseVerb : String,
    number : String,
    pluralNoun : String,
    exclamation : String,
    adjective3 : String
    ) -> String {
        
if  adjective1.isEmpty ||
        noun1.isEmpty ||
        pastTenseVerb.isEmpty ||
        adverb.isEmpty ||
        noun2.isEmpty ||
        adjective2.isEmpty ||
        noun3.isEmpty ||
        presentTenseVerb.isEmpty ||
        number.isEmpty ||
        pluralNoun.isEmpty ||
        exclamation.isEmpty ||
        adjective3.isEmpty
    {
return "Invalid Input"
    }
        
let randomStorySelector = Int.random(in: 1...3)
       
    switch randomStorySelector {
    case 1 : return "\"THE SPACE ADVENTURE\": It was a \(adjective1) day when the first \(noun1) landed on Mars. The astronaut \(pastTenseVerb) \(adverb) toward the hatch and opened it. Inside, they found a glowing \(noun2) and a(n) \(adjective2) \(noun3). \"I hope these things don't \(presentTenseVerb),\" the captain whispered. Suddenly, \(number) tiny \(pluralNoun) jumped out and yelled, \"\(exclamation)!\" It was the most \(adjective3) thing anyone had ever seen."
    case 2 : return "\"THE COOKING DISASTER\": To make a \(adjective1) cake, you must start with a fresh \(noun1). My grandmother always \(pastTenseVerb) \(adverb) while mixing the batter in her antique \(noun2). Next, add one \(adjective2) \(noun3) and make sure it doesn't \(presentTenseVerb) while baking. After \(number) minutes, the \(pluralNoun) will be ready. If you are like me, you will say \"\(exclamation)! This smells positively \(adjective3).\" when you smell your \(adjective1) cake cooking."
    default : return "\"THE ZOO BREAKOUT\": The \(adjective1) zookeeper realized that the \(noun1) had escaped. The animal \(pastTenseVerb) \(adverb) through the gift shop looking for a \(noun2). It grabbed a(n) \(adjective2) \(noun3) and started to \(presentTenseVerb) right in front of the tourists. This happened \(number) times before the \(pluralNoun) arrived. \"\(exclamation)!\" cried a witness, \"that is one \(adjective3) creature!\""
    }
}

print(MadLibGenerator(
    adjective1: "sloppy",
    noun1: "parakeet",
    pastTenseVerb: "sprinted",
    adverb: "gingerly",
    noun2: "popsicle",
    adjective2: "crooked",
    noun3: "rail road tie",
    presentTenseVerb: "spit",
    number: "3,967",
    pluralNoun: "bats",
    exclamation: "Jeepers",
    adjective3: "spunky")
)
