//
//  StartUpView.swift
//  Zesto
//
//  Created by Saisrivathsan Manikandan on 4/8/25.
//

import SwiftUI


public struct StartUpView: View {
    public var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [.green.opacity(0.3), .mint.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                Text("Zesto")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                    .padding(.top, 20)
                
                Text("Welcome to Zesto")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.black)

                
                Button(action: {
                    
                }) {
                    Text("Login")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(gradient: Gradient(colors: [.green, .mint]),
                                           startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(14)
                }
                .shadow(radius: 5)
                
                Button(action: {
                    
                }) {
                    Text("Sign Up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(gradient: Gradient(colors: [.green, .mint]),
                                           startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(14)
                }
                .shadow(radius: 5)
            }
            .padding(30)
            .background(.ultraThinMaterial)
            .cornerRadius(25)
            .shadow(radius: 10)
            .padding(.horizontal, 20)
            
        }
    }
}

#Preview {
    StartUpView()
}
