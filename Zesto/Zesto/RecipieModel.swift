//
//  RecipieModel.swift
//  Zesto
//
//  Created by Saisrivathsan Manikandan on 4/4/25.
//

import Foundation

struct RecipeModel{
    let name: String
    var tags: [String] = []
    let ingredients: [String]
    let instructions: [String]
    let imageURL: URL
}
