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
        // If you want to fully reset state, call this:
        selectedImage = nil
        sourceType = nil
        isShowingResult = false
        recognizedItems.removeAll()
        openAIResponse = ""
        isLoading = false
    }

    // The main scanning logic
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
                
                // 2) Send recognized text to OpenAI
                OpenAI.shared.processImage(text) { response in
                    DispatchQueue.main.async {
                        guard let response = response, !response.isEmpty else {
                            self.openAIResponse = "No response from API."
                            self.isLoading = false
                            return
                        }
                        
                        // Attempt to decode items from the JSON returned by OpenAI
                        if let data = response.data(using: .utf8) {
                            do {
                                let items = try JSONDecoder().decode([ReceiptItem].self, from: data)
                                self.recognizedItems = items
                            } catch {
                                print("Failed to decode items: \(error)")
                                // If decoding fails, store raw text in openAIResponse
                                self.openAIResponse = response
                            }
                        } else {
                            self.openAIResponse = response
                        }
                        self.isLoading = false
                    }
                }
            }
        }
    }
}

