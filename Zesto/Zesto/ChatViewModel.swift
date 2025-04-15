//
//  ChatViewModel.swift
//  Zesto
//
//  Created by Shaashvat Mittal on 4/14/25.
//

import Foundation
import SwiftUI
import Combine
import SwiftData

enum MessageRole: String, Codable {
    case user, assistant, system
}

struct ChatMessage: Identifiable, Codable {
    let id = UUID()
    let role: MessageRole
    let text: String
}

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText: String = ""
    
    // Dependencies provided via initialization.
    private var inventoryViewModel: InventoryViewModel
    private var userSession: UserSessionManager
    private var context: ModelContext  // Injected ModelContext from SwiftData
    
    // Combine cancellables for subscriptions.
    private var cancellables = Set<AnyCancellable>()
    
    init(inventoryViewModel: InventoryViewModel,
         userSession: UserSessionManager,
         context: ModelContext) {
        self.inventoryViewModel = inventoryViewModel
        self.userSession = userSession
        self.context = context
        
        // Fetch the latest inventory data from SwiftData.
        inventoryViewModel.fetchAllItems(context: context)
        
        // Set initial system context.
        updateSystemContext()
        
        // Subscribe to changes in inventory so that system context updates automatically.
        inventoryViewModel.$allItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateSystemContext()
            }
            .store(in: &cancellables)
        
        // Subscribe to changes in user profile data.
        userSession.$userModel
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateSystemContext()
            }
            .store(in: &cancellables)
    }
    
    /// Updates (or replaces) the system message with the current context.
    func updateSystemContext() {
        // Build an inventory description that shows each item's name and quantity.
        let items = inventoryViewModel.allItems
        let inventoryItemsDescription = items.isEmpty
            ? "No items"
            : items.map { "\($0.name) (\($0.quantity))" }.joined(separator: ", ")
        
        // Build the dietary restrictions description.
        let dietaryRestrictionsDescription: String = {
            if let restrictions = userSession.userModel?.dietaryPreferences, !restrictions.isEmpty {
                return restrictions.joined(separator: ", ")
            }
            return "None"
        }()
        
        // Include the role instruction together with the dynamic data.
        let systemPrompt = """
        You are a recipe suggestion assistant. User Inventory: \(inventoryItemsDescription). 
        Dietary Restrictions: \(dietaryRestrictionsDescription). 
        When suggesting recipes, only use these items and respect the dietary restrictions.
        """
        
        let systemMessage = ChatMessage(role: .system, text: systemPrompt)
        
        // Ensure the very first message is the system message.
        if let first = messages.first, first.role == .system {
            messages[0] = systemMessage
        } else {
            messages.insert(systemMessage, at: 0)
        }
    }
    
    /// Sends the user's message and calls the Chat API Service.
    func sendMessage() {
        let trimmedText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        // Append the user's message.
        let userMessage = ChatMessage(role: .user, text: trimmedText)
        messages.append(userMessage)
        
        // Clear the input field.
        inputText = ""
        
        // Call the API with the complete conversation (which includes the current system context).
        ChatAPIService.shared.sendMessage(messages: messages) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let reply):
                    let assistantMessage = ChatMessage(role: .assistant, text: reply)
                    self?.messages.append(assistantMessage)
                case .failure(let error):
                    let errorMessage = ChatMessage(role: .assistant, text: "Error: \(error.localizedDescription)")
                    self?.messages.append(errorMessage)
                }
            }
        }
    }
}
