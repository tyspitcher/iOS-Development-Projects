//
//  hints.swift
//  Hotel Registration App
//
//  Created by Tyson Pitcher on 2/25/26.
//Instructions:
//You are creating a registration app for a hotel, the Mountainland Inn. A starter project can be found in iOS Development/1 - Swift Fundamentals/Assignments/UI Elements and Controls Lab. Follow the instructions to create a screen where the customer can input their registration data.
//
// ****** DONE ******* In HotelRegistrationScreen, add a header to the top of the screen. It should include the hotel’s logo and a text label with its name; you can find the image in the assets folder. Make sure that the logo is appropriately sized.
//
//The assets folder also includes a few Color Sets with the hotel’s brand colors.
// ***** DONE ****** Place backgroundColor behind your view (you may wish to use a ZStack in ContentView to simplify doing this) and
// ***** DONE ****** place a RoundedRectangle with highlightColor behind the logo and hotel name stack;
// ***** DONE ****** make the hotel’s name be the same color as the background.
// ***** DONE ***** Make the rest of the text in your app all colored with the textColor color set and the company’s preferred fonts, Verdana and Rockwell.
//
// ***** DONE ***** Add @State properties for the following data to be collected from the customer: firstName, lastName, doorCode (a passcode for the hotel’s door number pads), numberOfGuests, lengthOfStay, nonSmoking, and registrationFeedback (which will hold a star rating from 1-5). Choose appropriate types for each field.
//
// Implement each UI Element one at a time: TextFields for the names, SecureField for the door code, a picker for numberOfGuests, a stepper for lengthOfStay, and a toggle for nonSmoking.
//
//Add a Button labelled “Submit.” Once pressed, it should toggle a boolean value called submitted.
//
//Add an if statement to the bottom of the view. If submitted == true, display a text label that says “Thank you for booking with us! How would you rate your experience?” Below the text, show a slider that updates registrationFeedback, with a Text label underneath that shows the rating they have selected (something like “1/5 ⭐️s”)
//
//
