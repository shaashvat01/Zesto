//
//  ResultView.swift
//  Zesto
//
//  Created by Shaashvat Mittal on 3/16/25.
//

import SwiftUI

struct ResultView: View {
    let image: UIImage
    @StateObject private var viewModel = ResultViewModel()
    @State private var selectedItem: ReceiptItem? = nil

    var body: some View {
        VStack
        {
            if viewModel.isLoading
            {
                ProgressView("Processing image...")
                    .padding()
            }
            else
            {
                if !viewModel.receiptItems.isEmpty
                {
                    List
                    {
                        HStack
                        {
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
                        
                        ForEach(viewModel.receiptItems){ item in
                            HStack
                            {
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
                }
                else
                {
                    // Fallback: show raw OpenAI response if JSON decoding failed.
                    ScrollView
                    {
                        Text("AI Analysis:")
                            .font(.headline)
                        Text(viewModel.openAIResponse)
                            .padding()
                    }
                }
            }
        }
        .navigationTitle("Scan Result")
        .onAppear {
            if viewModel.receiptItems.isEmpty {
                viewModel.processImage(image)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                EmptyView()
            }
        }
        // Use the .sheet(item:) modifier which presents the sheet when selectedItem is non-nil.
        .sheet(item: $selectedItem) { item in
            // Create a binding for the selected item using a helper function.
            EditReceiptView(item: binding(for: item))
        }
    }
    
    // Helper function to get a binding to the selected item in the view model array.
    private func binding(for item: ReceiptItem) -> Binding<ReceiptItem> {
        guard let index = viewModel.receiptItems.firstIndex(where: { $0.id == item.id }) else {
            fatalError("Item not found in array")
        }
        return $viewModel.receiptItems[index]
    }
}

struct ResultView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            // Create a dummy image using a system image for preview purposes.
            ResultView(image: UIImage(systemName: "photo") ?? UIImage())
        }
    }
}
