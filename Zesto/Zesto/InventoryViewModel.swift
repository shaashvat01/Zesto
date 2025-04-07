//
//  InventoryViewModel.swift
//  Zesto
//
//  Created by Shaashvat Mittal on 4/3/25.
//

import SwiftUI
import SwiftData
import Foundation

// MARK: - Basic Normalization (for dictionary keys)
// This basic normalization only lowercases and trims spaces.
func basicNormalize(_ text: String) -> String {
    return text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
}

// MARK: - Robust Normalization (for fuzzy matching)
// Uses NSLinguisticTagger for lemmatization.
func normalizeText(_ text: String) -> String {
    let lowercased = text.lowercased()
    let cleaned = lowercased.components(separatedBy: CharacterSet.punctuationCharacters).joined(separator: " ")
    let trimmed = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    
    let tagger = NSLinguisticTagger(tagSchemes: [.lemma], options: 0)
    tagger.string = trimmed
    var normalizedWords: [String] = []
    
    let range = NSRange(location: 0, length: trimmed.utf16.count)
    tagger.enumerateTags(in: range, unit: .word, scheme: .lemma, options: [.omitPunctuation, .omitWhitespace]) { tag, tokenRange, _ in
        if let lemma = tag?.rawValue {
            normalizedWords.append(lemma)
        } else {
            let word = (trimmed as NSString).substring(with: tokenRange)
            normalizedWords.append(word)
        }
    }
    
    return normalizedWords.joined(separator: " ")
}

// MARK: - Fuzzy Matching Helpers

func levenshtein(_ aStr: String, _ bStr: String) -> Int {
    let a = Array(aStr)
    let b = Array(bStr)
    let empty = [Int](repeating: 0, count: b.count + 1)
    var last = [Int](0...b.count)
    
    for (i, ca) in a.enumerated() {
        var cur = [i + 1] + empty
        for (j, cb) in b.enumerated() {
            cur[j + 1] = ca == cb ? last[j] : min(last[j], last[j + 1], cur[j]) + 1
        }
        last = cur
    }
    return last.last!
}

func similarityRatio(_ a: String, _ b: String) -> Double {
    let maxLength = max(a.count, b.count)
    if maxLength == 0 { return 100.0 }
    let distance = Double(levenshtein(a, b))
    return (1.0 - distance / Double(maxLength)) * 100.0
}

func isLikelySame(_ a: String, _ b: String, threshold: Double = 85.0) -> Bool {
    let ratio = similarityRatio(a, b)
    return ratio >= threshold
}

// MARK: - Unify Items within a Single Scan
// Merge duplicate ReceiptItems from the same scan.
func unifyItems(_ items: [ReceiptItem]) -> [ReceiptItem] {
    var dict = [String: ReceiptItem]()
    
    for item in items {
        let key = basicNormalize(item.name) + "::" + basicNormalize(item.type)
        if var existing = dict[key] {
            existing.quantity += item.quantity
            dict[key] = existing
        } else {
            dict[key] = item
        }
    }
    
    return Array(dict.values)
}

// MARK: - InventoryViewModel

class InventoryViewModel: ObservableObject {
    // Adds scanned receipt items to inventory.
    func addToInventory(_ receiptItems: [ReceiptItem], context: ModelContext) {
        // Unify duplicates within the new scanned receipt.
        let unifiedReceiptItems = unifyItems(receiptItems)
        
        // Build a dictionary of existing inventory items using basic normalization as key.
        let fetchDescriptor = FetchDescriptor<InventoryItem>()
        let existingItems: [InventoryItem] = (try? context.fetch(fetchDescriptor)) ?? []
        
        var inventoryDict = [String: InventoryItem]()
        for item in existingItems {
            let key = basicNormalize(item.name) + "::" + basicNormalize(item.type)
            inventoryDict[key] = item
        }
        
        // Process each unified receipt item.
        for rItem in unifiedReceiptItems {
            let key = basicNormalize(rItem.name) + "::" + basicNormalize(rItem.type)
            
            if let existing = inventoryDict[key] {
                // Use fuzzy matching (with robust normalization) to verify the match.
                if isLikelySame(normalizeText(existing.name), normalizeText(rItem.name)) &&
                   isLikelySame(normalizeText(existing.type), normalizeText(rItem.type)) {
                    existing.quantity += rItem.quantity
                } else {
                    // If fuzzy matching fails (unlikely), treat it as a new item.
                    fetchImage(for: rItem.name, type: rItem.type) { imageURL in
                        let invItem = InventoryItem(
                            name: rItem.name,
                            quantity: rItem.quantity,
                            price: rItem.price,
                            type: rItem.type,
                            imageURL: imageURL
                        )
                        context.insert(invItem)
                        inventoryDict[key] = invItem
                    }
                }
            } else {
                // No existing item for this key; create a new one.
                fetchImage(for: rItem.name, type: rItem.type) { imageURL in
                    let invItem = InventoryItem(
                        name: rItem.name,
                        quantity: rItem.quantity,
                        price: rItem.price,
                        type: rItem.type,
                        imageURL: imageURL
                    )
                    context.insert(invItem)
                    inventoryDict[key] = invItem
                }
            }
        }
        
        do {
            try context.save()
        } catch {
            print("Failed to save inventory items: \(error)")
        }
    }
    
    // Removes an inventory item.
    func removeItem(_ item: InventoryItem, context: ModelContext) {
        context.delete(item)
        do {
            try context.save()
        } catch {
            print("Failed to delete inventory item: \(error)")
        }
    }
}

// MARK: - fetchImage Function

func fetchImage(for dishName: String, type: String?, completion: @escaping (String?) -> Void) {
    let placeholderURL = "https://via.placeholder.com/150"
    let combinedQuery = type == nil ? dishName : "\(dishName) \(type!)"
    let baseURL = "https://bobo999.pythonanywhere.com/get_image?dish="
    
    guard let encodedQuery = combinedQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
          let url = URL(string: "\(baseURL)\(encodedQuery)") else {
        print("❌ Invalid URL for dish: \(dishName) with type: \(type ?? "nil")")
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
                completion(imageUrl)
            }
        } catch {
            print("❌ Failed to decode JSON: \(error)")
            completion(placeholderURL)
        }
    }.resume()
}
