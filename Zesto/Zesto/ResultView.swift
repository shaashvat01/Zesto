//
//  ResultView.swift
//  Zesto
//
//  Created by Shaashvat Mittal on 3/16/25.
//

import SwiftUI

struct ResultView: View {
    // The final recognized items
    let items: [ReceiptItem]
    // Whether we are still loading
    let isLoading: Bool
    // Any leftover raw text from OpenAI
    let openAIResponse: String
    
    // A callback for “Go Back”
    let onGoBack: () -> Void
    
    @Environment(\.dismiss) var dismiss
    
    // For sheet-based editing
    @State private var selectedItem: ReceiptItem? = nil
    
    // For navigating to inventory
    @State private var showInventory = false
    
    var body: some View {
        VStack {
            // Top buttons
            HStack {
                Button("Go Back") {
                    // If you want to reset the scanning state in the parent:
                    onGoBack()
                    dismiss()
                }
                Spacer()
                Button("Add to Inventory") {
                    showInventory = true
                }
            }
            .padding()

            // If scanning is still ongoing, show a spinner
            if isLoading {
                ProgressView("Processing image...")
                    .padding()
            }
            else {
                // If we have recognized items
                if !items.isEmpty {
                    List {
                        HStack {
                            Text("Item")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("Quantity")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, alignment: .center)
                            Text("Price")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .padding(.vertical, 4)

                        ForEach(items) { item in
                            HStack {
                                Text(item.name)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("\(item.quantity)")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                Text(String(format: "$%.2f", item.price))
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                // Show a sheet to edit
                                selectedItem = item
                            }
                            .padding(.vertical, 4)
                        }
                    }
                } else {
                    // If no items, show raw OpenAI text or a message
                    ScrollView {
                        Text("AI Analysis:")
                            .font(.headline)
                        Text(openAIResponse)
                            .padding()
                    }
                }
            }
        }
        .navigationTitle("Scan Result")
        .navigationBarBackButtonHidden(true)
        .sheet(item: $selectedItem) { item in
            // We can pass a binding if we want to allow edits
            // But we need to store the updated data somewhere in the parent
            // For now, let's just pass a constant binding so it's read-only
            EditReceiptView(item: .constant(item))
        }
        // Navigate to the inventory screen
        .navigationDestination(isPresented: $showInventory) {
            InventoryView()
        }
    }
}

