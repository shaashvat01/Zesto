//
//  VisionManager.swift
//  scan_test
//
//  Created by Shaashvat Mittal on 3/15/25.
//

import Foundation
import Vision
import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

class VisionManager {
    static let shared = VisionManager()
    
    private let context = CIContext()
    
    // Preprocesses the input image to enhance text recognition accuracy.
    // It applies a Noir filter for high contrast and then sharpens the image.
    func preprocessImage(_ image: UIImage) -> UIImage {
        guard let ciImage = CIImage(image: image) else { return image }
        
        // Apply a Noir effect to convert the image to high-contrast black and white.
        let noirFilter = CIFilter.photoEffectNoir()
        noirFilter.inputImage = ciImage
        guard let noirImage = noirFilter.outputImage else { return image }
        
        // Apply a sharpen filter to improve clarity.
        let sharpenFilter = CIFilter.sharpenLuminance()
        sharpenFilter.inputImage = noirImage
        sharpenFilter.sharpness = 0.5
        guard let sharpenedImage = sharpenFilter.outputImage else { return image }
        
        // Render the processed CIImage into a CGImage and then a UIImage.
        if let cgImage = context.createCGImage(sharpenedImage, from: sharpenedImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        
        return image
    }
    
    // Extracts text from the given image using the Vision framework.
    // The image is preprocessed to improve OCR accuracy.
    func recognizeText(from image: UIImage, completion: @escaping (String?) -> Void) {
        // Preprocess the image for better OCR quality.
        let preprocessedImage = preprocessImage(image)
        
        // Convert UIImage to CGImage.
        guard let cgImage = preprocessedImage.cgImage else {
            completion(nil)
            return
        }
        
        // Create the image request handler.
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        // Create a text recognition request.
        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(nil)
                return
            }
            
            // Concatenate recognized text from observations.
            let extractedText = observations
                .compactMap { $0.topCandidates(1).first?.string }
                .joined(separator: "\n")
            
            completion(extractedText)
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["en-US"]
        
        // Optionally: if you know the receipt area, set a regionOfInterest here.
        // request.regionOfInterest = CGRect(x: 0, y: 0, width: 1, height: 1)
        
        do {
            try requestHandler.perform([request])
        } catch {
            print("Error recognizing the text: \(error.localizedDescription)")
            completion(nil)
        }
    }
}
