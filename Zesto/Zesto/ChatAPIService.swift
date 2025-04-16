//
//  ChatAPIService.swift
//  Zesto
//
//  Created by Shaashvat Mittal on 4/14/25.
//

import Foundation

struct ChatAPIResponse: Decodable
{
    let choices: [ChatAPIChoice]
}

struct ChatAPIChoice: Decodable
{
    let message: ChatAPIMessage
}

struct ChatAPIMessage: Decodable
{
    let content: String
}

class ChatAPIService {
    static let shared = ChatAPIService()
    
    private let apiKey: String = {
            guard
                // 1) Find the file
                let path = Bundle.main.path(forResource: "secrets", ofType: "plist"),
                // 2) Load the file’s contents as a dictionary
                let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
                // 3) Extract the “API_KEY” value
                let key = dict["OpenAI_API"] as? String
            else {
                fatalError("API_KEY not found in Secrets.plist")
            }
            return key
    }()

    private let apiURL = "https://api.openai.com/v1/chat/completions"
    
    // Sends the given conversation messages to the OpenAI Chat API and returns the reply.
    func sendMessage(messages: [ChatMessage], completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: apiURL) else {
            completion(.failure(NSError(domain:"Invalid URL", code: 0)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Set headers
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Convert the ChatMessage array to the expected dictionary format.
        let messagesToSend = messages.map { ["role": $0.role.rawValue, "content": $0.text] }
        
        // Build the request body.
        let body: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": messagesToSend,
            "temperature": 0.2
        ]
        
        do {
            let data = try JSONSerialization.data(withJSONObject: body, options: [])
            request.httpBody = data
        } catch {
            completion(.failure(error))
            return
        }
        
        // Create the data task for the API call.
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain:"No data", code: 0)))
                return
            }
            do {
                let decodedResponse = try JSONDecoder().decode(ChatAPIResponse.self, from: data)
                if let reply = decodedResponse.choices.first?.message.content {
                    completion(.success(reply))
                } else {
                    completion(.failure(NSError(domain: "No reply", code: 0)))
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
