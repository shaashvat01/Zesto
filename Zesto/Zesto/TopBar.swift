//
//  TopBar.swift
//  Zesto
//
//  Created by Saisrivathsan Manikandan on 3/14/25.
//

import SwiftUI

struct TopBar: View {
    @EnvironmentObject var appState: AppState
    @State private var showShoppingList = false

    var body: some View {
        if !appState.hideTopBar {
            VStack {
                ZStack {
                    Rectangle()
                        .fill(Color.white)
                        .frame(height: 92)
                        .frame(maxWidth: .infinity)
                    
                    HStack {
                        switch appState.topID {
                        case 0: // Home
                            Spacer()
                            Button {
                                // Add action if needed.
                            } label: {
                                Image(systemName: "line.3.horizontal")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.black)
                            }
                            .padding(.top, 40)
                            .padding(.horizontal, 20)
                            
                        case 1: // Scan view
                            Text("Profile")
                            
                        case 2: // Inventory view
                            HStack {
                                Text("Inventory")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                // Shopping list icon
                                Button(action: {
                                    showShoppingList = true
                                }) {
                                    Image(systemName: "cart")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.black)
                                }
                                .padding(.trailing, 8)
                                
                                // Map icon stub
                                Button(action: {
                                    print("Map icon tapped")
                                }) {
                                    Image(systemName: "map")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.black)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 40)
                        default:
                            Text("")
                        }
                    }
                }
                .edgesIgnoringSafeArea(.all)
            }
            // Present the shopping list full screen from TopBar.
            .fullScreenCover(isPresented: $showShoppingList) {
                ShoppingListView()
            }
        }
    }
}

#Preview {
    TopBar()
        .environmentObject(AppState())
}
