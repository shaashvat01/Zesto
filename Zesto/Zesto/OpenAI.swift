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
    
    private let apiKey = ""
    
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
                    You are a text parser.
                    Given a grocery receipt, you must output only a table with three columns: Name, Quantity, Price.
                    Do not include explanations or chain-of-thought.
                    Also, expand the shorthand and write the full names of the items.
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
