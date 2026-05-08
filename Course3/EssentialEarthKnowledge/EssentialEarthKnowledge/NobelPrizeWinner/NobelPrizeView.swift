//
//  NobelPrizeView.swift
//  EssentialEarthKnowledge
//
//  Created by Tyson Pitcher on 4/23/26.
//

import Foundation
import SwiftUI

struct NobelPrizeView: View {
    @State var viewModel: NobelPrizeViewModel
    var body: some View {
        Text("Nobel Prize Winners")
    }
}
#Preview {
    NobelPrizeView(viewModel: NobelPrizeViewModel())
}
