//
//  UserModel.swift
//  Zesto
//
//  Created by Saisrivathsan Manikandan on 4/9/25.
//

import Foundation
import SwiftUICore
enum AccountType: String, Codable {
    case user
    case guest
}

struct UserModel: Identifiable {
    var type: AccountType = .user
    var id: String
    var email: String
    var firstName: String
    var lastName: String
    var username: String
    var displayName: String?
    var dateOfBirth: Date?
    var dietaryPreferences: [String]
    var createdAt: Date
    var profileImageURL: URL?
    var profileImage: Image?
}

// user dietary options
let dietaryOptions = [
    "Vegetarian", "Vegan", "Gluten-Free", "Dairy-Free",
    "Nut Allergy", "Halal", "Kosher", "Peanut Allergy",
    "Lactose Intolerant", "Shellfish Allergy"
]

let lifestyleOptions = [
    "Vegetarian",
    "Vegan",
    "Pescatarian",
    "Paleo",
    "Keto",
    "Low-Carb",
    "Raw Food",
    "Whole30",
    "Flexitarian"
]

let healthRestrictions = [
    "Gluten-Free",
    "Dairy-Free",
    "Lactose Intolerant",
    "Low FODMAP",
    "Low Sodium",
    "Low Sugar",
    "No Added Sugar",
    "Diabetic-Friendly",
    "Cholesterol-Conscious",
    "Heart-Healthy"
]

let allergies = [
    "Nut Allergy",
    "Peanut Allergy",
    "Tree Nut Allergy",
    "Shellfish Allergy",
    "Fish Allergy",
    "Egg Allergy",
    "Soy Allergy",
    "Wheat Allergy",
    "Sesame Allergy",
    "Corn Allergy",
    "Mustard Allergy",
    "Gluten Allergy",
    "Sulfite Sensitivity",
    "Food Dye Allergy"
]

let culturalReligiousRestrictions = [
    "Halal",
    "Kosher",
    "Jain Vegetarian",
    "Hindu Vegetarian",
    "Buddhist Vegetarian",
    "No Beef",
    "No Pork"
]

let otherRestrictions = [
    "Alcohol-Free",
    "Caffeine-Free",
    "MSG-Free"
]
