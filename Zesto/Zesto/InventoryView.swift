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
    // SwiftData fetched items.
    @Query var allItems: [InventoryItem]
    @EnvironmentObject var appState: AppState
    
    // For editing.
    @State private var editing: InventoryItem? = nil
    
    // Searching.
    @State private var searchText: String = ""
    @State private var selectedFilter: FilterType = .name
    
    enum FilterType: String, CaseIterable, Identifiable {
        case name = "Name"
        case price = "Price"
        case quantity = "Quantity"
        case category = "Category"  // New filter option
        
        var id: String { rawValue }
    }
    
    // Filtered items based on search text & selected filter.
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
        case .category:
            return allItems.filter { $0.type.lowercased().contains(searchValue) }
        }
    }
    
    // Group the filtered items by their type (category).
    var groupedItems: [String: [InventoryItem]] {
        Dictionary(grouping: filteredItems, by: { $0.type })
    }
    
    // Sorted list of categories (for consistent ordering).
    var sortedCategories: [String] {
        groupedItems.keys.sorted()
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Custom Search Bar.
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search \(selectedFilter.rawValue.lowercased())", text: $searchText)
                        .foregroundColor(.primary)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                    
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
                
                // Grouped List.
                List {
                    ForEach(sortedCategories, id: \.self) { category in
                        Section(header: Text(category)) {
                            ForEach(groupedItems[category] ?? []) { item in
                                HStack(alignment: .center, spacing: 16) {
                                    AsyncImage(url: URL(string: item.imageURL ?? "")) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                                .frame(width: 50, height: 50)
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 50, height: 50)
                                                .clipped()
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                        case .failure:
                                            Image(systemName: "photo")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 50, height: 50)
                                                .clipped()
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                                .foregroundColor(.gray)
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.name)
                                            .font(.headline)
                                        Text(String(format: "Price: $%.2f", item.price))
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    // Quantity control: decrement/increment.
                                    HStack(spacing: 2) {
                                        Button {
                                            if item.quantity > 1 {
                                                item.quantity -= 1
                                                do {
                                                    try item.modelContext?.save()
                                                } catch {
                                                    print("Error saving after minus: \(error)")
                                                }
                                            } else {
                                                // If quantity reaches 0, remove the item.
                                                if let context = item.modelContext {
                                                    viewModel.removeItem(item, context: context)
                                                }
                                            }
                                        } label: {
                                            Image(systemName: "minus.circle")
                                                .foregroundColor(.blue)
                                                .frame(minWidth: 44, minHeight: 44)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        
                                        Text("\(item.quantity)")
                                            .font(.body)
                                            .frame(minWidth: 25)
                                        
                                        Button {
                                            item.quantity += 1
                                            do {
                                                try item.modelContext?.save()
                                            } catch {
                                                print("Error saving after plus: \(error)")
                                            }
                                        } label: {
                                            Image(systemName: "plus.circle")
                                                .foregroundColor(.blue)
                                                .frame(minWidth: 44, minHeight: 44)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.vertical, 8)
                                .swipeActions {
                                    Button(role: .destructive) {
                                        if let context = item.modelContext {
                                            viewModel.removeItem(item, context: context)
                                        }
                                    } label: {
                                        Text("Delete")
                                    }
                                    
                                    Button {
                                        editing = item
                                    } label: {
                                        Text("Edit")
                                    }
                                    .tint(.blue)
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .background(Color.white)
            }
            .sheet(item: $editing) { item in
                EditInventoryView(item: item)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            appState.hideTopBar = false 
        }
    }
}
