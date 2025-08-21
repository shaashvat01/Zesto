//
//  BookmarkView.swift
//  Zesto
//
//  Created by Saisrivathsan Manikandan on 4/16/25.
//

import SwiftUI

struct BookmarkView: View {
    @EnvironmentObject var userRecipe: UserRecipeManager
    @EnvironmentObject var appState: AppState
    @State private var selectedRecipe: RecipeModel?  // Added state to control navigation

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(userRecipe.bookmarks, id: \.id) { recipe in
                        Button {
                            selectedRecipe = recipe  // Set selected recipe on tap
                        } label: {
                            HStack(spacing: 12) {
                                AsyncImage(url: recipe.imageURL) { phase in
                                    if let image = phase.image {
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 80, height: 80)
                                            .clipped()
                                            .cornerRadius(10)
                                    } else if phase.error != nil {
                                        Color.red
                                            .frame(width: 80, height: 80)
                                            .cornerRadius(10)
                                    } else {
                                        ProgressView()
                                            .frame(width: 80, height: 80)
                                    }
                                }

                                Text(recipe.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)

                                Spacer()
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(15)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 3)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            .navigationTitle("Bookmarked Recipes")
            .navigationDestination(item: $selectedRecipe) { recipe in
                RecipieView(recipe: recipe)
            }
        }
        .onAppear {
            appState.topID = 6
        }
        
    }
}

#Preview {
    LikeView()
        .environmentObject(UserRecipeManager())
        .environmentObject(AppState())
}

