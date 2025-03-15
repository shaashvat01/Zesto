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
                    .frame(width: 500, height: 92)
                
                Text("Zesto")
                    .font(.system(size: 40, weight: .bold, design: .default))
                    .offset(x: -120, y: 20)
                
                
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
            Spacer()
        }
        
    }
    
}

#Preview {
    TopBar()
}
