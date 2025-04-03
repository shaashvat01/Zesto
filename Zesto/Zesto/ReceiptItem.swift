//
//  ReceiptItem.swift
//  Zesto
//
//  Created by Shaashvat Mittal on 4/2/25.
//

import Foundation

struct ReceiptItem: Codable, Identifiable {
    // Generate a unique ID locally (won't be decoded from JSON)
    let id = UUID()
    var name: String
    var quantity: Int
    var price: Double

    private enum CodingKeys: String, CodingKey {
        case name, quantity, price
    }
}


