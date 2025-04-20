//
//  RecipieView.swift
//  Zesto
//
//  Created by Saisrivathsan Manikandan on 4/4/25.
//

import SwiftUI

struct RecipieView: View {
    let recipe: RecipeModel
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var userRecipe: UserRecipeManager
    
    var body: some View {
            ScrollView {
                GeometryReader { geometry in
                    let offset = geometry.frame(in: .global).minY
                    let height = max(400 - offset, 200) // Min height as it scrolls up
                    
                    
                    ZStack(alignment: .bottomLeading) {
                        AsyncImage(url: recipe.imageURL) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: geometry.size.width, height: height)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: geometry.size.width, height: height)
                                    .clipped()
                            case .failure:
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 90, height: 90)
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        VStack{
                            HStack{
                                Button(action: {
                                    print("Back button tapped!")
                                    appState.hideTopBar = false
                                    appState.hideBottomBar = false
                                    
                                    presentationMode.wrappedValue.dismiss()
                                    
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "arrow.left.circle.fill")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(.white)
                                    }
                                    .padding(.top, 40)
                                    .padding(.horizontal, 30)
                                    
                                }
                                
                                Spacer()
                            }
                            
                            
                            Spacer()
                            // Title over the image
                            Text(recipe.name.uppercased())
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .shadow(radius: 10)
                                .padding()
                                .background(Color.black.opacity(0.3))
                                .cornerRadius(10)
                                .padding([.leading, .bottom], 16)
                        }
                        
                    }
                    .frame(height: height)
                }
                .frame(height: 400)
                
                VStack(alignment: .leading, spacing: 16) {
                    // Chips
                    HStack {
                        Label("Nut Free", systemImage: "leaf")
                            .padding(8)
                            .background(Color.purple.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        Label("American", systemImage: "flag")
                            .padding(8)
                            .background(Color.blue.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        Label("Dinner", systemImage: "fork.knife")
                            .padding(8)
                            .background(Color.yellow.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    // Buttons
                    HStack(spacing: 16) {
                        Button(action: {
                            if userRecipe.isRecipeLiked(recipe){
                                userRecipe.removeLike(recipe)
                            }
                            else{
                                userRecipe.addLike(recipe)
                            }
                            
                        }) {
                            Image(systemName: userRecipe.isRecipeLiked(recipe) ? "heart.fill" : "heart")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.red)
                        }
                        Button(action: {
                            if userRecipe.isRecipeBookmarked(recipe){
                                userRecipe.removeBookmark(recipe)
                            }
                            else{
                                userRecipe.addBookmark(recipe)
                            }
                            
                        }) {
                            Image(systemName: userRecipe.isRecipeBookmarked(recipe) ? "bookmark.fill" : "bookmark")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    // Ingredients
                    VStack(alignment: .leading, spacing: 6) {
                        Text("🧂 Ingredients")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        ForEach(recipe.ingredients, id: \.self) { item in
                            Text("• \(item)")
                        }
                    }
                    
                    // Instructions
                    VStack(alignment: .leading, spacing: 6) {
                        Text("👨‍🍳 Instructions")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        ForEach(recipe.instructions.indices, id: \.self) { index in
                            Text("\(index + 1). \(recipe.instructions[index])")
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(1))
                        .shadow(radius: 10)
                )
                .padding(.top, -20) // Pull content closer to image
                
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            .ignoresSafeArea(edges: .top)
            .onAppear {
                appState.hideTopBar = true
                appState.hideBottomBar = true
            }
        
        
    }
}

