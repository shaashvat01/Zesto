//
//  ResultView.swift
//  Zesto
//
//  Created by Shaashvat Mittal on 3/16/25.
//

import SwiftUI
import SwiftData

struct ResultView: View {
    let items: [ReceiptItem]
    let isLoading: Bool
    let openAIResponse: String
    
    // Callback for going back
    let onGoBack: () -> Void

    // NEW: A reference to your InventoryViewModel
    @ObservedObject var inventoryVM: InventoryViewModel
    
    // Access to the SwiftData context
    @Environment(\.modelContext) private var modelContext
    
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedItem: ReceiptItem? = nil
    //@State private var showInventory = false
    
    var body: some View {
        VStack {
            HStack {
                Button("Go Back") {
                    onGoBack()
                    dismiss()
                }
                Spacer()
                Button("Add to Inventory") {
                    // Convert the scanned items => Inventory
                    inventoryVM.addToInventory(items, context: modelContext)
                    // Possibly navigate to inventory
                    //showInventory = false
                }
            }
            .padding()
            
            if isLoading {
                ProgressView("Processing image...")
                    .padding()
            } else {
                if !items.isEmpty {
                    List {
                        HStack {
                            Text("Item").fontWeight(.semibold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("Quantity").fontWeight(.semibold)
                                .frame(maxWidth: .infinity, alignment: .center)
                            Text("Price").fontWeight(.semibold)
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
                                selectedItem = item
                            }
                            .padding(.vertical, 4)
                        }
                    }
                } else {
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
            // For editing a single item
            // you'd need a mechanism to save changes
            // to recognizedItems in the parent
            EditReceiptView(item: .constant(item))
        }
        // Navigate to Inventory
//        .navigationDestination(isPresented: $showInventory) {
//            // Provide the same inventoryVM
//            InventoryView(viewModel: inventoryVM)
//        }
    }
}
