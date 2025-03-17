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
    @State private var openAIResponse: String = ""
    @State private var isLoading: Bool = true

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Processing image...")
                    .padding()
            } else {
                ScrollView {
                    Text("OpenAI Analysis:")
                        .font(.headline)
                    Text(openAIResponse)
                        .padding()
                }
            }
        }
        .navigationTitle("Scan Result")
        .onAppear {
            processImage()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                EmptyView()
            }
        }
    }

    func processImage() {
        // Use VisionManager to extract text from the image.
        VisionManager.shared.recognizeText(from: image) { text in
            if let text = text, !text.isEmpty {
                self.recognizedText = text
                // Sending the extracted text to OpenAI.
                OpenAI.shared.processImage(text) { response in
                    if let response = response {
                        self.openAIResponse = response
                    } else {
                        self.openAIResponse = "No response from API."
                    }
                    self.isLoading = false
                }
            } else {
                self.recognizedText = "No text found."
                self.isLoading = false
            }
        }
    }
}
