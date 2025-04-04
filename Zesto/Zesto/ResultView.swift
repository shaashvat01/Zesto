//
//  ResultView.swift
//  Zesto
//
//  Created by Shaashvat Mittal on 3/16/25.
//

import SwiftUI
import SwiftData

struct ResultView: View {
    @Binding var items: [ReceiptItem]
    let isLoading: Bool
    let openAIResponse: String
    let onGoBack: () -> Void
    @ObservedObject var inventoryVM: InventoryViewModel

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss

    @State private var selectedItem: ReceiptItem? = nil
    @State private var isAddingToInventory = false
    
    private func binding(for item: ReceiptItem) -> Binding<ReceiptItem> {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else {
            fatalError("Item not found")
        }
        return $items[index]
    }


    var body: some View {
        ZStack {
            // Main content
            VStack {
                HStack {
                    Button("Go Back") {
                        onGoBack()
                        dismiss()
                    }
                    Spacer()
                    Button("Add to Inventory") {
                        // Add to SwiftData
                        inventoryVM.addToInventory(items, context: modelContext)

                        // Show animation state
                        isAddingToInventory = true

                        // After delay, go back
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.75) {
                            onGoBack()
                            dismiss()
                        }
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
            .blur(radius: isAddingToInventory ? 10 : 0)  // Optional blur behind overlay

            
            if isAddingToInventory {
                VStack(spacing: 12) {
                    LottieView(animationName: "inventoryLottie") // file name without `.json`
                        .frame(width: 50, height: 50) // Adjust size here
                        .scaleEffect(0.2)
                        .padding(.bottom, 60)
                    
                    Text("Added to Inventory")
                        .font(.title3)
                        .bold()
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground).opacity(0.9))
                .ignoresSafeArea()
            }
        }
        .navigationTitle("Scan Result")
        .navigationBarBackButtonHidden(true)
        .sheet(item: $selectedItem) { item in
            EditReceiptView(item: binding(for: item))
        }

    }
}
