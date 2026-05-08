
Day 1:
Basic Entry Management

Learning Objectives

Set up SwiftData in a new project
Create and use a SwiftData model
Implement basic CRUD operations
Understand @Query and modelContext

Step 1: Project Setup
✅-Create a new iOS SwiftUI app called "SwiftDataJournal"
✅-Important: Check the "Use SwiftData" box
✅-This automatically sets up the SwiftData container and imports for you

Step 2: Create Entry Model
✅-Create Entry.swift:
✅-Use @Model class (not struct)
✅-Include properties: id, title, body, createdAt, updatedAt

Step 3: Build Entries List View
✅-Replace ContentView to show your entries:
✅-Use @Query to fetch entries automatically
✅-Display entries in a List with title and relative date
✅-Add a plus button in the toolbar for creating new entries
✅-Implement entry deletion with onDelete (use SwiftDataTodoList as a reference)

Step 4: Add/Edit Entry View
✅-Create a new Swift file called AddEditEntryView for entry creation and editing:
✅-Use TextField for title and TextEditor to input the journal entry message
✅-Handle both create and edit modes in same view
✅-Remember: Save your modelContext after changes!

Step 5: Navigation and Polish
✅-Present the AddEditEntryView when the user hits the plus button
✅-Set up sheet presentation for add/edit
✅-Remember to save the new entry to the modelContext and save the context
✅-Test that data persists after app restart

Day 1 Checkpoint
✅-You should have a working app that can create, edit, delete, and persist journal entries.
-Test thoroughly before moving to Day 2.
                                                                    
----------------------------------------------------
                                                                    
Day 2:
Adding Journals and Relationships

Learning Objectives

Understand SwiftData relationships
Implement one-to-many data patterns
Build hierarchical navigation
Brief: Understanding Relationships

SwiftData relationships work differently than simple arrays:

Use @Relationship annotation to define connections
Specify deleteRule (cascade means deleting parent deletes children)
Use inverse relationships to maintain data integrity
Both sides of relationship need to be defined

Step 1: Create Journal Model
✅-Create Journal.swift:
✅-Basic properties like Entry but add entries relationship
✅-Look up @Relationship(deleteRule: .cascade, inverse: \Entry.journal)

Step 2: Update Entry Model
✅-Modify your Entry model:
✅-Add optional journal property. This creates the inverse side of the relationship. @Relationship is only on one side of the relationship. Adding to both results in an compile error
✅-Update initializer to accept journal parameter

Step 3: Build Journals List
✅-Create or modify ContentView for journals:
✅-Use @Query for journals
✅-Show journal title and entry count
✅-Add NavigationLink to individual journal views
✅-Implement journal creation and deletion

Step 4: Entries View for Specific Journal
-Modify EntriesView to use the relationship
-A journal has a relationship to its entries
-Let's use that in the EntriesView instead using a @Query
-When you save an entry, make sure to save the entry.journal as the current journal. That's where the relationship is established.
-Update journal's updatedAt timestamp when entries change

Step 5: Update Navigation Flow
-Connect everything together:
-Journals list → Select journal → Entries list → Entry detail
-Ensure new entries are properly associated with their journal
-Test the full navigation flow

*** Critical Reminder: Saving Context ***

-SwiftData doesn't automatically save changes. After any create, update, or delete operation:

func save() {
    try? modelContext.save()
}
-Call this after all CRUD operations!

Day 2 Checkpoint
-Test your complete app:
-Create multiple journals
-Add entries to different journals
-Edit and delete both journals and entries
-Force quit and restart - verify all data persists
-Check that deleting a journal removes its entries

Key Takeaways
-Start simple (single model) before adding complexity
-Relationships require setup on both model sides
-Always save your modelContext after changes
-SwiftData handles most persistence automatically once configured
-@Query automatically updates your UI when data changes
