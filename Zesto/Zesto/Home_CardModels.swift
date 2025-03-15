//
//  Home_CardModels.swift
//  Zesto
//
//  Created by Saisrivathsan Manikandan on 3/14/25.
//

import Foundation

public class recommendCardHome{
    var mealTime: String
    var dishName: String
    var image: String
    
    init(mealTime: String, dishName: String, image: String) {
        self.mealTime = mealTime
        self.dishName = dishName
        self.image = image
    }
    
}
