//
//  InventoryView.swift
//  Zesto
//
//  Created by Shaashvat Mittal on 4/3/25.
//

import SwiftUI
import SwiftData

struct InventoryView: View {
    @ObservedObject var viewModel: InventoryViewModel
    // SwiftData auto-fetched items
    @Query var allItems: [InventoryItem]
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Inventory Screen")
                    .font(.title)
                    .padding()

                List {
                    ForEach(allItems) { item in
                        VStack(alignment: .leading, spacing: 5) {
                            Text(item.name)
                                .font(.headline)
                            Text("Qty: \(item.quantity) | Price: \(item.price)")
                                .font(.subheadline)
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                if let context = item.modelContext {
                                    viewModel.removeItem(item, context: context)
                                }
                            } label: {
                                Text("Delete")
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("My Inventory")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}


