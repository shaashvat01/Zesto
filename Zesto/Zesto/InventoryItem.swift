//
//  InventoryItem.swift
//  Zesto
//
//  Created by Shaashvat Mittal on 4/3/25.
//

import SwiftData
import Foundation

@Model
class InventoryItem {
    // SwiftData model class
    // SwiftData automatically generates an ID behind the scenes
    var name: String
    var quantity: Int
    var price: Double
    var imageURL: String?
    
    init(name: String, quantity: Int, price: Double, imageURL: String? = nil) {
        self.name = name
        self.quantity = quantity
        self.price = price
        self.imageURL = imageURL
    }
}
