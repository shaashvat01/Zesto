//
//  ShoppingListItem.swift
//  Zesto
//
//  Created by Shaashvat Mittal on 4/8/25.
//

import SwiftData
import Foundation

// swift data automatically gives each entry its unique value so that we don't have to make it Identifiable or make UUID.
@Model
class ShoppingListItem {
    var name: String
    var quantity: Int
    var price: Double
    var type: String
    var imageURL: String?
    var isChecked: Bool = false

    init(name: String, quantity: Int, price: Double, type: String, imageURL: String? = nil, isChecked: Bool = false) {
        self.name = name
        self.quantity = quantity
        self.price = price
        self.type = type
        self.imageURL = imageURL
        self.isChecked = isChecked
    }
}


