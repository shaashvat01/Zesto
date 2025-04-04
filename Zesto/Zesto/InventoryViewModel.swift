//
//  InventoryViewModel.swift
//  Zesto
//
//  Created by Shaashvat Mittal on 4/3/25.
//

import SwiftUI
import SwiftData

@Observable
class InventoryViewModel: ObservableObject {
    // For now, no stored properties.
    // We do all data insertion/deletion via SwiftData’s ModelContext.

    // Called when we want to add the scanned items to the inventory.
    func addToInventory(_ receiptItems: [ReceiptItem], context: ModelContext) {
        for rItem in receiptItems {
            let invItem = InventoryItem(
                name: rItem.name,
                quantity: rItem.quantity,
                price: rItem.price
            )
            // Insert into SwiftData’s context
            context.insert(invItem)
        }
        
        // SwiftData automatically saves eventually,
        // or call try? context.save() if you want immediate persistence
        do {
            try context.save()
        } catch {
            print("Failed to save inventory items: \(error)")
        }
    }
    
    // Example: remove an item from inventory
    func removeItem(_ item: InventoryItem, context: ModelContext) {
        context.delete(item)
        do {
            try context.save()
        } catch {
            print("Failed to delete inventory item: \(error)")
        }
    }
}

