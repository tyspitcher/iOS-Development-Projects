//
//  SeedData.swift
//  AdvancedLayoutsGridsLab
//
//  Created by Tyson Pitcher on 5/14/26.
//
import Foundation
import SwiftUI

struct Clothing: Hashable {
    let name: String
    let price: Double
    let size: String
    let color: String
    var formattedPrice: String {
        price.formatted(.currency(code: "USD"))
    }
}
extension Clothing {
    // Array of hats
    static let hats: [Clothing] = [
        Clothing(name: "Baseball Cap", price: 19.99, size: "M", color: "Blue"),
        Clothing(name: "Beanie", price: 14.99, size: "One Size", color: "Black"),
        Clothing(name: "Fedora", price: 29.99, size: "L", color: "Brown"),
        Clothing(name: "Sun Hat", price: 24.99, size: "One Size", color: "White"),
        Clothing(name: "Bucket Hat", price: 22.99, size: "One Size", color: "Yellow"),
        Clothing(name: "Cowboy Hat", price: 34.99, size: "L", color: "Tan"),
        Clothing(name: "Snapback", price: 18.99, size: "Adjustable", color: "Black"),
        Clothing(name: "Visor", price: 16.99, size: "Adjustable", color: "Pink"),
        Clothing(name: "Trucker Hat", price: 20.99, size: "Adjustable", color: "Red"),
        Clothing(name: "Beret", price: 27.99, size: "One Size", color: "Black"),
        Clothing(name: "Top Hat", price: 45.99, size: "L", color: "Gray"),
        Clothing(name: "Wide Brim Hat", price: 32.99, size: "One Size", color: "Beige")
    ]
    
    // Array of shirts
    static let shirts: [Clothing] = [
        Clothing(name: "Graphic Tee", price: 15.99, size: "M", color: "Red"),
        Clothing(name: "Polo Shirt", price: 25.99, size: "L", color: "Navy"),
        Clothing(name: "Button-Up", price: 34.99, size: "XL", color: "White"),
        Clothing(name: "Tank Top", price: 12.99, size: "S", color: "Green"),
        Clothing(name: "Flannel Shirt", price: 29.99, size: "M", color: "Plaid"),
        Clothing(name: "Hoodie", price: 39.99, size: "L", color: "Gray"),
        Clothing(name: "Long Sleeve Tee", price: 19.99, size: "M", color: "Black"),
        Clothing(name: "Sweater", price: 45.99, size: "XL", color: "Beige"),
        Clothing(name: "Denim Shirt", price: 36.99, size: "L", color: "Light Blue"),
        Clothing(name: "Henley", price: 22.99, size: "M", color: "Olive"),
        Clothing(name: "V-Neck Tee", price: 14.99, size: "S", color: "Purple"),
        Clothing(name: "Baseball Tee", price: 18.99, size: "M", color: "White/Red"),
        Clothing(name: "Long Sleeve Tee", price: 19.99, size: "M", color: "Black"),
        Clothing(name: "Sweater", price: 45.99, size: "XL", color: "Beige"),
        Clothing(name: "Denim Shirt", price: 36.99, size: "L", color: "Light Blue"),
        Clothing(name: "Henley", price: 22.99, size: "M", color: "Olive"),
        Clothing(name: "V-Neck Tee", price: 14.99, size: "S", color: "Purple"),
        Clothing(name: "Baseball Tee", price: 18.99, size: "M", color: "White/Red"),
        Clothing(name: "Rugby Shirt", price: 32.99, size: "L", color: "Green/Navy"),
        Clothing(name: "Chambray Shirt", price: 41.99, size: "M", color: "Light Blue"),
        Clothing(name: "Linen Shirt", price: 37.99, size: "S", color: "White"),
        Clothing(name: "Tunic Top", price: 23.99, size: "XL", color: "Coral"),
        Clothing(name: "Plaid Western Shirt", price: 34.99, size: "L", color: "Red/Black"),
        Clothing(name: "Thermal Henley", price: 28.99, size: "M", color: "Olive"),
        Clothing(name: "Base Layer Shirt", price: 19.99, size: "S", color: "Gray"),
        Clothing(name: "Performance Tee", price: 24.99, size: "L", color: "Blue"),
        Clothing(name: "Overshirt", price: 42.99, size: "XL", color: "Tan"),
        Clothing(name: "Mock Neck Sweater", price: 47.99, size: "M", color: "Cream"),
        Clothing(name: "Bowling Shirt", price: 26.50, size: "L", color: "Black/White"),
        Clothing(name: "Retro Print Shirt", price: 38.99, size: "M", color: "Multicolor")
    ]
    
