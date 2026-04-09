//
//  FamilyMemberInfo.swift
//  Meet My Family
//
//  Created by Tyson Pitcher on 3/5/26.
//
import Foundation
import SwiftUI

struct FamilyMember: Identifiable {
    var id = UUID()
    var name: String
    var hobbies: String
    var foods: String
    var bandsOrMusicians: String
    var places: String
    var photoAssetName: String
}

let familyMembers: [FamilyMember] = [
    FamilyMember(name: "Tyson", hobbies: "digital art, listening to music, snowboarding, boating", foods: "steak, pizza, sushi", bandsOrMusicians: "The Beatles, Tame Impala, Outkast, Radiohead, Ray Lamontagne", places: "The Bahamas, Puerto Rico, Hawaii", photoAssetName: "tyson"),
    FamilyMember(name: "Steph", hobbies: "reading, volleyball, travel", foods: "steak, fruits and veggies", bandsOrMusicians: "Ray Lamontagne", places: "Hawaii with my family", photoAssetName: "steph"),
    FamilyMember(name: "Carson", hobbies: "video games, snowboarding, surfing, skateboarding", foods: "steak, wings, ramen chimichangas", bandsOrMusicians: "The Beatles", places: "Hawaii", photoAssetName: "carson"),
    FamilyMember(name: "Josie", hobbies: "watercolor, hiking, taking care of plants", foods: "anything Thai or Mediterranean", bandsOrMusicians: "Mac Miller, Erykah Badu, Puzzle", places: "Mexico", photoAssetName: "josie"),
    FamilyMember(name: "Marley", hobbies: "Shopping", foods: "Sushi or Pasta", bandsOrMusicians: "sombr", places: "Puerto Rico", photoAssetName: "marley"),
    FamilyMember(name: "Kallie", hobbies: "hanging out with friends, listening to music, tanning", foods: "Carrabba's pizza", bandsOrMusicians: "Justin Beiber, Bruno Mars, Harry Styles", places: "Hawaii", photoAssetName: "kallie"),
    FamilyMember(name: "Quincey", hobbies: "dance, playing with her cat, watching YouTube shorts, hanging out with friends", foods: "Papa Murphy's white sauce and pepperoni pizza, sushi, coconut rice, Velveeta shells and cheese", bandsOrMusicians: "Tate McRae, Billie Eilish", places: "Hawaii, Mexico, Disneyland, California", photoAssetName: "quincey")
]

