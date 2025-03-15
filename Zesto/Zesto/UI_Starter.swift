//
//  UI_Template.swift
//  Zesto
//
//  Created by Saisrivathsan Manikandan on 3/14/25.
//

import SwiftUI

struct UI_Starter: View {
    var body: some View {
        VStack{
            ZStack{
                Rectangle()
                    .fill(Color.green)
                    .frame(width: 500, height: 100)
                
                Image("LOGO")
                    .resizable()
                    .frame(width: 150, height: 60)
                    .offset(x: -110, y: 20)
                
                
                Button {
                    
                } label: {
                    Image("MenuBar")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
                .offset(x: 170, y: 30)

                
            }
            
            
            Spacer()
            
            VStack{
                Text("Hello, from template!")
            }
            
            
            Spacer()
            
            ZStack{
                Rectangle()
                    .fill(Color.green)
                    .frame(width: 500, height: 75)
                
                Circle()
                    .fill(Color.white)
                    .shadow(radius: 10)
                    .frame(width: 50, height: 50)
                    .offset(y: -40)
                
                Button {
                    
                } label: {
                    Image("Home")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
                .offset(y: -40)
                
                Button {
                    
                } label: {
                    Image("Scan")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
                .offset(x: -130)
                
                Button {
                    
                } label: {
                    Image("Fridge")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
                .offset(x: -40)
                
                Button {
                    
                } label: {
                    Image("Chat")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
                .offset(x: 40)
                
                Button {
                    
                } label: {
                    Image("Community")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
                .offset(x: 130)
            }
            
        }
        .ignoresSafeArea(.all)
        
        
        
    }
}

#Preview {
    UI_Starter()
}

