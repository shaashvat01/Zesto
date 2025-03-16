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
            "Content-Type": "application/json"       // JSON format request
        ]
        
        // IMPORTANT - TELLS MODEL WHAT TO DO
        let parameters: [String: Any] = [
            "model": "sonar-reasoning",
            "messages": [
                [
                    "role": "system",
                    "content": """
                    You are a text parser. 
                    Given a grocery receipt, you must output only a table with three columns: Name, Quantity, Price.
                    Do not include explanations or chain-of-thought. 
                    End your response immediately after providing the table in this format:

                    | Name | Quantity | Price |
                    |------|----------|-------|
                    | Example Item | 2 | 5.99 |
                    | Another Item | 1 | 3.49 |

                    Only output the table, nothing else.
                    """
                ],
                [
                    "role": "user",
                    "content": text
                ]
            ],
            "max_tokens": 1000,
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
