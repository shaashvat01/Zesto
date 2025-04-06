//
//  OpenAI.swift
//  Zesto
//
//  Created by Shaashvat Mittal on 3/16/25.
//

import Foundation

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
    private let apiURL = "https://api.openai.com/v1/chat/completions"
    
    func processImage(_ text: String, completion: @escaping (String?) -> Void)
    {
        // 1. Construct the URL
        guard let url = URL(string: apiURL) else {
            completion("Invalid URL.")
            return
        }
        
        // 2. Create the URL request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // 3. Set the headers
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 4. Prepare the JSON body
        let parameters: [String: Any] = [
            "model": "gpt-3.5-turbo",
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
        
        // 5. Convert the parameters dictionary to JSON data
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            request.httpBody = jsonData
        } catch {
            completion("Failed to serialize JSON body: \(error.localizedDescription)")
            return
        }
        
        // 6. Create the data task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Check for networking errors
            if let error = error {
                completion("API request failed: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                completion("No data received from API.")
                return
            }
            
            // 7. Decode the JSON response
            do {
                let decodedResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
                let content = decodedResponse.choices.first?.message.content ?? "No structured data found."
                completion(content)
            } catch {
                completion("Failed to decode JSON response: \(error.localizedDescription)")
            }
        }
        
        // 8. Start the request
        task.resume()
    }
}
