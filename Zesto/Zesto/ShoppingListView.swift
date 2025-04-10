//
//  ShoppingListView.swift
//  Zesto
//
//  Created by Shaashvat Mittal on 4/8/25.
//

import SwiftUI
import SwiftData

struct ShoppingListView: View {
    @Environment(\.dismiss) var dismiss
    @Query var shoppingItems: [ShoppingListItem]
    @Environment(\.modelContext) var context

    var body: some View {
        NavigationView
        {
            VStack
            {
                List
                {
                    ForEach(shoppingItems) { item in
                        HStack (spacing: 12)
                        {
                            Button(action:
                            {
                                item.isChecked.toggle()
                                do
                                {
                                    try context.save()
                                }
                                catch
                                {
                                    print("Error saving checkbox state: \(error)")
                                }
                            })
                            {
                                Image(systemName: item.isChecked ? "checkmark.square.fill" : "square")
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // image display
                            if let urlStr = item.imageURL, let url = URL(string: urlStr)
                            {
                                AsyncImage(url: url) { phase in
                                    switch phase
                                    {
                                        case .empty:
                                            ProgressView()
                                                .frame(width: 40, height: 40)
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 40, height: 40)
                                                .clipped()
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                        case .failure:
                                            Image(systemName: "photo")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 40, height: 40)
                                                .foregroundColor(.gray)
                                        @unknown default:
                                            EmptyView()
                                    }
                                }
                            }
                            else
                            {
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                            }
                            
                            VStack(alignment: .leading)
                            {
                                Text(item.name)
                                    .font(.headline)
                                
                                Text("Quantity: \(item.quantity)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text(String(format: "$%.2f", item.price))
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                context.delete(item)
                                do {
                                    try context.save()
                                } catch {
                                    print("Error deleting shopping list item: \(error)")
                                }
                            } label: {
                                Text("Delete")
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .background(Color.white)
                //.padding(.top, 0)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar
                {
                    
                    ToolbarItem(placement: .navigationBarLeading)
                    {
                        Button(action:
                        {
                            dismiss()
                        })
                        {
                            HStack
                            {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                        }
                    }
                    
                    ToolbarItem(placement: .principal)
                    {
                        Text("Shopping List")
                            .font(.system(size: 25, weight: .bold))
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing)
                    {
                        Button(action: clearShoppingList)
                        {
                            Text("Clear List")
                                .foregroundColor(.red)
                        }
                    }
                }

            }
            
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func clearShoppingList()
    {
        for item in shoppingItems
        {
            context.delete(item)
        }
        do
        {
            try context.save()
        }
        catch
        {
            print("Error clearing shopping list: \(error)")
        }
    }
}


// For preview in Xcode
struct ShoppingListView_Previews: PreviewProvider {
    // Create a container for ShoppingListItem
    static let container: ModelContainer = {
        do {
            return try ModelContainer(for: ShoppingListItem.self)
        } catch {
            fatalError("Failed to create model container: \(error)")
        }
    }()
    
    static var previews: some View {
        // Get the model context from the container
        let context = container.mainContext
        
        let sampleItem1 = ShoppingListItem(name: "Apple", quantity: 3, price: 0.99, type: "Fruit", imageURL: "https://via.placeholder.com/40")
        let sampleItem2 = ShoppingListItem(name: "Bread", quantity: 1, price: 2.49, type: "Bakery", imageURL: "https://via.placeholder.com/40")
        context.insert(sampleItem1)
        context.insert(sampleItem2)
        
        return ShoppingListView()
            .environment(\.modelContext, context)
            .previewDisplayName("ShoppingListView Preview")
    }
}
