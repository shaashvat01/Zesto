//
//  ResultViewModel.swift
//  Zesto
//
//  Created by Shaashvat Mittal on 3/29/25.
//

import Foundation
import UIKit

class ResultViewModel: ObservableObject {
    @Published var recognizedText: String = ""
    @Published var openAIResponse: String = ""
    @Published var isLoading: Bool = true
    @Published var receiptItems: [ReceiptItem] = []

    func processImage(_ image: UIImage) {
        isLoading = true

        // Recognize text from the image
        VisionManager.shared.recognizeText(from: image) { [weak self] text in
            guard let self = self else { return }

            DispatchQueue.main.async
            {
                guard let text = text, !text.isEmpty
                else
                {
                    self.recognizedText = "No text found."
                    self.isLoading = false
                    return
                }

                self.recognizedText = text

                // Send the text to OpenAI to extract receipt items
                OpenAI.shared.processImage(text) { response in
                    DispatchQueue.main.async
                    {
                        guard let response = response, !response.isEmpty
                        else
                        {
                            self.openAIResponse = "No response from API."
                            self.isLoading = false
                            return
                        }

                        // Convert OpenAI response into ReceiptItem list
                        if let data = response.data(using: .utf8)
                        {
                            do
                            {
                                let items = try JSONDecoder().decode([ReceiptItem].self, from: data)
                                self.receiptItems = items
                            }
                            catch
                            {
                                print("Failed to decode items: \(error)")
                                self.openAIResponse = response  // Show raw text for now
                            }
                        }
                        else
                        {
                            self.openAIResponse = response
                        }
                        self.isLoading = false
                    }
                }
            }
        }
    }
}
