//
//  SwiftUITextLabApp.swift
//  SwiftUITextLab
//
//  Created by Jane Madsen on 9/10/25.
//

import SwiftUI

@main
struct SwiftUITextLabApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        TabView {
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
            TopFiveFriendsView()
                .tabItem {
                    Label("Friends", systemImage: "person.3.sequence")
                }
            BlogPostView()
                .tabItem {
                    Label("Blog", systemImage: "doc.text")
                }
        }
    }
}

struct ProfileView: View {
    var body: some View {
        ZStack(alignment: .top) {
            VStack {
                Spacer()
                Text("User Name: tyspitcher")
                    .padding(5)
                    .font(.custom("Verdana", size: 18))
                Text("Real Name: Tyson Pitcher")
                    .padding(5)
                    .font(.custom("Verdana", size: 18))
                Text("Home City: Provo, UT")
                    .padding(5)
                    .font(.custom("Verdana", size: 18))
                Text("Bio: ")
                    .padding(5)
                    .font(.custom("Verdana", size: 18))
                Spacer()
            }
            
            Text("Profile Page")
                .font(.custom("Verdana", size: 30))
                .padding(.top, 40)
        }
    }
}

struct TopFiveFriendsView: View {
    var body: some View {
        ZStack(alignment: .top) {
            VStack() {
                Spacer()
                Text("💕 KOTTA 💕")
                    .padding(5)
                    .font(.custom("Party LET", size: 28))
                    .foregroundColor(.pink)
                Text("🏌🏼‍♂️Jeremy 🏌🏼‍♂️")
                    .padding(5)
                    .font(.custom("Copperplate", size: 28))
                    .foregroundColor(.gray)
                Text("🔨 Dad 🔨")
                    .padding(5)
                    .font(.custom("Academy Engraved LET", size: 28))
                    .foregroundColor(.blue)
                Text("😉 Taylor 😉")
                    .padding(5)
                    .font(.custom("Impact", size: 28))
                    .foregroundColor(.red)
                Text("🎶 Teagan 🎶")
                    .padding(5)
                    .font(.custom("Futura", size: 28))
                    .foregroundColor(Color(.cyan))
                Spacer()
            }
            Text("Top Five Friends Page")
                .padding(.top, 40)
                .font(.custom("Verdana", size: 30))
        }
    }
}

struct BlogPostView: View {
    var body: some View {
        VStack() {
            Text("Blog Post Page")
                .padding(.top, 40)
                .font(.custom("Verdana", size: 30))
                .padding(15)
                .padding(.horizontal, 60)
                .background(Color.white.opacity(0.8))
                .zIndex(1) //keeps the title at the top
            ScrollView {
                VStack(alignment: .leading) {
                    Spacer()
                    Text("February 17, 2026")
                        .font(.custom("Verdana", size: 12))
                        .foregroundColor(.blue)
                        .padding(.horizontal, 30)
                    Text("You shouldn't listen to me. I'm nobody. But you know what? I'm not trying to sell you anything. I'm not trying to get power over you. I'm not trying to manipulate you into being a cog. To doing my dirty work for me. And you know what else? Those who would use you that way won't tell you that's what they're doing. \"They\" will claim they are there for you. They're on your side. They want what you want. They will play into your insecurities and the various injustices you've suffered- and we all have suffered injustice. That's life. It's not meant to be fair, but that's a whole other blog post! The point is, we've all been treated unfairly and nobody asks for that, but using victimhood as an identity is a choice. They want you pissed off because your brain turnes off and now they can use you. \n\n Now, if you listen to them long enough, they will convince you that you're suffering comes because of \"the other side\". How the other side is bad and they're good, and if you want to be good, then you sure as hell better be on their side. \n\n So, who are \"they\"? I know what you're thinking, you're thinking that the \"other side\" does this, but not \"my side\". Nope! Both sides do it. The fact is, almost all effective power structures do this. If there's a \"side\" at all then that side does it. Because that's how they keep us stuck. That's how they talk us into doing things that are actually morally repugnant. Hurting each other. Staying divided. And that's precisely how they stay in power. \n\n You know, we actually have more in common than you you think. They know this, and they are terrified that we will discover that truth. In fact, you have more in common with \"the other side\" than you do with \"them\"! Don't believe me? Talk to someone on the other side about their family. Talk to them about their job. What's your favorite food? Who's your best friend? What do you love to do in your free tim? What kind of music do you like? For now, don't bring up the \"conflict du jour\" they want you to fight about. Just opt out of the game, just for one conversation. I'll bet you walk away from that conversation with a little less animosity and a little more compasion for that person that you've been told hates you and all that you stand for. \n\n Go ahead, prove me wrong.")
                        .font(.custom("Verdana", size: 15))
                        .padding(.horizontal, 30)
                    Spacer()
                }
            }
        }
        
    }
}

#Preview("ProfileView") {
    ProfileView()
        .background(.white)
}

#Preview("TopFiveFriendsView") {
    TopFiveFriendsView()
        .background(.white)
}

#Preview("BlogPostView") {
    BlogPostView()
        .background(.white)
}

