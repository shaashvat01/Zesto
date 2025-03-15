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
            .ignoresSafeArea(.all)
            Spacer()
        }
        
    }
    
}

#Preview {
    TopBar()
}
