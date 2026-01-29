import UIKit

// this extension
extension TimeInterval {
      static func minutes(_ m: Int, _ s: Int = 0) -> TimeInterval { TimeInterval(m * 60 + s) }
  }

struct Song {
    var artist: String
    var album: String
    var title: String
    var duration : Double
}

class Playlist {
    var name: String
    var author: String
    var songs: [Song]
    var currentlyPlaying: Song?
    
// currentIndex helps keep track of where we're at
// in the playlist for the playback navigation.
// The initial value -1 means it's not playing yet
// because it is 0 indexed, so if I put 0 that would
// mean a song is playing.
    var currentIndex: Int = -1
    
    init(name: String, author: String, songs: [Song], currentlyPlaying: Song? = nil) {
        self.name = name
        self.author = author
        self.songs = songs
        self.currentlyPlaying = currentlyPlaying
    }
    
// *** Core Mutation ***
    
    func add(_ song: Song) {
        songs.append(song)
    }
// using optional Int in case there isn't a number at that index
// using a ! to force unwrap the index object
    func remove(at index: Int?) {
        songs.remove(at: index!)
    }

    func clear() {
        songs.removeAll()
    }
    
// *** Querying / Reading ***
    
    var count: Int {
        songs.count
    }
    func showAllSongs() -> [Song] {
        songs
    }
    func currentSong() -> Song? {
        if currentIndex >= 0 && currentIndex < songs.count {
            return songs[currentIndex]
        } else {
            return nil
        }
    }
    
    
// *** Playback Navigation ***
    
    func playHere(at index: Int) -> Song {
        let song = songs[index]
        currentIndex = index
        currentlyPlaying = song
        return song
    }
    
    func playNext() -> Song {
        currentIndex += 1
        let song = songs[currentIndex]
        currentlyPlaying = song
        return song
    }
    
    func playPrevious() -> Song {
        currentIndex -= 1
        let song = songs[currentIndex]
        currentlyPlaying = song
        return song
    }
    
    func shuffle() {
        songs.shuffle()
    }
    
    func totalDuration() {
        
    }
}
// *** Playlists ***

var beatlesDeepCuts = Playlist(name: "Beatles Deep Cuts", author: "Tyson", songs: [])
var tameImpalaFavs = Playlist(name: "Tame Impala Favs", author: "Tyson", songs: [])
var pastPresent = Playlist(name: "Past & Present Mix", author: "Tyson", songs: [])

// *** Music Library ***

let thatsWhatIWant = Song(
    artist: "The Beatles",
    album: "With The Beatles",
    title: "Money (That's What I Want",
    duration: .minutes(2, 47)
)

let anyTimeAtAll = Song(
    artist: "The Beatles",
    album: "A Hard Day's Night",
    title: "Any Time at All",
    duration: .minutes(2, 12)
)

let babysInBlack = Song(
    artist: "The Beatles",
    album: "Beatles For Sale",
    title: "Baby's In Black",
    duration: .minutes(2, 5)
)

let hideYourLoveAway = Song(
    artist: "The Beatles",
    album: "Help!",
    title: "You've Got to Hide Your Love Away",
    duration: .minutes(2, 9)
)

let michelle = Song(
    artist: "The Beatles",
    album: "Rubber Soul",
    title: "Michelle",
    duration: .minutes(2, 42)
)

let forNoOne = Song(
    artist: "The Beatles",
    album: "Revolver",
    title: "For No One",
    duration: .minutes(2, 1)
)

let aDayInTheLife = Song(
    artist: "The Beatles",
    album: "Sgt. Pepper's Lonely Hearts Club Band",
    title: "A Day In The Life",
    duration: .minutes(5, 37)
)

let helloGoodbye = Song(
    artist: "The Beatles",
    album: "Magical Mystery Tour",
    title: "Hello, Goodbye",
    duration: .minutes(3, 27)
)

let marthaMyDear = Song(
    artist: "The Beatles",
    album: "White Album",
    title: "Martha My Dear",
    duration: .minutes(2, 28)
)

let yellowSubmarine = Song(
    artist: "The Beatles",
    album: "Yellow Submarine",
    title: "Yellow Submarine",
    duration: .minutes(2, 38)
)

