//
//  Home_CardModels.swift
//  Zesto
//
//  Created by Saisrivathsan Manikandan on 3/14/25.
//

import Foundation
import SwiftUICore


struct RecommendCardHome: Identifiable {
    let id = UUID()
    let mealTime: String
    let dishName: String
    var imageURL: String?
    var RecipeModel: RecipeModel?
}

struct InsightsCardHome: Identifiable {
    let id = UUID()
    let message: String
    let Color: Color
}

struct PopularDishesCardHome: Identifiable {
    let id = UUID()
    let dishName: String
    var imageURL: String?
    var RecipeModel: RecipeModel?
}


