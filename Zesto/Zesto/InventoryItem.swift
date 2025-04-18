//
//  InventoryItem.swift
//  Zesto
//
//  Created by Shaashvat Mittal on 4/3/25.
//

import SwiftData
import Foundation

@Model
class InventoryItem
{
    var name: String
    var quantity: Int
    var price: Double
    var type: String 
    var imageURL: String?
    
    init(name: String, quantity: Int, price: Double, type: String, imageURL: String? = nil)
    {
        self.name = name
        self.quantity = quantity
        self.price = price
        self.type = type
        self.imageURL = imageURL
    }
}
