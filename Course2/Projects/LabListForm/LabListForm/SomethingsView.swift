//
//  ContentView.swift
//  LabListForm
//
//  Created by Tyson Pitcher on 3/2/26.
//

import SwiftUI

struct Songs {
    var title: String
    var album: String
    var duration: String
}

extension Songs {
    static let breatheDeeper = Songs(title: "Breathe Deeper", album: "Currents", duration: "3:39")
    static let theLessIKnow = Songs(title: "The Less I Know the Better", album: "Currents", duration: "6:13")
    static let sundownSyndrome = Songs(title: "Sundown Syndrome", album: "Sundown Syndrome/Remember Me - Single", duration: "5:49")
    static let dracula = Songs(title: "Dracula", album: "Deadbeat", duration: "3:25")
    static let endorsToi = Songs(title: "Endors Toi", album: "Lonerism", duration: "3:07")
    static let lucidity = Songs(title: "Lucidity", album: "Inner Speaker", duration: "4:32")
    static let solitudeIsBliss = Songs(title: "Solitude is Bliss", album: "Inner Speaker", duration: "3:56")
    
    static let allSamples: [Songs] = [
            .breatheDeeper,
            .theLessIKnow,
            .sundownSyndrome,
            .dracula,
            .endorsToi,
            .lucidity,
            
    ]
}

struct ArtistSongView: View {
    let song: Songs
    var body: some View {
        HStack {
            Image(systemName: "music.note")
                .font(.title)
                .padding(.horizontal, 10)
            VStack(alignment: .leading) {
                Text(song.title)
                    .font(.headline)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Text(song.album)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            Spacer()
            Text(song.duration)
                .padding(.horizontal, 10)
            
        }
    }
}



struct SomethingsView: View {
    var body: some View {
        VStack {
            List {
                Section {
                    ForEach(Songs.allSamples, id: \.title) { song in
                        ArtistSongView(song: song)
                    }
                } header: {
                    HStack {
                        Image(systemName: "person")
                            .font(Font.title.bold())
                        Text("Tame Impala")
                            .font(Font.title.bold())
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .listStyle(.automatic)
        }
        .padding()
        .background(LinearGradient(
            colors: [.red, .orange, .yellow, .green],
                startPoint: .top,
                endPoint: .bottom))
    }
}

#Preview {
    SomethingsView()
}