    // Array of pants
    static let pants: [Clothing] = [
        Clothing(name: "Jeans", price: 39.99, size: "32", color: "Dark Blue"),
        Clothing(name: "Chinos", price: 49.99, size: "34", color: "Khaki"),
        Clothing(name: "Sweatpants", price: 29.99, size: "L", color: "Gray"),
        Clothing(name: "Shorts", price: 19.99, size: "M", color: "Black"),
        Clothing(name: "Cargo Pants", price: 44.99, size: "36", color: "Olive"),
        Clothing(name: "Dress Pants", price: 59.99, size: "32", color: "Charcoal"),
        Clothing(name: "Joggers", price: 35.99, size: "M", color: "Navy"),
        Clothing(name: "Capri Pants", price: 25.99, size: "S", color: "White"),
        Clothing(name: "Corduroy Pants", price: 49.99, size: "34", color: "Brown"),
        Clothing(name: "Linen Pants", price: 39.99, size: "M", color: "Beige"),
        Clothing(name: "Overalls", price: 59.99, size: "L", color: "Denim"),
        Clothing(name: "Track Pants", price: 29.99, size: "M", color: "Black/White"),
        Clothing(name: "Slim Fit Khakis", price: 52.99, size: "32", color: "Stone"),
        Clothing(name: "Track Shorts", price: 23.99, size: "M", color: "Blue"),
        Clothing(name: "Pleated Trousers", price: 64.99, size: "38", color: "Black"),
        Clothing(name: "Jogger Shorts", price: 27.99, size: "L", color: "Gray"),
        Clothing(name: "Cargo Shorts", price: 34.99, size: "S", color: "Olive"),
        Clothing(name: "Drawstring Pants", price: 29.99, size: "M", color: "Navy"),
        Clothing(name: "Relaxed Jeans", price: 42.99, size: "34", color: "Medium Blue"),
        Clothing(name: "Suit Pants", price: 79.99, size: "32", color: "Charcoal"),
        Clothing(name: "Sweat Shorts", price: 18.99, size: "M", color: "Heather Gray"),
        Clothing(name: "Bermuda Shorts", price: 26.99, size: "L", color: "Beige"),
        Clothing(name: "Straight Leg Pants", price: 38.99, size: "30", color: "Black"),
        Clothing(name: "Painter Pants", price: 43.99, size: "36", color: "White"),
        Clothing(name: "Relaxed Jeans", price: 42.99, size: "34", color: "Medium Blue"),
        Clothing(name: "Suit Pants", price: 79.99, size: "32", color: "Charcoal"),
        Clothing(name: "Sweat Shorts", price: 18.99, size: "M", color: "Heather Gray"),
        Clothing(name: "Bermuda Shorts", price: 26.99, size: "L", color: "Beige"),
        Clothing(name: "Straight Leg Pants", price: 38.99, size: "30", color: "Black"),
        Clothing(name: "Painter Pants", price: 43.99, size: "36", color: "White"),
        Clothing(name: "Tech Joggers", price: 53.99, size: "M", color: "Slate"),
        Clothing(name: "Yoga Pants", price: 44.50, size: "S", color: "Black"),
        Clothing(name: "Ski Pants", price: 119.99, size: "L", color: "Navy"),
        Clothing(name: "Moto Jeans", price: 64.99, size: "32", color: "Charcoal"),
        Clothing(name: "Patchwork Jeans", price: 69.99, size: "34", color: "Blue Multi"),
        Clothing(name: "Paperbag Pants", price: 56.99, size: "M", color: "Olive"),
        Clothing(name: "Cropped Pants", price: 38.99, size: "S", color: "Pink"),
        Clothing(name: "Track Leggings", price: 32.99, size: "XS", color: "Gray/White"),
        Clothing(name: "Work Pants", price: 49.99, size: "34", color: "Tan"),
        Clothing(name: "Stretch Trousers", price: 59.99, size: "38", color: "Navy"),
        Clothing(name: "Painter Overalls", price: 69.99, size: "L", color: "White"),
        Clothing(name: "Wide Leg Pants", price: 48.99, size: "M", color: "Emerald"),
        Clothing(name: "Cargo Joggers", price: 44.99, size: "M", color: "Camo"),
        Clothing(name: "Pleather Pants", price: 79.99, size: "S", color: "Black"),
        Clothing(name: "Skinny Jeans", price: 41.99, size: "30", color: "Light Wash"),
        Clothing(name: "Dress Culottes", price: 54.99, size: "M", color: "Ivory"),
        Clothing(name: "Thermal Leggings", price: 27.99, size: "XS", color: "Burgundy"),
        Clothing(name: "Embroidered Jeans", price: 62.99, size: "32", color: "Indigo"),
        Clothing(name: "Satin Pants", price: 67.99, size: "M", color: "Champagne"),
        Clothing(name: "Cord Joggers", price: 35.99, size: "L", color: "Olive"),
        Clothing(name: "Printed Leggings", price: 24.50, size: "S", color: "Floral"),
        Clothing(name: "Convertible Cargo Pants", price: 77.99, size: "32", color: "Beige"),
        Clothing(name: "Wind Pants", price: 37.99, size: "M", color: "Royal Blue"),
        Clothing(name: "Snowboard Pants", price: 132.00, size: "L", color: "Red/Black"),
        Clothing(name: "Painter Shorts", price: 29.99, size: "M", color: "White"),
        Clothing(name: "Cropped Pants", price: 38.99, size: "8", color: "Blue")
    ]
}

extension Color {
    static func random() -> Color {
        Color.init(red: .random(in: 0.5...1),
                   green: .random(in: 0.5...1),
                   blue: .random(in: 0.5...1)
        )
    }
}
