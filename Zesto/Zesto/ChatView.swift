//
//  ChatView.swift
//  Zesto
//
//  Created by Shaashvat Mittal on 4/14/25.
//

import SwiftUI
import SwiftData


struct ChatView: View {
    // These dependencies are injected.
    var inventoryViewModel: InventoryViewModel
    var userSession: UserSessionManager
    var context: ModelContext  // Must be passed in from a parent view which has access to the environment
    
    @StateObject private var viewModel: ChatViewModel
    
    // Custom initializer now requires ModelContext.
    init(inventoryViewModel: InventoryViewModel,
         userSession: UserSessionManager,
         context: ModelContext) {
        self.inventoryViewModel = inventoryViewModel
        self.userSession = userSession
        self.context = context
        _viewModel = StateObject(
            wrappedValue: ChatViewModel(inventoryViewModel: inventoryViewModel,
                                        userSession: userSession,
                                        context: context)
        )
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            ChatBubble(message: message)
                        }
                    }
                    .padding()
                }
                .background(Color(UIColor.systemGroupedBackground))
                
                Divider()
                
                HStack {
                    TextField("Type your message...", text: $viewModel.inputText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(minHeight: 44)
                    
                    Button(action: {
                        viewModel.sendMessage()
                    }) {
                        Text("Send")
                            .bold()
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle("Chat")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ChatBubble: View {
    var message: ChatMessage
    var body: some View {
        HStack {
            if message.role == .assistant {
                Text(message.text)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else if message.role == .user {
                Text(message.text)
                    .padding()
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(10)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            } else {  // system message
                Text(message.text)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
}





