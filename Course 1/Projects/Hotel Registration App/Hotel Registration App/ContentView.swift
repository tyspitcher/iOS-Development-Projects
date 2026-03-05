//
//  ContentView.swift
//  Hotel Registration App
//
//  Created by Jane Madsen on 9/26/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        HotelRegistrationScreen()
    }
    
}


struct HotelRegistrationScreen: View {
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var doorCode: String = ""
    @State private var numberOfGuests: String = ""
    @State private var lengthOfStay: Int = 1
    @State private var nonSmoking: Bool = false
    @State private var registrationFeedback: StarRating = .one
    @State private var isEditing: Bool = false
    @State private var submitted: Bool = false
    @State private var sliderValue: Double = 1
    
    let guestNumberOptions = ["1", "2", "3", "4", "5"]
    
    enum StarRating: Int {
        case one = 1, two, three, four, five
    }
    
    var body: some View {
        ZStack {
            Color("highlightColor")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Image("mountainlandLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                    
                    VStack {
                        Text("Mountainland Inn")
                            .font(.custom("Rockwell", size: 27))
                            .foregroundStyle(Color("highlightColor"))
                        
                        Text("\"You're home away from school.\"")
                            .font(.custom("Rockwell", size: 14))
                            .foregroundStyle(Color("highlightColor"))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color("backgroundColor"))
                )
                .padding()
                
                Text("Guest Registration")
                    .font(.custom("Verdana", size: 24))
                    .foregroundStyle(Color("backgroundColor"))
                
                Text("Name")
                    .font(.custom("Verdana", size: 17))
                    .foregroundStyle(Color("backgroundColor"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                
                HStack {
                    TextField("First Name", text: $firstName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 160)
                    .padding()
                    
                    TextField("Last Name", text: $lastName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 160)
                        .padding(.vertical, 8)
                    Spacer()
                }
                
                HStack {
                Text("Total guests:")
                    .font(.custom("Verdana", size: 17))
                    .foregroundStyle(Color("backgroundColor"))
                    .frame(alignment: .leading)
                    .padding()
                
                    Picker(selection: $numberOfGuests) {
                        ForEach(guestNumberOptions, id: \.self) { number in
                            Text(number)
                        }
                    } label: {
                        Text(numberOfGuests.isEmpty ? "Select..." : numberOfGuests)
                            .font(.custom("Verdana", size: 17))
                            .foregroundStyle(Color("backgroundColor"))
                    }
                    .tint(Color("backgroundColor"))
                    .padding()
                    Spacer()
                }
                
                HStack {
                    Text("Length of stay:")
                        .font(.custom("Verdana", size: 17))
                        .foregroundStyle(Color("backgroundColor"))
                        .frame(alignment: .leading)
                        .padding(.horizontal, 11)
                    
                    Text("\(lengthOfStay)")
                        .font(.custom("Verdana", size: 17))
                        .foregroundStyle(Color("backgroundColor"))
                    
                    Stepper("Night(s)",
                            value: $lengthOfStay,
                            in: 1...30,
                            step: 1,
                            onEditingChanged: { editing in
                        isEditing = editing
                    })
                    .font(.custom("Verdana", size: 17))
                    .foregroundStyle(Color("backgroundColor"))
                    .padding()
                    
                    Spacer()
                }
                
                Text("Create a door code")
                    .font(.custom("Verdana", size: 17))
                    .foregroundStyle(Color("backgroundColor"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                
                HStack {
                    SecureField("Code", text: $doorCode)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 120, alignment: .leading)
                        .padding()
                    Spacer()
                }
                
                HStack {
                    Text("Non-smoking")
                    .font(.custom("Verdana", size: 17))
                    .foregroundStyle(Color("backgroundColor"))
                    .frame(alignment: .leading)
                    .padding(.horizontal, 16)
                    
                    Toggle("", isOn: $nonSmoking)
                        .labelsHidden()
                    Spacer()
                }
                
                Button {
                    submitted.toggle()
                } label: {
                    Text("Submit      ")
                        .font(.custom("Rockwell", size: 30))
                        .offset(y: 5)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color("backgroundColor"))
                .foregroundStyle(Color("highlightColor"))
                .padding(50)
                .padding(.top, 8)

                if submitted {
                    VStack(spacing: 8) {
                        Text("Thank you for booking with us!")
                            .font(.custom("Verdana", size: 17))
                            .foregroundStyle(Color("backgroundColor"))
                        
                        Text("How would you rate your experience?")
                            .font(.custom("Verdana", size: 17))
                            .foregroundStyle(Color("backgroundColor"))
                        
                        Slider(value: $sliderValue, in: 1...5, step: 1)
                            .tint(Color("backgroundColor"))
                            .onChange(of: sliderValue) {
                                let intVal = Int(sliderValue.rounded())
                                registrationFeedback = StarRating(rawValue: intVal) ?? .one
                            }
                        
                        Text("\(registrationFeedback.rawValue)/5 " + String(repeating: "⭐️", count: registrationFeedback.rawValue))
                            .font(.custom("Verdana", size: 16))
                            .foregroundStyle(Color("backgroundColor"))
                    }
                    .onAppear { sliderValue = Double(registrationFeedback.rawValue) }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
                
                Spacer()
            }
        }
    }
}

#Preview {
    ContentView()
}

                    
                    
