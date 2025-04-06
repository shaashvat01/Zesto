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
    
    var body: some View {
        NavigationView
        {
            Form
            {
                TextField("Name", text: $item.name)
                TextField("Quantity", value: $item.quantity, format: .number)
                TextField("Price", value: $item.price, format: .currency(code: "USD"))
            }
            .navigationTitle("Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar
            {
                ToolbarItem(placement: .navigationBarTrailing)
                {
                    Button("Save")
                    {
                        do
                        {
                            try context.save()
                        }
                        catch
                        {
                            print("Error saving: \(error)")
                        }
                        dismiss()
                    }
                }
            }
        }
    }
}
