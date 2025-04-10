//
//  TopBar.swift
//  Zesto
//
//  Created by Saisrivathsan Manikandan on 3/14/25.
//

import SwiftUI

struct TopBar: View {
    @EnvironmentObject var appState: AppState
    @Binding var showMenu: Bool
    
    var body: some View {
        if !appState.hideTopBar {
            VStack {
                ZStack {
                    Rectangle()
                        .fill(Color.white)
                        .frame(height: 92)
                        .frame(maxWidth: .infinity)
                        .shadow(radius: 2)
                    
                    HStack {
                        switch appState.topID {
                        case 0: // Home
                            Spacer()
                            Button {
                                withAnimation {
                                    showMenu.toggle()
                                }
                            } label: {
                                Image(systemName: "line.3.horizontal")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.black)
                            }
                            .padding(.top, 40)
                            .padding(.horizontal, 20)
                        case 1:
                            Text("Profile")
                        default:
                            Text("")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    TopBar(showMenu: .constant(true))
        .environmentObject(AppState())
}
