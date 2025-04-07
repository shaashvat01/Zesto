//
//  EditInventoryView.swift
//  Zesto
//
//  Created by Shaashvat Mittal on 4/5/25.
//

import Foundation
import SwiftUI
import SwiftData

struct EditInventoryView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @Bindable var item: InventoryItem
    
    // Predefined list of categories. Adjust as needed.
    let categories = ["Fruit", "Vegetable", "Dairy", "Meat", "Seafood", "Condiment", "Beverage", "Snack", "Grain", "Frozen", "Bakery", "Misc"]
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $item.name)
                TextField("Quantity", value: $item.quantity, format: .number)
                TextField("Price", value: $item.price, format: .currency(code: "USD"))
                
                // New Picker for editing the item's type.
                Picker("Category", selection: $item.type) {
                    ForEach(categories, id: \.self) { category in
                        Text(category).tag(category)
                    }
                }
            }
            .navigationTitle("Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        do {
                            try context.save()
                        } catch {
                            print("Error saving: \(error)")
                        }
                        dismiss()
                    }
                }
            }
        }
    }
}
