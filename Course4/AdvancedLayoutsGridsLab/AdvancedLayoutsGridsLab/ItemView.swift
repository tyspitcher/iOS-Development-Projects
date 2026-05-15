//
//  ItemView.swift
//  AdvancedLayoutsGridsLab
//
//  Created by Tyson Pitcher on 5/14/26.
//

import Foundation
import SwiftUI

struct ItemView: View {
    var item: Clothing
    var width: CGFloat
    var height: CGFloat
    var body: some View {
        VStack {
            
            Text(item.name)
                .font(.body.bold())
            Text(item.formattedPrice)
            Text(item.color)
                .font(.subheadline)
            Text(item.size)
                .font(.subheadline)
        }
        .frame(width: width - 35, height: height - 35)
        .background {
            Color.random()
                .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
}

#Preview {
    ItemView(
        item: Clothing(name: "Fedora", price: 29.99, size: "M", color: "Brown"),
        width: 200, height: 200
    )
}
