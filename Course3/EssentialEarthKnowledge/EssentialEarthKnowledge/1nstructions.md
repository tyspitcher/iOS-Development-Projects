---
id: CB7A124D-F67A-4C17-AEBD-BCC4DA7D22AD
name: #8 - Random APIs
type: project
assignDay: ND05
dueDay: ND09
location: 
---

# #8 - Random APIs Project Requirements - Due Dec 1, 2025

## Objective

Repeatedly demonstrate ability to retrieve data from an API, combining knowledge of URLSession and Table Views

## Details:

**Overview:** A new foreign exchange program allows young aliens to come live in Utah to learn more about Earth culture. You are building an educational app to teach them about 2-3 important Earth topics: dogs, United States Representatives, and, as a black diamond challenge, Nobel Prize winners. A collection of [project mockup screenshots](https://github.com/MTechMobileDevelopment/iOS-Development/tree/main/3%20-%20Networking%20and%20Data%20Storage/Assignments/Random%20APIs%20Mockup%20Screenshots) has been prepared by the exchange service and they have asked you to build it out in SwiftUI.

**Instructions:**
✅1. Review the mockup screenshots linked above.
✅3. As shown in the mockup, the Dog tab will include:
    ✅- One random image of a dog pulled from the API service. Access the API documentation here: [https://dog.ceo/dog-api/](https://dog.ceo/dog-api/)
    ✅- In order to ensure clean code organization, your API calls should be handled by a class called `DogAPIController` that ✅conforms to a custom protocol `DogAPIControllerProtocol`. For this project, you may choose whether to use MVVM or not, but 🚫either your view or view model should require a `DogAPIControllerProtocol` conforming object.
    ✅- A "name" text field where you can give the currently displayed dog a name
    ✅- A List view that stores all generated dogs and their names
        ✅- Pressing the "New Image" button should move the current image and dog name to the list view before generating a new one
        ✅- The cells of your List view should be contained in their own subview called `DogListCell`
        🚫- Tapping on a previously named dog should show a **detail view** that allows you to edit that dog's name; returning to the main view should show the dog's updated name in the list.
        ✅- You do not need to persist your saved dogs to disk.
4. As shown in the mockup, the Representative tab will include:
    ✅-  A list of representatives for a given zip code pulled from the API. Access the API documentation here: [https://whoismyrepresentative.com/api](https://whoismyrepresentative.com/api)
    ✅-  In order to ensure clean code organization, your API calls should be handled by a class called `RepresentativeAPIController` that conforms to a custom protocol `RepresentativeAPIControllerProtocol`. 🚫Either your view or view model should require a `RepresentativeAPIControllerProtocol` conforming object.
    ✅-  A search field that allows you to enter a Zip code to search for representatives
    ✅-  A List view that shows the returned results

## Black Diamond

3. Complete the Nobel Prize tab included in the screenshots.

  - Nobel Prize API: [https://nobelprize.readme.io/docs/getting-started](https://nobelprize.readme.io/docs/getting-started)

4. Give the app a revamped UI (Make it look good! Add colors! Your app is for alien teenagers, so make a good impression for Earth!)
5. Save data received from the API to the disk.

## Rubric:
- App functionality matches the mockup, allowing dog images to be fetched from the Dog API and given a name, and a list of United States Representatives, searchable by Zip Code
- Code is well organized, clean, and readable
- API call code is handled thoughtfully and efficiently
- Black Diamond requirements, as always, are optional.

## Notes:
- If you code this well and comment your code, it will be much easier to complete Part 2 of this project, which will be able to reuse much of the same backend code.

