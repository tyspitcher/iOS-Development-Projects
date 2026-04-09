
# Saving Data Lab Requirements

Complete the EmojiDictionary lab from the Saving Data chapter of your textbook. This lab was built for UIKit and assumes you have already built the project; instead, we have a starter for you provided in this repo. `EmojiTableViewController` becomes `EmojiListView`, `viewDidLoad()` becomes `.onAppear()`; all other instructions should remain applicable.

Lab—Remember Your Emojis 
Objective
The objective of this lab is to use the Codable protocol, the FileManager, and methods on Data to persist information between app launches. Start with the EmojiDictionary project that you developed in earlier table view lessons. Take a few minutes to refamiliarize yourself with the code. If you run the app, you will see that any additions and changes you make to the default list of emoji are lost when the app is restarted. In this lab, you’ll add persistence to your Emoji objects.
Step 1
Implement Saving on Emoji
✅To persist your app’s information across app launches, you need to be able to write its information to a file on disk. Start by ✅making your Emoji struct adopt the Codable protocol in its declaration.
Remember that you can implement saving and loading as static methods on the model. ✅Add the static method signature for a saveToFile(emojis:) function in the Emoji class. It should take an array of Emoji objects as a parameter. Now ✅add a static loadFromFile() method. It shouldn’t take any parameters, but should return an array of Emoji objects.
In each of these methods, you’ll use either a ✅PropertyListEncoder to encode your Emoji object or a ✅PropertyListDecoder to decode it. But to write data to a file, you need to have a file path. ✅Add a static property archiveURL to your Emoji class that returns the file path for Documents/emojis.plist. If you need a refresher on how to do this, go back and read this lesson’s section on sandboxing.
Now that you have a path for saving your Emoji object, ✅fill in the method bodies of saveToFile(emojis:) and ✅loadFromFile(), using Emoji.archiveURL as the file path. Your saveToFile(emojis:) method should save the supplied emojis array by encoding it and then writing it to Emoji.archiveURL. Your loadFromFile() method should read the data from the file, decode it as an [Emoji] array, and return the array.
Create a static sampleEmojis method that returns a predefined [Emoji] collection. You can use the list assigned to emojis in EmojiListView as your list of items
Step 2
Save and Load When Appropriate
• Update emojis to be initialized to an empty collection rather than a large sample collection. When the .onAppear() method is called, you should check the Documents directory for any previously saved Emoji objects using loadFromFile(). If they’re found, assign them to emojis. If not, assign emojis to Emoji.sampleEmojis.
• Take a moment to think about when it might be appropriate to save your Emoji objects.
• In this case, the central spot for your data is the emojis array on the EmojiListView— which means it would be appropriate to call saveToFile(emojis:) whenever the emojis property is changed.
• Next, think about when it might be appropriate to load your archived Emoji objects. Again, in this simple case, there’s really only one point where the archived data will need to be unarchived—when the first view loads. You should already be calling this method in the first view controller’s .onAppear().
• By now, your emoji data should be properly saving and loading. Run your app. Try adding a new emoji and tapping the Save button. Then close the app, reopen it, and observe whether the emoji persists in the table view. Repeat this process for editing an already existing emoji.
Congratulations! Persisting data isn’t an easy thing to learn, but it’s a concept you’ll probably use in every app you build. Be sure to save this new version of your app to your project folder.
