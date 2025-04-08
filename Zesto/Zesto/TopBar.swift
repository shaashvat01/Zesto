//
//  TopBar.swift
//  Zesto
//
//  Created by Saisrivathsan Manikandan on 3/14/25.
//

import SwiftUI

struct TopBar: View {
    @EnvironmentObject var appState: AppState
    var body: some View {
        if(!appState.hideTopBar){
            VStack{
                ZStack{
                    Rectangle()
                        .fill(Color.white)
                        .frame(height: 92)
                        .frame(maxWidth: .infinity)
                        //.shadow(radius: 2)
                    
                    HStack{
                        switch appState.topID {
                            case 0: //home id
                            Spacer()
                                Button {
                                    
                                } label: {
                                    Image(systemName: "line.3.horizontal")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.black)
                                }
                                .padding(.top, 40) //follow padding palcement for proper align
                                .padding(.horizontal, 20)
                            case 1: //scan id
                                Text("Profile")
                            
                        case 2: // Inventory view customization
                            HStack {
                                Text("Inventory")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 40)
                            
                            
                            default:
                                Text("")
                        }
                    }
   
                }
                .edgesIgnoringSafeArea(.all)
                //.ignoresSafeArea(.all)
            }
        }
        
        
    }
    
}

#Preview {
    TopBar()
        .environmentObject(AppState())
}
