//
//  BottomBar.swift
//  Zesto
//
//  Created by Saisrivathsan Manikandan on 3/14/25.
//

import SwiftUI

struct BottomBar: View {
    @Binding var menuID: Int
    var body: some View {
        VStack{
            ZStack{
                Rectangle()
                    .fill(Color.green.opacity(0.85))
                    .frame(width: 500, height: 75)
                
                Circle()
                    .fill(Color.white)
                    .shadow(radius: 10)
                    .frame(width: 50, height: 50)
                    .offset(y: -40)
                
                Button {
                    menuID = 0
                } label: {
                    Image(systemName: "house")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.black)
                }
                .offset(y: -40)
                
                HStack{
                    Spacer()
                    
                    Button {
                        menuID = 1
                    } label: {
                        Image(systemName: "document.viewfinder")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    Button {
                        menuID = 2
                    } label: {
                        Image(systemName: "pencil.and.list.clipboard")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.black)
                    }
                    Spacer()
                    Button {
                        menuID = 3
                    } label: {
                        Image(systemName: "ellipsis.message")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.black)
                    }
                    Spacer()
                    Button {
                        menuID = 4
                    } label: {
                        Image(systemName: "person.3")
                            .resizable()
                            .frame(width: 35, height: 30)
                            .foregroundColor(.black)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                
                
            }
            
        }
        .ignoresSafeArea(.all)
        
        
    }
    
}

#Preview {
    BottomBar(menuID: .constant(0))
}
