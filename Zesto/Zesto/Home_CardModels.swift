//
//  Home_CardModels.swift
//  Zesto
//
//  Created by Saisrivathsan Manikandan on 3/14/25.
//

import Foundation

struct RecommendCardHome: Identifiable {
    let id = UUID()
    let mealTime: String
    let dishName: String
    var imageURL: String?
}

struct InsightsCardHome: Identifiable {
    let id = UUID()
    let message: String
}

struct PopularDishesCardHome: Identifiable {
    let id = UUID()
    let dishName: String
    var imageURL: String?
}


