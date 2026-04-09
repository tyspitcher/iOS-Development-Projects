//
//  FamilyMemberView.swift
//  Meet My Family
//
//  Created by Tyson Pitcher on 3/5/26.
//

import SwiftUI
import Foundation

struct FamilyMemberView: View {
    let member: FamilyMember
    @Binding var isSelected: Bool
    var selectionEmoji: String = "✅"

    var body: some View {
        HStack(spacing: 12) {
            ZStack(alignment: .bottomLeading) {
                Image(member.photoAssetName)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                if isSelected {
                    Text(selectionEmoji)
                        .font(.system(size: 14))
                        .padding(10)
                }
            }

            Text(member.name)
                .font(.custom("Impact", size: 45))
                .foregroundStyle(Color.black.opacity(0.7))

            Spacer()
        }
    }
}

#Preview {
    FamilyMemberView(
        member: FamilyMember(
            name: "Tyson",
            hobbies: "digital art, listening to music, snowboarding, boating",
            foods: "steak, pizza, sushi",
            bandsOrMusicians: "The Beatles, Tame Impala, Outkast, Radiohead, Ray Lamontagne",
            places: "The Bahamas, Puerto Rico, Hawaii",
            photoAssetName: "tyson"
        ),
        isSelected: .constant(true),
    )
    .padding(25)
}