let sheCameIn = Song(
    artist: "The Beatles",
    album: "Abby Road",
    title: "She Came In Through the Bathroom Window",
    duration: .minutes(1, 57)
)

let iveGotAFeeling = Song(
    artist: "The Beatles",
    album: "Let It Be",
    title: "I've Got a Feeling",
    duration: .minutes(3, 38)
)

let desireBe = Song(
    artist: "Tame Impala",
    album: "Tame Impala - EP",
    title: "Desire Be Desire Go",
    duration: .minutes(4, 26)
)

let theSun = Song(
    artist: "Tame Impala",
    album: "Tame Impala - EP",
    title: "The Sun",
    duration: .minutes(3, 47)
)

let sundownSyndrome = Song(
    artist: "Tame Impala",
    album: "Syndown Syndrome / Remember Me - Single",
    title: "Sundown Syndrome",
    duration: .minutes(4, 18)
)

let solitudeIsBliss = Song(
    artist: "Tame Impala",
    album: "InnerSpeaker",
    title: "Solitude Is Bliss",
    duration: .minutes(3, 55)
)

let elephant = Song(
    artist: "Tame Impala",
    album: "Lonerism",
    title: "Elephant",
    duration: .minutes(3, 31)
)

let loveParanoia = Song(
    artist: "Tame Impala",
    album: "Currents",
    title: "Love/Paranoia",
    duration: .minutes(3, 6)
)

let patience = Song(
    artist: "Tame Impala",
    album: "Patience - Single",
    title: "Patience",
    duration: .minutes(4, 52)
)

let breatheDeeper = Song(
    artist: "Tame Impala",
    album: "The Slow Rush",
    title: "Breathe Deeper",
    duration: .minutes(6, 13)
)

let guiltyConscience = Song(
    artist: "Tame Impala",
    album: "Guilty Conscience (Tame Impala Remix) - Single",
    title: "Guilty Conscience (Tame Impala Remix)",
    duration: .minutes(4, 5)
)

let neverender = Song(
    artist: "Justice & Tame Impala",
    album: "Hyperdrama",
    title: "Neverender",
    duration: .minutes(4, 52)
)

let endOfSummer = Song(
    artist: "Tame Impala",
    album: "Deadbeat",
    title: "End Of Summer",
    duration: .minutes(3, 12)
)

// adding songs to playlists and testing

beatlesDeepCuts.add(hideYourLoveAway)
beatlesDeepCuts.add(sheCameIn)
beatlesDeepCuts.add(marthaMyDear)
beatlesDeepCuts.clear()
beatlesDeepCuts.add(iveGotAFeeling)
beatlesDeepCuts.add(forNoOne)
print(beatlesDeepCuts.count)
// loop prints just the titles in playlist
for song in beatlesDeepCuts.songs {
    print(song.title)
}
print()
print(beatlesDeepCuts.showAllSongs())
print()

tameImpalaFavs.add(breatheDeeper)
tameImpalaFavs.add(elephant)
tameImpalaFavs.add(endOfSummer)
tameImpalaFavs.add(loveParanoia)
tameImpalaFavs.add(neverender)
// loop that prints out a string with song info
// in playlist
print(tameImpalaFavs.count)
for song in tameImpalaFavs.songs {
    print("\(song.title) by \(song.artist) on \"\(song.album)\"")
}
print()

tameImpalaFavs.remove(at: 2)

print(tameImpalaFavs.count)
for song in tameImpalaFavs.songs {
    print("\(song.title) by \(song.artist) on \"\(song.album)\"")
}
print()

pastPresent.add(aDayInTheLife)
pastPresent.add(patience)
pastPresent.add(yellowSubmarine)
pastPresent.add(helloGoodbye)
pastPresent.add(hideYourLoveAway)
pastPresent.add(solitudeIsBliss)
pastPresent.add(theSun)
for song in pastPresent.songs {
    print("\(song.title)")
}
print()
pastPresent.shuffle()
for song in pastPresent.songs {
    print("\(song.title)")
}
print()
print(pastPresent.currentlyPlaying)
pastPresent.playNext()
print()
print(pastPresent.currentlyPlaying)
pastPresent.playNext()
print()
print(pastPresent.currentlyPlaying)

//fatalError("Invalid Input")

