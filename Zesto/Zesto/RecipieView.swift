//
//  RecipieView.swift
//  Zesto
//
//  Created by Saisrivathsan Manikandan on 4/4/25.
//

import SwiftUI

struct RecipieView: View {
    let recipie: RecipeModel
    @EnvironmentObject var appState: AppState
    var body: some View {
        ScrollView {
            GeometryReader { geometry in
                let offset = geometry.frame(in: .global).minY
                let height = max(400 - offset, 200) // Min height as it scrolls up

                ZStack(alignment: .bottomLeading) {
                    AsyncImage(url: recipie.imageURL) { phase in
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

                    // Title over the image
                    Text(recipie.name.uppercased())
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(radius: 10)
                        .padding()
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(10)
                        .padding([.leading, .bottom], 16)
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
                    Button(action: {}) {
                        Image(systemName: "heart")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.red)
                    }
                    Button(action: {}) {
                        Image(systemName: "bookmark")
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
                    
                    ForEach(recipie.ingredients, id: \.self) { item in
                        Text("• \(item)")
                    }
                }

                // Instructions
                VStack(alignment: .leading, spacing: 6) {
                    Text("👨‍🍳 Instructions")
                        .font(.title2)
                        .fontWeight(.semibold)

                    ForEach(recipie.instructions.indices, id: \.self) { index in
                        Text("\(index + 1). \(recipie.instructions[index])")
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
        .ignoresSafeArea(edges: .top)
        .onAppear {
            appState.hideTopBar = true
        }
    }
}


//#Preview {
//    @State var sampleRecipe = RecipeModel(
//        name: "Spicy Arrabiata Penne",
//        ingredients: ["1 pound penne rigate", "1/4 cup olive oil", "3 cloves garlic"],
//        instructions: ["Boil pasta", "Make sauce", "Mix and serve", "Mix and serve", "Mix and serve", "Mix and serve", "Mix and serve", "Mix and serve", "Mix and serve", "Mix and serve", "Mix and serve", "Mix and serve", "Mix and serve", "Mix and serve", "Mix and serve"],
//        imageURL: URL(string: "https://www.themealdb.com/images/media/meals/ustsqw1468250014.jpg")!
//    )
//    
//    return RecipieView(recipie: $sampleRecipe)
//}
