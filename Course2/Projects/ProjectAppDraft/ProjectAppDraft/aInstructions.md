---
id: 7F41D29A-9DE0-49BA-80D6-104E664DC025
name: #7 - App Draft
type: project
assignDay: TP23
dueDay: TP28
location: 
---

# #7 - App Draft Project Requirements - Due Nov 13, 2025

## Overview

In a few weeks we will begin our course titled "Full App Development", in which you will imagine you have been contracted to create an app which interacts with an API.

You must choose between building a Social Media App or a Class Calendar App. Whichever you choose now will determine which you are building during that course. While both apps will draw on the same skills, the Calendar app API is generally more complex than the Social Media one, and thus is a more challenging project.

For this assignment, you will begin the initial drafting of that project. Imagine your employer has asked you to **build the UI of the app**, but says they **have not yet finalized the backing API**. As such, you will **<u>not</u>** be adding any networked features at this point of development, but should use your current understanding of SwiftUI, MVVM, SOLID, and working with the Web to begin outlining the views, files, and navigational structure you will need in the future once the API is available.

### Notes on Planning Ahead:

- Since you know you will be iterating on this project down the road, it is important that your design is **well thought out and documented**. 

- You will need to create custom data models for the kinds of data this app will display. For the social media app, you will need structs such as `User`, `Post`, `Comment`, and possibly more. For the calendar app, you will need `CalendarEntry`, `LessonOutline`, and `Assignment`.

- Wherever data from the API will be displayed to the user, you may use placeholder data, but should design it so those placeholders are easily replaced by the actual results of an API call. For example, this Text view representing the user's display name uses a String literal which will require revision:

    `Text("Jane Madsen")`

    While this may not seem difficult to revise, with multiple views and a great deal of placeholder data, future revisions become more complex. On the other hand, the example below derives its data from a View Model appropriately.

    `Text(viewModel.user.userDisplayName)`

    This way, once the API becomes available, you will only need to change how your view model sources its data, and not need to touch the code for your Views.
    
- Be aware that your planning to integrate the API will not be perfect and does not need to be. This is an exercise in doing your best to plan for future updates and then experiencing making those changes in the future in a simulation of imperfect real world development processes.

## Requirements

The overall layout and styling of your app is primarily up to you. That said, your imaginary employer wishes you to be sure to include the following required elements. If there are things about this list you would like to tweak, consult with an instructor.

## Code Design Requirements (Both Project Choices)
1. Code is commented thoroughly.
1. Code is designed using MVVM architecture.
1. Code follows SOLID design principles where possible. 
    - SOLID is more applicable to back-end development, so for this front-end UI draft, you likely won't find a lot of opportunities to follow SOLID, but take some time to review the principles nonetheless.

## Tech Social Media App Requirements

#### Major Views
1. A Tab parent view.
1. A **user profile page** tab.
    ✅- This screen should show the **currently logged in user**.
    ✅- It should show a **profile photo** and a **background (cover) photo** at the top of the screen.
    ✅- It should show the user's **first name, last name, username, bio, and tech interests**. Since this app is designed for Tech Industry workers, the tech interests is a place for them to specifically list the topics that they are interested in.
    ✅- It should have **at least one post** (representing the most recent user post) under the user details.
1. ✅A second tab where a **timeline of posts** are displayed.
    - This screen displays all users' posts on the services, including your own posts and everyone else's. 
    - Show at least **one post from your user** and **one post from another user**.
    - The post should display the **number of likes and comments**. The number of comments should be tappable to display the comments listed on the post; this should transition the user to a **new view where users can see the list of comments**. 
        - Make sure you have at least one post with placeholder comments on it so that the comment UI can be seen.
    - These posts should use UI that is extensible down the road to show as many posts as are retrieved from the API. (In other words, make sure you are using **reusable, automatically generated views**.)

#### Child Views
7. ✅The User Profile tab should include a button that pops up a **modal sheet for editing their profile information**.
    ✅- This sheet should include the **appropriate fields** for updating this data, and a **save button** that dismisses the view when finished.
    ✅- This sheet does not need to actually function, since updating the user's profile data will not be done locally but instead will trigger an API call.
1. The Posts tab should include a button that presents **a sheet view for making a new post**.
    - Should include a field for the title and body of the post.
    - Should include a **button that submits** the post and dismisses the view. Like before, this does not need to make any changes to your app since no API calls are implemented yet.

#### Black Diamond
9. Include an Edit Post button and functionality. The specific implementation is up to you.
1. Tapping on another user in their post displays their user profile view.
1. Any other UI/features that the app can reasonably have--be aware that the API will not support posting images, adding friends, or anything beyond the features already implied by the UI above, but you are still welcome to add those things to your are UI.


## Tech Social Media App Rubric

#### Code

- [ ] Code is commented
- [ ] Code is MVVM
- [ ] Code follows SOLID (if possible)

#### Views
- [ ] User profile view
    - [ ] Logged in user's first name, last name, username, bio, tech interests
    - [ ] Most recent post from user
- [ ] Timeline
    - [ ] At least one post from you and one post from someone else
    - [ ] Likes and Comments Count on Posts
    - [ ] Tapping shows comment list (at least one post should have a comment to demo this)
    - [ ] Reusable views
- [ ] Edit Profile View
    - [ ] Fields for editing data
    - [ ] Save button that dismisses view (doesn't need to actually update data)
- [ ] New Post View
    - [ ] Title and Body fields
    - [ ] Submit button that dismisses the view (does not need to actually save any data)
- [ ] Optional Black Diamond Elements
