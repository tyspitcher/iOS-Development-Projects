/*:
## Exercise - Associated Values
 
 Much of error handling is used in conjunction with networking related code, which is prone to failure due to outside circumstances. Provided below is an `Error` conforming enum `CommunicationError` with several cases, some of which have associated values. In the exercises below, you will need to handle each case appropriately. For simplicity's sake, the `sendPacket` function simulates this by generating a random error from the list.
 */

enum CommunicationError: Error {
    case networkServiceUnavailable
    case invalidMessage(String)
    case timedOut(waitTime: Int)
    case cancelledByUser
    case rejectedByServer(reason: String)
    case unknown
}

func sendPacket() throws {
    let randomNumber = Int.random(in: 0..<6)
    
    switch randomNumber {
    case 0:
        throw CommunicationError.networkServiceUnavailable
    case 1:
        throw CommunicationError.invalidMessage("\"outGonigMessage\": \"Hi!\"")
    case 2:
        throw CommunicationError.timedOut(waitTime: 5)
    case 3:
        throw CommunicationError.cancelledByUser
    case 4:
        throw CommunicationError.rejectedByServer(reason: "You're a bot!")
    default:
        throw CommunicationError.unknown
    }
}

/*:
 First, remove the question mark from `try?` so that errors from `sendPacket` will be caught. Then, add a `catch` statement for each error. If the error has an associated value, assign that value to a constant with an appropriate name. The first one has been created for you.
 */
let userMessage: String
let userWaitTime: Int
let serverRejectionReason: String
do {
    try sendPacket()
    print("Packet sent successfully.")
} catch CommunicationError.networkServiceUnavailable {
    print("Network Service is unavailable.")
} catch CommunicationError.invalidMessage(let userMessage) {
    print("Invalid message: \(userMessage).")
} catch CommunicationError.timedOut(waitTime: let userWaitTime) {
    print("Request timed out after \(userWaitTime) seconds.")
} catch CommunicationError.cancelledByUser {
    print("User cancelled the request.")
} catch CommunicationError.rejectedByServer(reason: let serverRejectionReason) {
    print("Rejected by server: \(serverRejectionReason).")
} catch {
    print("Unknown error.")
}


/*:
 In the body of each catch statement, print a message that describes the error in plain English. Make sure that associated values are included in the print statement. For example, the `invalidMessage(let message)` case might print, `"Communication error due to invalid message: \(message)"`
 
 Test out your code by running the playground repeatedly to randomize the error output.
 */

/*:
[Previous](@previous)  |  page 3 of 4  |  [Next: App Exercise - Counting](@next)
 */
