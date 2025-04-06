//
//  RecipieView.swift
//  Zesto
//
//  Created by Saisrivathsan Manikandan on 4/4/25.
//

import SwiftUI

struct RecipieView: View {
    @Binding var recipie: RecipeModel

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Background Image
                AsyncImage(url: recipie.imageURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: geometry.size.width, height: 400)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: 400)
                            .frame(maxWidth: .infinity)
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

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Spacer().frame(height: 320)

                        VStack(alignment: .leading, spacing: 12) {
                            Text(recipie.name.uppercased())
                                .font(.title)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.leading)
                                .padding(.top)

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

                            VStack(alignment: .leading, spacing: 6) {
                                Text("🧂 Ingredients")
                                    .font(.title2)
                                    .fontWeight(.semibold)

                                ForEach(recipie.ingredients, id: \..self) { item in
                                    Text("• \(item)")
                                }
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text("👨‍🍳 Instructions")
                                    .font(.title2)
                                    .fontWeight(.semibold)

                                ForEach(recipie.instructions.indices, id: \..self) { index in
                                    Text("\(index + 1). \(recipie.instructions[index])")
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                        .padding()
//                        .background(
//                            RoundedRectangle(cornerRadius: 20)
//                                .fill(Color.white.opacity(0.9))
//                                .shadow(radius: 10)
//                        )
                    }
                }
            }
            .ignoresSafeArea(.all, edges: .top)
        }
    }
}
#Preview {
    @State var sampleRecipe = RecipeModel(
        name: "Spicy Arrabiata Penne",
        ingredients: ["1 pound penne rigate", "1/4 cup olive oil", "3 cloves garlic"],
        instructions: ["Boil pasta", "Make sauce", "Mix and serve"],
        imageURL: URL(string: "https://www.themealdb.com/images/media/meals/ustsqw1468250014.jpg")!
    )
    
    return RecipieView(recipie: $sampleRecipe)
}
