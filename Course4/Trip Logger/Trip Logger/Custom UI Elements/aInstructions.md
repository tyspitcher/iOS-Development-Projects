---
id: 5C913F71-2911-414C-99FC-C68DA635B877
name: #11 - Trip Logger
type: project
assignDay: ST09
dueDay: ST15
location:
---

# #11 - Trip Logger Project Requirements - Due Jan 20, 2026

## Objectives
- Demonstrate comprehensive understanding of SwiftUI
- Use advanced navigational structure
- Use MVVM to organize code
- Use LazyGrids to create a grid view
- Use SwiftData to store user data

## Overview
This project is inspired by the trip logging app [Polarsteps](https://www.polarsteps.com/?locale=en). Your goal is to create an app in SwiftUI that combines photos, text, and location data into a journal recounting a vacation. Screenshots of what the final product should look like are below.

## Instructions
A starter project has been provided. Follow the steps below to finish the app.

1. ✅Review and understand the existing code, especially the MapKit `Map` presented on `TripMapScreen`. You may want to review the documentation for MapKit as well.
2. ✅Add an "Add" button to the navigation bar in `ContentView`.
3. ✅Configure the Add button to present a sheet (modal) with the `NewTripScreen`. Embed it in a `NavigationStack` so that users can navigate through the three screens provided for a new trip.
4. ✅Add a `TextField` and a "Next" button to `NewTripScreen`. The "Next" button should be disabled when the TextField is empty.
5. ✅Make the "Next" button present the `PlacePinScreen`. Pass through the name the user selected and use it to create a `Trip` object.
6. ✅Some code has already been provided for you on `PlacePinScreen`. ✅Create a new `JournalEntry` in the `placePin(reader:location:)` function using the `coordinate` provided and ✅add it to the `Trip` object's collection `journalEntries`.
7. ✅Display a pin on the `Map` by adding a `Marker` to its closure. ✅You can use the `Marker(item:)` initializer by accessing `journalEntry.location.mapItem`. ✅You will need to retrieve the journal entry you just added to the `Trip` to accomplish this.
8. ✅Add a "Next" button that transitions to `SetUpPinScreen`, passing through the `Trip` object you created, which should now contain one `JournalEntry`.
9. ✅On `SetUpPinScreen`, create `TextField`s that bind directly to the journal entry's `name` and `text` properties. ✅You most likely will need to simply force unwrap `trip.journalEntries.first` in order to achieve this efficiently, which is okay for this project.
10. ✅Add a `PhotoScrollView` to the screen as well. We will finish configuring this view in a moment.
11. ✅Add a save button. Pressing it should dismiss the presented sheet and save the `Trip` to the modelContext.
12. ✅In `PhotoScrollView`, use a `ForEach` to display all the photos in a `JournalEntry`. Note that the photos are stored as `Data`; use `UIImage(data:)` to convert it for display.
13. Now, set up the `Edit` buttons in the `TripMapScreen` and its child `Journal` to allow the user to edit existing trips (including **adding more `JournalEntries` by dropping new pins on the map**, plus changing the name or deleting a trip altogether), and edit individual journal entries (change the name, text, and photos), respectively. The exact implementation of this step is up to you.
14. Review your work and make sure the styling is complete and well configured. Use `Spacer`s and `.padding()` where needed.

## Black Diamond
15. There is currently a bug where reopening and closing the photo picker will re-add any selected photos to the journal entry. Fix this.
16. Make it so that users can change the dates associated with journal entries.
17. Using the dates associated with journal entries, draw a path on the map representing the path the user took on their journey. This feature is built in to MapKit, it's just a matter of configuring it.

## Rubric
- User can create a new trip, including its name and adding its first pin on the map, with associated photos, name, and date for the pin.
- User can add further pins to a trip.
- Photos display properly after being added in `PhotoScrollView`.
- Styling is appropriate.
