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
    @StateObject var homeManager: HomeViewManager = HomeViewManager()
    var body: some View {
        ZStack{
            ScrollView(.vertical) {
                        VStack(spacing: 10) {
                            
                            Text("Recommened Today")
                                .font(.title2)
                                .fontWeight(.bold)
                                .font(.system(size: 20, weight: .bold, design: .default))
                                .padding(.leading)
                            
                            ScrollView(.horizontal, showsIndicators: false) {  // Horizontal scrolling for HStack
                                HStack(spacing: 15) {
                                    ForEach(1...4, id: \.self) { index in
                                        ZStack{
                                            
                                            if let card = homeManager.getRecommendCard(index: index-1) {
                                                
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
                                                
                                                Text(card.mealTime)
                                                    .foregroundColor(.white)
                                                    .font(.headline)
                                                    .fontWeight(.bold)
                                                    .multilineTextAlignment(.center)
                                                    .offset(y: 65)
                                                
                                                Text(card.dishName)
                                                    .foregroundColor(.white)
                                                    .font(.headline)
                                                    .fontWeight(.bold)
                                                    .multilineTextAlignment(.center)
                                                    .offset(y: 85)
                                                
                                            }
                                            
                                            
                                        }
                                        
                                    }
                                }
                                .padding()
                            }
                            
                            Text("AI Insights")
                                .font(.title2)
                                .fontWeight(.bold)
                                .font(.system(size: 20, weight: .bold, design: .default))
                                .padding(.leading)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(1...10, id: \.self) { index in
                                        ZStack{
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color.black.opacity(0.1))
                                                .frame(width: 175, height: 200)
                                            
                                            if let card = homeManager.getInsightCard(index: index-1) {
                                                Text(card.message)
                                                    .foregroundColor(.black)
                                                    .font(.headline)
                                                    .multilineTextAlignment(.center)
                                                    .frame(width: 100)
                                            }
                                        }
                                        
                                    }
                                }
                                .padding()
                            }
                            
                            Text("Popular Dishes")
                                .font(.title2)
                                .fontWeight(.bold)
                                .font(.system(size: 20, weight: .bold, design: .default))
                                .padding(.leading)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(1...4, id: \.self) { index in
                                        ZStack{
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(Color.black.opacity(0.1))
                                                .frame(width: 175, height: 200)
                                            
                                            if let card = homeManager.getPopularCard(index: index-1){
                                               

                                                AsyncImage(url: URL(string: card.imageURL ?? "")) { phase in
                                                    if let image = phase.image {
                                                        image
                                                            .resizable()
                                                            .scaledToFill()
                                                            .frame(width: 175, height: 200)
                                                            .clipped()
                                                            .cornerRadius(10)
                                                    } else if phase.error != nil {
                                                        Image(systemName: "photo")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 50, height: 50)
                                                            .foregroundColor(.gray)
                                                    } else {
                                                        ProgressView()
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
                                                
                                                Text(card.dishName)
                                                    .foregroundColor(.white)
                                                    .font(.headline)
                                                    .fontWeight(.bold)
                                                    .multilineTextAlignment(.center)
                                                    .offset(y: 85)
                                            }
                                            
                                            
                                        }
                                        
                                    }
                                }
                                .padding()
                            }
                        }
                        
                        .padding()
                    }
                .frame(width:450 ,height: 700)
            
                TopBar()
                
                VStack{
                    
                }
                
                BottomBar()
                }
        
            
            
        }
        .navigationBarBackButtonHidden(true)
    }


#Preview {
    HomePage()
}
