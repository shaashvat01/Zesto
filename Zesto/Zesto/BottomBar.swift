//
//  BottomBar.swift
//  Zesto
//
//  Created by Saisrivathsan Manikandan on 3/14/25.
//

import SwiftUI

struct BottomBar: View {
    var body: some View {
        VStack{
            Spacer()
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
                    
                } label: {
                    Image(systemName: "house")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.black)
                }
                .offset(y: -40)
                
                HStack{
                    Spacer()
                    NavigationLink(destination: ScanView()) {
                        Image(systemName: "document.viewfinder")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.black)
                    }
                    Spacer()
                    Button {
                        
                    } label: {
                        Image(systemName: "pencil.and.list.clipboard")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.black)
                    }
                    Spacer()
                    Button {
                        
                    } label: {
                        Image(systemName: "ellipsis.message")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.black)
                    }
                    Spacer()
                    Button {
                        
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
    BottomBar()
}
