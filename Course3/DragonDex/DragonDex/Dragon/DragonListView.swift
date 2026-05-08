//
//  DragonListView.swift
//  DragonDex
//
//  Created by Logan Steven Bartell on 12/4/25.
//

import SwiftUI

struct DragonListView: View {
    @Environment(BackgroundSettings.self) var backgroundsettings
    @Environment(HomeRouter.self) var router
    let dragons = Dragon.dragons

    var body: some View {
        ZStack {
            backgroundsettings.backgroundColor
                .ignoresSafeArea()
            ScrollView {
                VStack {
                    ForEach(dragons) { dragon in
                        dragonCardView(dragon: dragon) { dragon in
                            // TODO: User Tapped on this row - navigate to DragonDetailView for `dragon`
                            router.navigateTo(route: .dragonDetail(dragon: dragon))
                        }
                            .padding()
                    }
                }
            }
        }
    }
    private func dragonCardView(dragon: Dragon, didTap: @escaping (Dragon) -> Void) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 40)
                .frame(width: 370, height: 620)
                .foregroundStyle(.gray)
            RoundedRectangle(cornerRadius: 40)
                .frame(width: 350, height: 600)
                .foregroundStyle(.cardBorder)
            VStack {
                Spacer()
                    .frame(height: 90)
                ZStack {
                    Text(dragon.name)
                        .font(.custom("Cochin", size: 40))
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 40)
                                .frame(width: 370)
                                .foregroundStyle(.gray)
                        )
                        .offset(y: -100)
                    HStack {
                        Text(dragon.rating)
                            .font(.custom("Cochin", size: 40))
                            .background(
                                Circle()
                                    .frame(width: 60, height: 60)
                                    .foregroundStyle(.blue)
                            )
                        Spacer()
                            .frame(width: 250)
                        Text(dragon.health)
                            .font(.custom("Cochin", size: 40))
                            .background(
                                Circle()
                                    .frame(width:60, height: 60)
                                    .foregroundStyle(.red)
                            )
                    }
                    .offset(y: -100)
                }
                ZStack {
                    Rectangle()
                        .frame(width: 320, height: 320)
                    Image(dragon.picture)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300)
                    Text("Powers/Abilities: \(dragon.powers.count)")
                        .font(.custom("Cochin", size: 25))
                        .padding()
                        .background(
                            Rectangle()
                                .foregroundStyle(.gray)
                        )
                        .offset(y: 200)
                }
                .offset(y: -80)
                Button {
                    didTap(dragon)
                } label: {
                    Text("Details")
                        .font(.custom("Cochin", size: 30))
                        .foregroundStyle(.black)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 40)
                        )
                }
            }
        }
    }
}

