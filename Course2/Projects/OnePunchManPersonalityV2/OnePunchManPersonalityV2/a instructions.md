---
id: 13725F61-2EDE-42EE-BD0E-B7798B50988D
name: #5 - Personality Quiz Part 1
type: project
assignDay: TP06
dueDay: TP08
location: 
---

# #5 - Personality Quiz Part 1 Project Requirements - Due Oct 20, 2025

## Overview
The year is 2014 and BuzzFeed has decided to build an app that hosts their famous popular BuzzFeed Quizzes. Inspired by such classics as [What Kind Of Dog Are You?](https://www.buzzfeed.com/chelseamarshall/what-kind-of-dog-are-you) and [What City Should You Actually Live In?](https://www.buzzfeed.com/ashleyperez/what-city-should-you-actually-live-in), your task is to build an app with a single personality quiz as a proof of concept.
## Notes:
Included in the assignments folder for this unit are screenshots of what your finished project may look like. You are welcome to customize the appearance as you see fit.
## Instructions:
1. Your quiz must include each of the following types of questions, each of which will need its own view: ranged questions where the user uses a slider to indicate where they fall on a scale; single choice questions where the user can only select one answer from a Picker; and multiple choice questions where the user can select multiple answers using Toggles. Start by creating each of the following View structs: ✅`TitleView`, ✅`QuestionFlowView`, ✅`SingleResponseSubview`, ✅`MultipleResponseSubview`, ✅`RangedResponseSubview` and ✅`ResultsView`. ✅(`QuestionFlowView` will be a parent view for the three subviews.)
2. You will need data that supports your app by listing the questions and answers. ✅You'll want to associate each answer that a user selects with a particular outcome. For the example below, we're using a "Which animal are you?" quiz, where each answer points towards either a lion, a cat, a rabbit, or a turtle. You should replace this with your own topic, questions, and possible outcomes in your quiz.
``` swift
✅struct Question {
    var text: String
    var type: ResponseType
    var answers: [Answer]
}
✅enum ResponseType {
    case single, multiple, ranged
}
```
``` swift
✅struct Answer {
    var text: String
    var type: AnimalType *** Changed to points because I am assigning point values
}
✅enum AnimalType {
    case lion, cat, rabbit, turtle
}
```
3. ✅Next, you'll want to create an array that holds the actual question literals you'll be presenting to the user. A sensible place for this would be a new class called `QuizManager` with a property called `questionList`. Below is an example from the "Which animal are you?" example quiz.
    - Include a minimum of 4 questions in your `questions` array. Each question should have exactly 4 answers to choose from.
    
    ✅make an @Observable class due to changes that will be made later
``` swift
✅ struct QuizManager { 
    let questionList: [Question] = [
        Question(
            text: "Which food do you like the most?",
            type: .single,
            answers: [
                Answer(text: "Steak", type: .lion),
                Answer(text: "Fish", type: .cat),
                Answer(text: "Carrots", type: .rabbit),
                Answer(text: "Corn", type: .turtle)
            ]
        ),
        Question(
            text: "Which activities do you enjoy?",
            type: .multiple,
            answers: [
                Answer(text: "Swimming", type: .turtle),
                Answer(text: "Sleeping", type: .cat),
                Answer(text: "Cuddling", type: .rabbit),
                Answer(text: "Eating", type: .lion)
            ]
        ),
        Question(
            text: "How much do you enjoy car rides?",
            type: .ranged,
            answers: [
                Answer(text: "I dislike them", type: .cat),
                Answer(text: "I get a little nervous", type: .rabbit),
                Answer(text: "I barely notice them", type: .turtle),
                Answer(text: "I love them", type: .lion)
            ]
        )
    ]
}
```

4. Now let's build some UI. The simplest UI should be designing a title screen. This should display ✅the title of your quiz, ✅a "Begin" button, and ✅an image (any Google Image result related to your topic should do, but make sure to use the CreativeCommons filter--avoid uploading copyrighted images to your GitHub account). 
5. In the future, we'll want that Begin button to navigate to the next screen, so ✅use a NavigationLink, but leave its destination empty for now.
2. We will next fill out the `body` of each the three `Subview` structs. For now we will hold off on adding any logic or navigation; continue to focus on building UI. The UI in the body will need to display some question data, so add a ✅`let question: Question` property to each subview. It does not need to be marked @State, because the questions will not change during the usage of the app; it will always be the same list.
3. ✅In `MultipleResponseSubview`, add four toggles, one for each `Answer` in `question.answers`. ✅Bind each toggle to its own `@State` boolean property. (You might be tempted to use a ForEach, but this approach gets tricky when each toggle needs its own boolean binding. For now just manually add four Toggles, each with a binding.) ✅Label each answer the text in `answer.text`.
4. ✅In `SingleResponseSubview`, add a `Picker` that allows users to choose from the list of answers in `question.answer`. Create a `@State` variable to hold their selected choice.
5. ✅In `RangedResponseSubview`, add a `Slider` that allows users to select a value on a sliding scale. ✅Below the scale, display the four answers from left to right. But how do we turn a number into one of the four answers? ✅First, store the selected value in an `@State` variable. ✅Then, use a stepped range on the slider to limit them to only certain positions; in other words, the user will only be able to select 0, 1, 2, or 3, which will correspond to one of the available answers.
6. ✅In `ResultsView`, add a property called `resultText` of type `String` with a default empty value. ✅Add a Text view to display this string. You can make this view more complex later on if you wish but for now we will keep it simple.
7. ✅Configure your `QuestionFlowView` to also have a `question: Question` property. Once again, you do not need to mark it @State. ✅In the body, add a `Text` label to display the actual text of the question; ✅below that,switch on `question.type` to determine which of the three question type subviews to show. ✅In each case, show the appropriate Subview and pass the question being displayed through the subviews' initializers.
8. ✅We're now ready to start configuring our navigation. Put a `NavigationStack` around your top-level view in `TitleView`, and ✅configure your `NavigationLink` to show the `QuestionFlowView`. ✅For the moment leave the view's `question` parameter blank. In order to know which question to display, we need to look it up in the list we put in QuizManager, so we will make that accessible next.
9. ✅Make your `QuizManager` observable. ✅Add an `@State` property called `quizManager` to your `TitleView`. ⭐️To finish setting up the `NavigationLink`, ✅get the first question in the array of questions in `quizManager` and pass it to the initializer we previously left blank.
10. ✅Since future views will also need access to QuizManager, use a `.environment` modifier to add it to `QuestionFlowView`'s environment.
    ^^^^^^^^^ Switched to @Observable class to help with later adjustments
11. To continue navigating, we will next need to ✅add a `NavigationStack` to `QuestionFlowView`. ✅Add a `NavigationLink` to the toolbar of `QuestionFlowView`. Where should this lead to? ✅We will display another `QuestionFlowView` each time this button is pressed, initializing the view with the next question in our array. Like in title screen, we will need a `Question` to display, but unlike before, we can't just use the first one in the array, so our next step will be to ✅code the logic that chooses the next question.
12. First ✅get the `QuizManager` out of the environment using `@Environment` in `QuestionFlowView`. Then, find the ✅current question's index in the quiz manager's question array. Now you can ✅use that index to find the next question in the array. ✅If there are no more questions in the array, our NavigationLink should instead take us to `ResultsView`, so ✅use an if statement to check whether there are no more questions left and decide which view to display.
13. There's one piece of the puzzle still missing. When a user selects an answer, we need to store what they chose so we can calculate their results later. In `QuizManager`, ✅create a collection called `selectedAnswers` to store their selections, ✅and a function called `selectAnswers(_: [Answer])` which adds the chosen answer to the array. ✅Call `selectAnswers` in each of your subviews, using a ✅`.onChange { }` modifier to detect when a user's selection has changed.
14. ✅There's a bug in the `selectAnswers()` function. It works if the user doesn't make any mistakes, but what if a user wants to either view or change their answer later? Currently, there's no good way to remove previously submitted answers and put in new ones. It falls to you to solve this problem as a test of your problem solving skills. Here are some ideas you can consider to help you get started, but you don't have to use any/all of them:
        - You may need to change your existing data structures
        - You may need to add more parameters to your function signature
       ✅ - You may need to store selected answers in a different collection than `[Array]` **Dictionary**
        - You probably **don't** need to change any UI or navigation; the function, collection, and data structures are the only pieces in this puzzle.

1. ✅Now that we have a collection of answers, create a function in `QuizManager` called `calculateResults()`. Whichever `type` they selected most often determines what their result is, so tally up the user's selected answers  and return a `String` with a short paragraph describing their results.
2. Finally, access the ✅`quizManager` in `ResultsView` using `@Environment`, and ✅call `calculateResults()` in a `.onAppear { }` modifier.
Finalize your app by testing it thoroughly and adding any polish to the UI you would like.
You will present this project! Students will take turns taking each others' quizzes, so be prepared to share your quiz with others.

Additional Requirements which will supersede prior instructions:
Following the steps below, update one of your personality quiz views to use a ViewModel instead.
Make sure your structs are defined in a separate file (should be doing this anyway)
Create a class, usually ending in ViewModel, to hold all logic from the view, and mark it @Observable
Move all functions, including standalone functions, button closures, and so on, to the ViewModel. Never update the ViewModel’s state directly; instead, use functions to keep the logic for updates all in one place.
Move all stored properties, @State variables and beyond, into ViewModel
Initialize the view model as an @State property in View. This should now be your only property, and any views that update data should call through to its functions. Views can read its data directly, but should only update it through a function.

