//
//  Untitled.swift
//  iTunesSearch
//
//  Created by Tyson Pitcher on 4/16/26.
//
# Concurrency Lab Requirements - Due Nov 17, 2025

## iTunes Search (Part 3)

### Objective
✅The objective of this lab is to integrate your iTunes Search network requests into an actual app and apply the lessons you’ve learned about concurrency to the project. You’ll create an app that will allow the user to search for different media types and view the results in a table view. To improve the performance of the table view, you’ll also learn how to update the size of the URL cache to temporarily save images.

✅In the iOS Development Repo, open the starter project called “Concurrency (iTunes Search Part 3).” The app includes an initial view with a list view for listing search results, a search bar for entering a query, and a segmented picker for narrowing the search results to a particular media type.

✅The `StoreItemListViewModel` class has placeholder properties and functions that handle the search bar and segmented picker and display a list of items in the table view. Before continuing with the following steps, take a moment to review the project’s code to understand how the app is set up.

### Step 1 - Import Your Playground Code
✅- Open the “iTunes Search” playground you created in the previous two lessons.
✅- Create a **`StoreItem.swift`** file and copy your `StoreItem` structure definition into the file. Also copy your intermediary `SearchResponse` struct into this file, outside the declaration of `StoreItem`.
✅- Create a **`StoreItemController.swift`** file and define a new `StoreItemController` class. Copy your `fetchItems(matching:)` function into the controller.

### Step 2 - Add the Request to the View
Remember that the `StoreItemList` has already implemented the code for the segmented picker and the search bar and for supplying data to the list. But right now, the list is set up to use an array of String instances. ✅You’ll update the view model to use the `StoreItemController` to fetch items based on the media type selected in the segmented picker and the query in the search bar. Once the items are returned, you’ll put them in the items array and the view will redraw to display them.

When the user enters text in the search bar, the keyboard will display "search" where the return key normally is thanks to the `.submitLabel` modifier. What happens when they press that button? If you look above that modifier, there is a closure provided to the text field's `onCommit` property. When the user taps the Search button, this closure will be triggered. In the closure, call the view model's `fetchMatchingItems()` function.

Now, you’ll code the `fetchMatchingItems()` function to set up a query dictionary and make the network request. Here’s how to go about it:

- Add a new `StoreItemController` property to the list view model. You’ll use this instance to run the network request to fetch the matching `StoreItem` objects.
- Update the `items` array to be the `[StoreItem]` type. This will cause an error in the list view because `StoreItem` must conform to `Hashable`; add that conformance.
- In the `ItemCellView` struct, replace the name and artist property and instead use a `StoreItem` to provide those values. We will update the image to work properly later. Update the initialization of `ItemCellView` in the list view to match the new properties.
- In the `fetchMatchingItems()` function, within the if `!searchTerm.isEmpty` braces, set up a query dictionary, setting the `"term"` and `"media"` keys to their respective values. You might also want to use the `"limit"` key to limit the number of results or the `"lang": "en_us"` key-value pair to limit results to items in U.S. English.
- After creating your query, call the `fetchItems(matching:)` method on the `StoreItemController` instance, passing the query dictionary in a do/catch statement within a `Task`. In the case for success, set the returned `[StoreItem]` as the `self.items` property on the view controller. In the case for failure, print the associated `Error` to the console.

### Step 3 - Review Your Progress
At this stage, when the user types text into the search bar and taps the Search button, your app should trigger a network request and return an array of `StoreItem` objects. When your table view is redrawn, it should display the results.
- Run the app in Simulator to verify that it works as expected. If it doesn’t, try to figure out why. Use breakpoints and the debugging console to find out whether the network request was executed and whether the completion handler is getting called.

### Step 4 - Display Images in the Cells
You’ll need to set the `ItemCellView`'s name, artist, and artwork image. The name and artist can be easily loaded from the `StoreItem` property. But in this case, you don’t have the image. You only have an image URL. So you’ll need to fetch the image in order to display it.

Fortunately, SwiftUI makes this fairly straightforward thanks to the `AsyncImage` type. In the body of `ItemCellView`, first add an if-statement to check that we have an `artworkURL` value. While technically `AsyncImage` can handle a nil or missing address, we want to control what happens in those cases ourselves.

If the image address is empty (or possibly nil, depending on how you set up `StoreItem`) because it hasn't loaded yet or there is no artwork, the current `Image(systemName: "photo")` will be our fallback, so put it in the `else` clause of your if-statement.

Now that we're sure we have an address, we can simply pass that to `AsyncImage(url:)`. Add that initializer to the braces where your value is unwrapped, passing in your `artworkURL` value. The UI element will helpfully handle the asynchronous concerns itself.

### Step 5 - Add Previews
Often times, after searching for a piece of music we will want to hear or see a preview of it. The API provides a `previewUrl` key with music results that awill allow you to access a 30 second preview file.
First, revise `StoreItem` to decode and store the `previewUrl` key when possible. Since this value is only present on song request, make sure the property is optional and uses `.decodeIfPresent` or `try?` so that the decoding process does not fail if it is absent.

