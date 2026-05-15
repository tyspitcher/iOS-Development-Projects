//
//  ContentView.swift
//  TransitionLab
//
//  Created by Tyson Pitcher on 5/6/26.
//

import SwiftUI

enum FaceParts {
    case eye1, eye2, nose, mustache
    
    var image: Image {
        switch self {
        case .eye1, .eye2:
            return Image(systemName: "eye.half.closed")
        case .nose:
            return Image(systemName: "nose")
        case .mustache:
            return Image(systemName: "mustache.fill")
        }
    }
    
    var entryEdge: Edge {
        switch self {
        case .eye1: return .leading
        case .eye2: return .top
        case .nose: return .trailing
        case .mustache: return .bottom
        }
    }
}

struct ContentView: View {
    @Namespace var animation
    @State var stage = 0
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack {
                HStack {
                    if stage >= 1 {
                        facePart(.eye1)
                    }
                    
                    if stage >= 2 {
                        facePart(.eye2)
                    }
                }
                
                if stage >= 3 {
                    facePart(.nose)
                }
                
                if stage >= 4 {
                    facePart(.mustache)
                }
            }
            .frame(width: 350, height: 300)
            
            Spacer()
            
            Button("Build Face") {
                animateFace()
            }
            .padding()
            .font(.title.bold())
            .frame(maxWidth: .infinity)
            .overlay(RoundedRectangle(cornerRadius: 10)
                .stroke(lineWidth: 3)
            )
            .foregroundStyle(Color.blue)
        }
        .padding()
        .padding()
    }
    
    func facePart(_ part: FaceParts) -> some View {
        part.image
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 80)
            .foregroundStyle(.black)
            .matchedGeometryEffect(id: "\(part)", in: animation)
            .transition(.move(edge: part.entryEdge))
    }
    
    func animateFace() {
        stage = 0
        
        withAnimation {
            stage = 1
        } completion: {
            withAnimation {
                stage = 2
            } completion: {
                withAnimation {
                    stage = 3
                } completion: {
                    withAnimation {
                        stage = 4
                    }
                }
            }
        }
    }
}


#Preview {
    ContentView()
}
