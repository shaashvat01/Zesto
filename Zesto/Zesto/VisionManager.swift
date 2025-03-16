//
//  VisionManager.swift
//  scan_test
//
//  Created by Shaashvat Mittal on 3/15/25.
//

import Foundation
import Vision
import UIKit

// managing the text recognition from the image
class VisionManager {
    static let shared = VisionManager()
    
    // extract text from the image and returns it using the completion
    func recognizeText(from image: UIImage, completion: @escaping (String?) -> Void) {
        // converting UIImage to CGImage
        guard let cgImage = image.cgImage else { return }
        // for image processing
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        // this is text recog request
        let request = VNRecognizeTextRequest { (request, error) in
            // exit if no text
            guard let observations = request.results as? [VNRecognizedTextObservation] else {return}
            
            // extract text
            let extractedText = observations
                .compactMap{$0.topCandidates(1).first?.string}
                .joined(separator: "\n")
            
            completion(extractedText)
        }
        
        request.recognitionLevel = .accurate    // we can do .fast for the faster result, i am doing accurate
        request.usesLanguageCorrection = true   // auto correct
        
        do
        {
            try requestHandler.perform([request])
        }
        catch
        {
            print("Error recognizing the text: \(error.localizedDescription)")
        }
    }
}