In `ItemCellView`, a commented-out button has been provided to you that only displays if the store item's previewUrl value is not equal to nil. Uncomment the button.

In the button's closure, we will want to fetch the media file from the provided URL. But before we can do that, we need to consider what happens if multiple play buttons are pressed. The user will expect that starting another preview will stop the current one, and if we start downloading another preview, we should cancel the one currently downloading.

To make this possible, add a property to `ItemCellView` of type `() -> Void` called `onPlayButtonPressed`. Then, in `StoreItemListView`, add a trailing closure to satisify the new requirements for `ItemCellView`'s initializer. Now our logic for pressing multiple play buttons can be handled in `StoreItemListView`, which can manage which one is playing and start and stop different previews as needed.

To download the preview, we will need to run a Task. As mentioned, it's a good idea to cancel this task when it's no longer needed. In the `StoreItemListViewModel`, add the following property:

```swift
var previewTask: Task<Void, Never>? = nil
```

Now, when the play button is pressed, we will start up a Task to retrieve the media file. Since we're storing it in the view model, we'll have access to cancel it later the next time a button is pressed. Create a new function in the viewModel called `fetchPreview(item:)` and place the following code inside:

```swift
    if let previewTask {
        previewTask.cancel()
    }

    previewTask = Task {
        // Code to fetch the preview data using the URL
                            
        // Once the task is complete, return the stored task value to nil
        previewTask = nil
    }
}
```

Call this function in the trailing closure for `ItemCellView` in the body of `StoreItemListView`.

Now we need to actually download the audio file. Getting the data for the file is like any other network retrieval: using `URLSession.shared.data(from:)`, we can retrieve the raw binary. Add a function to `StoreItemController` called `fetchPreview(from url: URL)` to do this, returning `Data` in this case instead of decoding it directly. Other than not decoding it, this function should follow the same pattern of network data retrieval you have practiced so far, so you can refer back to your `fetchItems(matching:)` function to review how to accomplish this.

Now, unwrap `item.previewUrl` and call your controller's new `fetchPreview` function in the `Task` you created above, before setting `previewTask` to nil. Make sure to wrap the function call in a do/catch statement as well.

In order to make this data actually playable requires a few extra steps that go beyond the scope of this lesson, so at this point you can call this lab complete if you so choose. Congrats! If you would like to actually play the previews, continue with the Black Diamond steps below.

## Black Diamond

### Step 6 - AVFoundation

Apple offers a framework called AVFoundation that supports playback of audio and video files. Its most relevant feature to us today is the AVPlayer. In order to play the media file, we will first need to add an AVPlayer to our view model. Start by importing AVFoundation, then in your view model, add:

```swift
var previewPlayer: AVPlayer?
```

By storing this as a property we are able to start and stop playback at any time.

In order to play a file, AVPlayback needs it to be stored locally on disk. Using FileManager, we will store the data we received from the preview URL in the temporary directory. In the `fetchPreview` function after retrieving the data, add the following:

```swift
let tempDirectory = FileManager.default.temporaryDirectory
let tempFileUrl = tempDirectory.appendingPathComponent(previewUrl.lastPathComponent) // Naming the file the same as what was provided by the API

try data.write(to: tempFileUrl)
```

Now that we have the audio file stored to the disk, we are ready to play it. Create a new AVPlayer, using the url of the data we just stored to initialize it:

```swift
previewPlayer = AVPlayer(url: tempFileUrl)
```

And finally, hit "play" on the player:

```swift
previewPlayer?.play()
```

You should now be able to play the audio file retrieved from the source. If the user presses another play button, we should stop any currently playing audio, so above the code where you assign a new `AVPlayer` call `viewModel.previewPlayer?.pause()` and then set the player to nil before beginning a new playback task.

### Step 7 - Caching URL Results

Caching the results of your URL requests reduces the number of requests that need to be made to the server and improves your app’s user experience by making certain data from the server more readily available—even when the user is offline, experiencing a slow network connection, or requesting a large piece of data that would typically take time to download, such as an image or video. The shared URLSession (URLSession.shared) will by default use URLCache.shared, which is preconfigured—but sometimes its a good idea to increase its capacity.

If you cache audio files in this app, they will load significantly faster after the first time they’ve been downloaded from the server, because they won’t need to be downloaded a second time. To increase the cache capacity, all you need to do is put the following code in the `init` function of the top level of your App, the `iTunesSearchApp` file.

```swift
URLCache.shared.memoryCapacity = 25_000_000URLCache.shared.diskCapacity = 50_000_000
```

This adjusts the default system-provided cache instance so that memoryCapacity and diskCapacity are 25 megabytes and 50 megabytes, respectively. Depending on your app and its data, you can decide what values provide the best user experience.

Congratulations! You’ve made a more complex app that fetches a list of iTunes store items, loads their respective images, and displays them in a table view. Be sure to save it to your project folder for future reference.
