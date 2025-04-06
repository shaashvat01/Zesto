//
//  TopBar.swift
//  Zesto
//
//  Created by Saisrivathsan Manikandan on 3/14/25.
//

import SwiftUI

struct TopBar: View {
    var body: some View {
        VStack{
            ZStack{
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 500, height: 92)
                    .shadow(radius: 2)
                
                
                Button {
                    
                } label: {
                    Image(systemName: "line.3.horizontal")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.black)
                }
                .offset(x: 160, y: 20)

                
            }
            .ignoresSafeArea(.all)
        }
        
    }
    
}

#Preview {
    TopBar()
}
