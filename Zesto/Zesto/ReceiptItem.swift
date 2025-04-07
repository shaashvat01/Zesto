//
//  ReceiptItem.swift
//  Zesto
//
//  Created by Shaashvat Mittal on 4/2/25.
//

import Foundation

struct ReceiptItem: Codable, Identifiable, Equatable {
    // Generate a unique ID locally (won't be decoded from JSON)
    let id = UUID()
    var name: String
    var quantity: Int
    var price: Double
    var type: String 

    private enum CodingKeys: String, CodingKey {
        case name, quantity, price, type
    }
}
