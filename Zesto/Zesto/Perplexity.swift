//
//  Perplexity.swift
//  scan_test
//
//  Created by Shaashvat Mittal on 3/15/25.
//

import Foundation
import Alamofire // for API calls

struct PerplexityResponse: Decodable {
    let choices: [Choice]  // API sends back an array of choices
}

struct Choice: Decodable {
    let message: Message  // Each choice contains a message object
}

struct Message: Decodable {
    let content: String  // The final structured grocery data we need
}

class Perplexity {
    static let shared = Perplexity()
    
    private let apiKey = "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"
    
    private let apiURL = "https://api.perplexity.ai/chat/completions"
    
    func processImage(_ text: String, completion: @escaping (String?) -> Void) {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(apiKey)",     // auth key
            "Content-Type": "application/json"         // JSON format request
        ]
        
        // IMPORTANT - TELLS MODEL WHAT TO DO
        let parameters: [String: Any] = [
            "model": "sonar-reasoning",
            "messages": [
                [
                    "role": "system",
                    "content": "Analyze the given grocery receipt text and extract item details in a structured table format. Expand shorthand names into full product names where necessary. The output should be a table with exactly three columns:\n\n- Name: Full product name (expand shorthand if needed).\n- Quantity: Extract the quantity from the receipt, default to 1 if missing.\n- Price: Extract the price of each item.\n\n**Return output as structured text in this format:**\n\n| Name | Quantity | Price |\n|------|----------|--------|\n| Example Item | 2 | 5.99 |\n| Another Item | 1 | 3.49 |\n\n**Do not add explanations or extra text. Only return the formatted table.**"
                ],
                [
                    "role": "user",
                    "content": text
                ]
            ],
            "max_tokens": 2000,
            "temperature": 0.2,
            "top_p": 0.9
        ]
        
        AF.request(apiURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate() // ensure successful API call
            .responseDecodable(of: PerplexityResponse.self) { response in
                switch response.result {
                case .success(let value):
                    print("AI Response: ", value)
                    let fullResponse = value.choices.first?.message.content ?? "No structured data found."
                    // Post-process the full response to extract only the table lines
                    let cleanedTable = self.extractTable(from: fullResponse)
                    let finalOutput = cleanedTable.isEmpty ? fullResponse : cleanedTable
                    completion(finalOutput)
                    
                case .failure(let error):
                    print("AI error: ", error.localizedDescription)
                    completion("API request failed: \(error.localizedDescription)")
                }
            }
    }
    
    // Helper function to extract only the table from the text
    private func extractTable(from text: String) -> String {
        // Split the response into lines
        let lines = text.components(separatedBy: .newlines)
        var tableLines = [String]()
        
        // Use a simple heuristic: only include lines that start with "|" and contain at least two "|"
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedLine.hasPrefix("|") && trimmedLine.filter({ $0 == "|" }).count >= 2 {
                tableLines.append(trimmedLine)
            }
        }
        
        // Join the lines back together into a single string
        return tableLines.joined(separator: "\n")
    }
}
