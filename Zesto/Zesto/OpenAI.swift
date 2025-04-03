//
//  OpenAI.swift
//  Zesto
//
//  Created by Shaashvat Mittal on 3/16/25.
//

import Foundation
import Alamofire

// Response structures for OpenAI's Chat Completions API
struct OpenAIResponse: Decodable
{
    let choices: [OpenAIChoice]
}

struct OpenAIChoice: Decodable
{
    let message: OpenAIMessage
}

struct OpenAIMessage: Decodable
{
    let content: String
}

class OpenAI
{
    static let shared = OpenAI()
    
    private let apiKey = "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"
    
    // OpenAI's Chat Completions endpoint
    private let apiURL = "https://api.openai.com/v1/chat/completions"
    
    func processImage(_ text: String, completion: @escaping (String?) -> Void)
    {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(apiKey)",     // OpenAI auth key
            "Content-Type": "application/json"         // JSON format request
        ]
        
        // THIS IS IMPORTANT
        let parameters: [String: Any] = [
            "model": "gpt-3.5-turbo", // My model
            "messages": [
                [
                    "role": "system",
                    "content": """
                    You are a grocery receipt parser.

                    Your job is to extract a list of grocery items from raw receipt text and return them as a JSON array. Each object must include exactly three fields:
                    - 'name': full name of the item (expand any abbreviations or codes)
                    - 'quantity': number of units purchased (use 1 if not explicitly mentioned)
                    - 'price': the total price for that item (not per unit)

                    Only include food or kitchen-related grocery items.  
                    Exclude all non-food or non-cooking items such as clothing, electronics, tools, or household goods.

                    Strictly return **only** a JSON array. Do not add explanations or other text.
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
        
        // Make the API call using Alamofire
        AF.request(apiURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate() // Ensure a valid response
            .responseDecodable(of: OpenAIResponse.self) { response in
                switch response.result
                {
                    case .success(let value):
                        let fullResponse = value.choices.first?.message.content ?? "No structured data found."
                        completion(fullResponse)
                    
                    case .failure(let error):
                        print("OpenAI API error: ", error.localizedDescription)
                        completion("API request failed: \(error.localizedDescription)")
                }
            }
    }
}
