//
//  InventoryViewModel.swift
//  Zesto
//
//  Created by Shaashvat Mittal on 4/3/25.
//

import SwiftUI
import SwiftData
import Foundation

// Simple normalization: lowercase and trim spaces.
func basicNormalize(_ text: String) -> String {
    return text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
}

// Robust normalization using NSLinguisticTagger.
func normalizeText(_ text: String) -> String {
    let lower = text.lowercased()
    let noPunct = lower.components(separatedBy: CharacterSet.punctuationCharacters).joined(separator: " ")
    let trimmed = noPunct.trimmingCharacters(in: .whitespacesAndNewlines)
    
    let tagger = NSLinguisticTagger(tagSchemes: [.lemma], options: 0)
    tagger.string = trimmed
    var words = [String]()
    let range = NSRange(location: 0, length: trimmed.utf16.count)
    tagger.enumerateTags(in: range, unit: .word, scheme: .lemma, options: [.omitPunctuation, .omitWhitespace]) { tag, tokenRange, _ in
        if let lemma = tag?.rawValue {
            words.append(lemma)
        } else {
            let word = (trimmed as NSString).substring(with: tokenRange)
            words.append(word)
        }
    }
    return words.joined(separator: " ")
}

// Levenshtein distance.
func levenshtein(_ a: String, _ b: String) -> Int {
    let aArr = Array(a)
    let bArr = Array(b)
    var dist = [[Int]](repeating: [Int](repeating: 0, count: bArr.count + 1), count: aArr.count + 1)
    for i in 0...aArr.count { dist[i][0] = i }
    for j in 0...bArr.count { dist[0][j] = j }
    for i in 1...aArr.count {
        for j in 1...bArr.count {
            if aArr[i-1] == bArr[j-1] {
                dist[i][j] = dist[i-1][j-1]
            } else {
                dist[i][j] = min(dist[i-1][j], dist[i][j-1], dist[i-1][j-1]) + 1
            }
        }
    }
    return dist[aArr.count][bArr.count]
}

func similarityRatio(_ a: String, _ b: String) -> Double {
    let maxLen = max(a.count, b.count)
    if maxLen == 0 { return 100.0 }
    let d = Double(levenshtein(a, b))
    return (1.0 - d / Double(maxLen)) * 100.0
}

func isLikelySame(_ a: String, _ b: String, threshold: Double = 85.0) -> Bool {
    return similarityRatio(a, b) >= threshold
}

// Merge duplicate ReceiptItems in one scan.
func unifyItems(_ items: [ReceiptItem]) -> [ReceiptItem] {
    var dict = [String: ReceiptItem]()
    for item in items {
        let key = basicNormalize(item.name) + "::" + basicNormalize(item.type)
        if var exist = dict[key] {
            exist.quantity += item.quantity
            dict[key] = exist
        } else {
            dict[key] = item
        }
    }
    return Array(dict.values)
}

class InventoryViewModel: ObservableObject {
    func addToInventory(_ receiptItems: [ReceiptItem], context: ModelContext) {
        // Merge duplicate items from the same scan.
        let unifiedItems = unifyItems(receiptItems)
        
        // Get existing inventory items.
        let fetchDesc = FetchDescriptor<InventoryItem>()
        let existingItems: [InventoryItem] = (try? context.fetch(fetchDesc)) ?? []
        
        // Build a dictionary of existing items using basic normalization as key.
        var invDict = [String: InventoryItem]()
        for item in existingItems {
            let key = basicNormalize(item.name) + "::" + basicNormalize(item.type)
            invDict[key] = item
        }
        
        // Process each item from the new scan.
        for rItem in unifiedItems {
            let key = basicNormalize(rItem.name) + "::" + basicNormalize(rItem.type)
            if let existing = invDict[key] {
                // Check with fuzzy matching.
                if isLikelySame(normalizeText(existing.name), normalizeText(rItem.name)) &&
                    isLikelySame(normalizeText(existing.type), normalizeText(rItem.type)) {
                    existing.quantity += rItem.quantity
                } else {
                    fetchImage(for: rItem.name, type: rItem.type) { url in
                        let newItem = InventoryItem(
                            name: rItem.name,
                            quantity: rItem.quantity,
                            price: rItem.price,
                            type: rItem.type,
                            imageURL: url
                        )
                        context.insert(newItem)
                        invDict[key] = newItem
                    }
                }
            } else {
                fetchImage(for: rItem.name, type: rItem.type) { url in
                    let newItem = InventoryItem(
                        name: rItem.name,
                        quantity: rItem.quantity,
                        price: rItem.price,
                        type: rItem.type,
                        imageURL: url
                    )
                    context.insert(newItem)
                    invDict[key] = newItem
                }
            }
        }
        
        do {
            try context.save()
        } catch {
            print("Error saving: \(error)")
        }
    }
    
    func removeItem(_ item: InventoryItem, context: ModelContext) {
        context.delete(item)
        do {
            try context.save()
        } catch {
            print("Error deleting: \(error)")
        }
    }
}

func fetchImage(for dishName: String, type: String?, completion: @escaping (String?) -> Void) {
    let placeholder = "https://via.placeholder.com/150"
    let query = type == nil ? dishName : "\(dishName) \(type!)"
    let base = "https://bobo999.pythonanywhere.com/get_image?dish="
    guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
          let url = URL(string: "\(base)\(encoded)") else {
        print("Bad URL for \(dishName) type: \(type ?? "nil")")
        completion(placeholder)
        return
    }
    
    print("Fetching image from: \(url)")
    
    URLSession.shared.dataTask(with: url) { data, _, error in
        if let err = error {
            print("Error: \(err.localizedDescription)")
            completion(placeholder)
            return
        }
        guard let data = data else {
            print("No data.")
            completion(placeholder)
            return
        }
        do {
            let imgResp = try JSONDecoder().decode(ImageResponse.self, from: data)
            let imgUrl = imgResp.image_url
            print("Got image URL: \(imgUrl)")
            DispatchQueue.main.async {
                completion(imgUrl)
            }
        } catch {
            print("Decode error: \(error)")
            completion(placeholder)
        }
    }.resume()
}
