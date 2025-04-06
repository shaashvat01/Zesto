//
//  InventoryViewModel.swift
//  Zesto
//
//  Created by Shaashvat Mittal on 4/3/25.
//
import SwiftUI
import SwiftData


class InventoryViewModel: ObservableObject {
    // Use @EnvironmentObject for dependency injection from the parent vie
    
    // Called when we want to add the scanned items to the inventory.
    func addToInventory(_ receiptItems: [ReceiptItem], context: ModelContext) {
        for rItem in receiptItems {
            // Fetch image URL for the item name
            fetchImage(for: rItem.name) { imageURL in
                // Create the inventory item with the fetched image URL
                let invItem = InventoryItem(
                    name: rItem.name,
                    quantity: rItem.quantity,
                    price: rItem.price,
                    imageURL: imageURL
                )
                
                // Insert into SwiftData’s context
                context.insert(invItem)
            }
        }
        
        // SwiftData automatically saves eventually,
        // or call try? context.save() if you want immediate persistence
        do {
            try context.save()
        } catch {
            print("Failed to save inventory items: \(error)")
        }
    }
    
    // Example: remove an item from inventory
    func removeItem(_ item: InventoryItem, context: ModelContext) {
        context.delete(item)
        do {
            try context.save()
        } catch {
            print("Failed to delete inventory item: \(error)")
        }
    }
}

func fetchImage(for dishName: String, completion: @escaping (String?) -> Void) {
    let placeholderURL = "https://via.placeholder.com/150"
    let baseURL = "https://bobo999.pythonanywhere.com/get_image?dish="
    guard let encodedDish = dishName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
          let url = URL(string: "\(baseURL)\(encodedDish)") else {
        print("❌ Invalid URL for dish: \(dishName)")
        completion(placeholderURL)
        return
    }

    print("🌍 Fetching image from: \(url)")

    URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            print("❌ Error fetching image: \(error.localizedDescription)")
            completion(placeholderURL)
            return
        }

        guard let data = data else {
            print("❌ No data received for image request.")
            completion(placeholderURL)
            return
        }

        do {
            let imageResponse = try JSONDecoder().decode(ImageResponse.self, from: data)
            let imageUrl = imageResponse.image_url
            
            print("✅ Successfully fetched image URL: \(imageUrl)")
            
            DispatchQueue.main.async {
                //self.objectWillChange.send()
                completion(imageUrl)
            }
        } catch {
            print("❌ Failed to decode JSON: \(error)")
            completion(placeholderURL)
        }
    }.resume()
}

