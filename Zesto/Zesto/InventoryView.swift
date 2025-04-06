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
    // SwiftData fetched items
    @Query var allItems: [InventoryItem]
    
    // For editing
    @State private var editing: InventoryItem? = nil
    
    // Searching
    @State private var searchText: String = ""
    @State private var selectedFilter: FilterType = .name
    
    enum FilterType: String, CaseIterable, Identifiable {
        case name = "Name"
        case price = "Price"
        case quantity = "Quantity"
        
        var id: String { rawValue }
    }
    
    // Filtered items based on search text & filter type
    var filteredItems: [InventoryItem] {
        let searchValue = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        guard !searchValue.isEmpty else {
            return allItems
        }
        
        switch selectedFilter {
        case .name:
            return allItems.filter { $0.name.lowercased().contains(searchValue) }
        case .price:
            guard let targetPrice = Double(searchValue) else { return [] }
            return allItems.filter { $0.price == targetPrice }
        case .quantity:
            guard let targetQty = Int(searchValue) else { return [] }
            return allItems.filter { $0.quantity == targetQty }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Custom Search Bar
                HStack {
                    // Left search icon
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    // Search text field
                    TextField("Search \(selectedFilter.rawValue.lowercased())", text: $searchText)
                        .foregroundColor(.primary)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                    
                    // Right filter/menu icon
                    Menu {
                        ForEach(FilterType.allCases, id: \.self) { filterCase in
                            Button(filterCase.rawValue) {
                                selectedFilter = filterCase
                            }
                        }
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(uiColor: .systemGray6))
                )
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Main list
                List {
                    ForEach(filteredItems) { item in
                        HStack(alignment: .center, spacing: 16)
                        {
                            // Thumbnail image (placeholder)
                            Image("Apple")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            
                            // Name + Price in a VStack
                            VStack(alignment: .leading, spacing: 4)
                            {
                                Text(item.name)
                                    .font(.headline)
                                Text(String(format: "Price: $%.2f", item.price))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            // Quantity stepper-like control
                            HStack(spacing: 2)
                            {
                                Button
                                {
                                    // Decrement quantity if above 0
                                    if item.quantity > 0
                                    {
                                        item.quantity -= 1
                                        // Save update directly to SwiftData
                                        do
                                        {
                                            try item.modelContext?.save()
                                        }
                                        catch
                                        {
                                            print("Error saving after minus: \(error)")
                                        }
                                    }
                                }
                                label:
                                {
                                    Image(systemName: "minus.circle")
                                        .foregroundColor(.blue)
                                        .frame(minWidth: 44, minHeight: 44)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Text("\(item.quantity)")
                                    .font(.body)
                                    .frame(minWidth: 25)
                                
                                Button
                                {
                                    // Increment quantity
                                    item.quantity += 1
                                    // Save update directly to SwiftData
                                    do {
                                        try item.modelContext?.save()
                                    } catch {
                                        print("Error saving after plus: \(error)")
                                    }
                                }
                                label:
                                {
                                    Image(systemName: "plus.circle")
                                        .foregroundColor(.blue)
                                        .frame(minWidth: 44, minHeight: 44)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.vertical, 8)
                        .swipeActions
                        {
                            // Delete action
                            Button(role: .destructive)
                            {
                                if let context = item.modelContext
                                {
                                    viewModel.removeItem(item, context: context)
                                }
                            }
                            label:
                            {
                                Text("Delete")
                            }
                            
                            // Edit action
                            Button
                            {
                                editing = item
                            }
                            label:
                            {
                                Text("Edit")
                            }
                            .tint(.blue)
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .background(Color.white)
            }
            .navigationTitle("My Inventory")
            .navigationBarTitleDisplayMode(.inline)
            // Edit sheet
            .sheet(item: $editing) { item in
                EditInventoryView(item: item)
            }
        }
    }
}
