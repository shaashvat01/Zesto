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

struct ChatMessage: Identifiable, Codable
{
    let id = UUID()
    let role: MessageRole
    let text: String
}

class ChatViewModel: ObservableObject
{
    @Published var messages: [ChatMessage] = []
    @Published var inputText: String = ""
    
    private var inventoryViewModel: InventoryViewModel
    private var userSession: UserSessionManager
    private var context: ModelContext  // from swift data
    
    private var cancellables = Set<AnyCancellable>()
    
    init(inventoryViewModel: InventoryViewModel, userSession: UserSessionManager, context: ModelContext)
    {
        self.inventoryViewModel = inventoryViewModel
        self.userSession = userSession
        self.context = context
        
        inventoryViewModel.fetchAllItems(context: context)
        
        updateSystemContext()
        
        inventoryViewModel.$allItems
            .receive(on: DispatchQueue.main)
            .sink
        {
            [weak self] _ in
                self?.updateSystemContext()
        }
        .store(in: &cancellables)
        
        userSession.$userModel
            .receive(on: DispatchQueue.main)
            .sink
        {
            [weak self] _ in
                self?.updateSystemContext()
        }
        .store(in: &cancellables)
    }
    
    func updateSystemContext()
    {
        let items = inventoryViewModel.allItems
        let inventoryItemsDescription = items.isEmpty ? "No items" : items.map { "\($0.name) (\($0.quantity))" }.joined(separator: ", ")
        
        let dietaryRestrictionsDescription: String = {
            if let restrictions = userSession.userModel?.dietaryPreferences, !restrictions.isEmpty
            {
                return restrictions.joined(separator: ", ")
            }
            return "None"
        }()
        
        
        // IMPORTANT
        let systemPrompt = """
        You are a recipe suggestion assistant. User Inventory: \(inventoryItemsDescription). 
        Dietary Restrictions: \(dietaryRestrictionsDescription). 
        When suggesting recipes, only use these items and respect the dietary restrictions.
        """
        
        let systemMessage = ChatMessage(role: .system, text: systemPrompt)
        
        if let first = messages.first, first.role == .system
        {
            messages[0] = systemMessage
        }
        else
        {
            messages.insert(systemMessage, at: 0)
        }
    }
    
    func sendMessage()
    {
        let trimmedText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        let userMessage = ChatMessage(role: .user, text: trimmedText)
        messages.append(userMessage)
        
        inputText = ""
        
        ChatAPIService.shared.sendMessage(messages: messages) { [weak self] result in
            DispatchQueue.main.async
            {
                switch result
                {
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
