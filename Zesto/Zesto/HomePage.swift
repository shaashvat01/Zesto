//
//  HomePage.swift
//  Zesto
//
//  Created by Saisrivathsan Manikandan on 3/14/25.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct HomePage: View {
    @ObservedObject var homeManager: HomeViewManager
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack
        {
            GeometryReader{ geometry in
                NavigationView{
                    ScrollView(.vertical) {
                        VStack(spacing: 10) {
                            
                            Text("Recommened Today")
                                .font(.title2)
                                .fontWeight(.bold)
                                .font(.system(size: 20, weight: .bold, design: .default))
                                .padding(.leading)
                            
                            ScrollView(.horizontal, showsIndicators: false) {  // Horizontal scrolling for HStack
                                RecommendedCards(homeManager: homeManager)
                            }
                            
                            Text("AI Insights")
                                .font(.title2)
                                .fontWeight(.bold)
                                .font(.system(size: 20, weight: .bold, design: .default))
                                .padding(.leading)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(1...4, id: \.self) { index in
                                        ZStack{
                                            if let card = homeManager.getInsightCard(index: index-1) {
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(
                                                        LinearGradient(
                                                            gradient: Gradient(colors: [card.Color.opacity(0.2), card.Color.opacity(0.05)]),
                                                            startPoint: .bottom,
                                                            endPoint: .top
                                                        ))
                                                    .frame(width: 175, height: 200)
                                                
                                                Text(card.message)
                                                    .foregroundColor(.black)
                                                    .font(.headline)
                                                    .multilineTextAlignment(.center)
                                                    .frame(width: 100)
                                            }
                                        }
                                        
                                    }
                                }
                            }
                            
                            Text("Popular Dishes")
                                .font(.title2)
                                .fontWeight(.bold)
                                .font(.system(size: 20, weight: .bold, design: .default))
                                .padding(.leading)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                PopularCards(homeManager: homeManager)
                            }
                            
                        }
                        .padding()
                        .frame(width: geometry.size.width)
                        .frame(maxHeight: .infinity)
                        
                    }
                    .frame(maxHeight: .infinity)
                    //.frame(maxWidth: .infinity, maxHeight: .infinity)
                    .frame(width: geometry.size.width)
                }
                
                
            }
        }
        .onAppear {
                appState.hideTopBar = false // ✅ Ensures TopBar is shown on HomePage
            }
        
    }
        
}

struct RecommendedCards: View {
    @ObservedObject var homeManager: HomeViewManager
    var body: some View {
        HStack(spacing: 15) {
            ForEach(1...4, id: \.self) { index in
                ZStack{
                    
                    if let card = homeManager.getRecommendCard(index: index-1) {
                        if let recipe = card.RecipeModel {
                            NavigationLink(destination: RecipieView(recipie: recipe)){
                                
                                if let cachedImage = card.cachedImage{
                                    cachedImage
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 175, height: 200)
                                        .clipped()
                                        .cornerRadius(10)
                                }
                                else{
                                    AsyncImage(url: URL(string: card.imageURL ?? "")) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                                .frame(width: 175, height: 200)
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 175, height: 200)
                                                .clipped()
                                                .cornerRadius(10)
                                        case .failure:
                                            Image(systemName: "photo")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 50, height: 50)
                                                .foregroundColor(.gray)
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                }
                                
                                
                                
                            }
                        }
                        
                        
                        
                        
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.black.opacity(1), Color.clear]),
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .frame(width: 175, height: 50)
                            .offset(y: 75)
                        
                        VStack{
                            Spacer()
                            Text(card.mealTime)
                                .foregroundColor(.white)
                                .font(.headline)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                                //.offset(y: 65)
                            
                            Text(card.dishName)
                                .foregroundColor(.white)
                                .font(.headline)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                                //.offset(y: 85)
                                
                        }
                        
                        .frame(width: 175)
                    }

                }
            }
        }
    }
}

struct PopularCards: View {
    @ObservedObject var homeManager: HomeViewManager
    var body: some View {
        HStack(spacing: 15) {
            ForEach(1...4, id: \.self) { index in
                ZStack{
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.1))
                        .frame(width: 175, height: 200)
                    
                    if let card = homeManager.getPopularCard(index: index-1){
                        
                        if let recipe = card.RecipeModel {
                            NavigationLink(destination: RecipieView(recipie: recipe)){
                                
                                if let cachedImage = card.cachedImage{
                                    cachedImage
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 175, height: 200)
                                        .clipped()
                                        .cornerRadius(10)
                                }
                                else{
                                    AsyncImage(url: URL(string: card.imageURL ?? "")) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                                .frame(width: 175, height: 200)
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 175, height: 200)
                                                .clipped()
                                                .cornerRadius(10)
                                            
                                        case .failure:
                                            Image(systemName: "photo")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 50, height: 50)
                                                .foregroundColor(.gray)
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }

                                }
                                
                                
                            }
                        }
                    
                        
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.black.opacity(1), Color.clear]),
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .frame(width: 175, height: 50)
                            .offset(y: 75)
                        
                        VStack{
                            Spacer()
                            
                            Text(card.dishName)
                                .foregroundColor(.white)
                                .font(.headline)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                        }
                        .frame(width: 175)
                        
                    }
                    
                    
                }
                
            }
        }
    }
}

#Preview {
    HomePage(homeManager: HomeViewManager())
        .environmentObject(AppState())
}
