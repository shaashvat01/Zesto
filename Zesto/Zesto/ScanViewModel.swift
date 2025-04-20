//
//  ScanViewModel.swift
//  Zesto
//
//  Created by Shaashvat Mittal on 4/3/25.
//

import SwiftUI
import UIKit

class ScanViewModel: ObservableObject {
    // For picking images
    @Published var showImagePicker = false
    @Published var sourceType: UIImagePickerController.SourceType? = nil
    @Published var selectedImage: UIImage? = nil
    // For navigating to result screen
    @Published var isShowingResult = false
    
    // Scanning results
    @Published var isLoading = false
    @Published var recognizedItems: [ReceiptItem] = []
    @Published var openAIResponse: String = ""
    
    func pickCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            sourceType = .camera
            showImagePicker = true
        } else {
            print("Camera not available")
        }
    }
    
    func pickGallery() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            sourceType = .photoLibrary
            showImagePicker = true
        } else {
            print("Can't access photo library")
        }
    }
    
    func reset() {
        // Fully reset state
        selectedImage = nil
        sourceType = nil
        isShowingResult = false
        recognizedItems.removeAll()
        openAIResponse = ""
        isLoading = false
    }
    
    func processImage(_ image: UIImage) {
        isLoading = true
        
        // 1) Recognize text via Vision
        VisionManager.shared.recognizeText(from: image) { [weak self] text in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                guard let text = text, !text.isEmpty else {
                    self.openAIResponse = "No text found."
                    self.isLoading = false
                    return
                }
                
                // Clean the OCR text before sending to GPT
                let cleanedText = self.cleanOCRText(text)
                
                // 2) Send cleaned text to OpenAI
                OpenAI.shared.processImage(cleanedText) { response in
                    DispatchQueue.main.async {
                        guard let response = response, !response.isEmpty else {
                            self.openAIResponse = "No response from API."
                            self.isLoading = false
                            return
                        }
                        
                        // First attempt: try to decode JSON directly
                        if let data = response.data(using: .utf8) {
                            do {
                                let items = try JSONDecoder().decode([ReceiptItem].self, from: data)
                                self.recognizedItems = items
                                self.isLoading = false
                            } catch {
                                print("Initial decoding failed: \(error)")
                                
                                // Interactive approach: Ask GPT for a corrected response
                                var followUpPrompt = """
                                Your previous response wasn't valid JSON. Please return only valid JSON with the structure:
                                {"name":"Tomatoes","quantity":1,"price":2.50}, ...
                                """
                                
                                // Optionally, append the original response for context
                                followUpPrompt += "\n\nOriginal Response:\n\(response)"
                                
                                OpenAI.shared.processImage(followUpPrompt) { retryResponse in
                                    DispatchQueue.main.async {
                                        guard let retryResponse = retryResponse, !retryResponse.isEmpty else {
                                            self.openAIResponse = "No response from API on retry."
                                            self.isLoading = false
                                            return
                                        }
                                        
                                        if let retryData = retryResponse.data(using: .utf8) {
                                            do {
                                                let items = try JSONDecoder().decode([ReceiptItem].self, from: retryData)
                                                self.recognizedItems = items
                                            } catch {
                                                print("Retry decoding failed: \(error)")
                                                // If it still fails, show the raw retry response
                                                self.openAIResponse = retryResponse
                                            }
                                        } else {
                                            self.openAIResponse = retryResponse
                                        }
                                        self.isLoading = false
                                    }
                                }
                            }
                        } else {
                            self.openAIResponse = response
                            self.isLoading = false
                        }
                    }
                }
            }
        }
    }
    
    
    // Cleans the raw OCR text by filtering out lines that are not likely to be items
    // and recombining lines if the item name and price are split.
    func cleanOCRText(_ rawText: String) -> String {
        let lines = rawText.components(separatedBy: .newlines)
        
        // Filter out known non-item lines
        let filteredLines = lines.filter { line in
            let lower = line.lowercased()
            return !lower.contains("total")
                && !lower.contains("tax")
                && !lower.contains("change")
                && !lower.contains("payment")
                && !lower.contains("order")
                && !lower.contains("credit")
        }
        
        // Combine lines where the price might have been split onto a separate line.
        // If a line is just a price (a number), append it to the previous line.
        var combinedLines: [String] = []
        for line in filteredLines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if isPrice(trimmed), let last = combinedLines.popLast() {
                combinedLines.append(last + " " + trimmed)
            } else {
                combinedLines.append(line)
            }
        }
        
        return combinedLines.joined(separator: "\n")
    }
    
    // Checks if a given string represents a price.
    func isPrice(_ string: String) -> Bool {
        // Remove any potential dollar signs or spaces
        let cleaned = string.replacingOccurrences(of: "$", with: "").trimmingCharacters(in: .whitespaces)
        return Double(cleaned) != nil
    }
}
