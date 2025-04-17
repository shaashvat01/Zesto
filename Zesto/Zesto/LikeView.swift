//
//  LikeView.swift
//  Zesto
//
//  Created by Saisrivathsan Manikandan on 4/16/25.
//

import SwiftUI



struct LikeView: View {
    @EnvironmentObject var userRecipe: UserRecipeManager

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(userRecipe.likes, id: \.id) { recipe in
                        NavigationLink(destination: RecipieView(recipe: recipe)) {
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
            .navigationTitle("Liked Recipes")
        }
    }
}

#Preview {
    LikeView()
        .environmentObject(UserRecipeManager())
}
