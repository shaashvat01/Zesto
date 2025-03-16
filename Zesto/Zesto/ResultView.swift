//
//  ResultView.swift
//  Zesto
//
//  Created by Shaashvat Mittal on 3/16/25.
//

import SwiftUI

struct ResultView: View {
    
    let image: UIImage

    @State private var recognizedText: String = ""
    @State private var perplexityResponse: String = ""
    @State private var isLoading: Bool = true

    var body: some View {
        VStack
        {
            if isLoading
            {
                ProgressView("Processing image...")
                    .padding()
            }
            else
            {
                ScrollView
                {
                    Text("Extracted Text:")
                        .font(.headline)
                        .padding(.top)
                    Text(recognizedText)
                        .padding()

                    Divider()
                        .padding(.vertical)

                    Text("Perplexity Analysis:")
                        .font(.headline)
                    Text(perplexityResponse)
                        .padding()
                }
            }
        }
        .navigationTitle("Scan Result")
        .onAppear {
            processImage()
        }
    }

    func processImage() {
        // Using VisionManager to extract text from the image.
        VisionManager.shared.recognizeText(from: image) { text in
            if let text = text, !text.isEmpty {
                self.recognizedText = text
                // Sending the extracted text to Perplexity.
                Perplexity.shared.processImage(text) { response in
                    if let response = response
                    {
                        self.perplexityResponse = response
                    }
                    else
                    {
                        self.perplexityResponse = "No response from API."
                    }
                    self.isLoading = false
                }
            }
            else
            {
                self.recognizedText = "No text found."
                self.isLoading = false
            }
        }
    }
}
