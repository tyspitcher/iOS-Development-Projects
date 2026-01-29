/*:
## Exercise - Methods
 
 A `Book` struct has been created for you below. Add an instance method on `Book` called `description` that will print out facts about the book. Then create an instance of `Book` and call this method on that instance.
 */
struct Book {
    var title: String
    var author: String
    var pages: Int
    var price: Double
    
    func description() {
        print("The book \"\(title)\" by \(author) is \(pages) pages long, and can be purchased for $\(price).")
    }
}
var favoriteBook = Book(title: "The Lord of the Rings", author: "J. R. R. Tolkien", pages: 1_077, price: 14.99)
favoriteBook.description()
//:  A `Post` struct has been created for you below, representing a generic social media post. Add a mutating method on `Post` called `like` that will increment `likes` by one. Then create an instance of `Post` and call `like()` on it. Print out the `likes` property before and after calling the method to see whether or not the value was incremented.
struct Post {
    var message: String
    var likes: Int
    var numberOfComments: Int
    
    mutating func like() {
        likes += 1
        
    }
}
var post = Post(message: "I'm going to tell you what a mentor once told me: he said ham and cheese are the best kind of sandwiches. Hit that like button if you agree!", likes: 1_043_233, numberOfComments: 3_223)
post.like()
print(post.likes)
/*:
[Previous](@previous)  |  page 5 of 10  |  [Next: App Exercise - Workout Functions](@next)
 */
