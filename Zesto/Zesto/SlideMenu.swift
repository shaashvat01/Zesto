//
//  SlideMenu.swift
//  Zesto
//
//  Created by Saisrivathsan Manikandan on 4/7/25.
//

import SwiftUI
import FirebaseAuth
struct SlideInMenu: View {
    @Binding var showMenu: Bool
    @EnvironmentObject var UserSession: UserSessionManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Spacer()
                Button(action: {
                    withAnimation {
                        showMenu = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.gray)
                }
            }
            
            Text("User Profile")
                .font(.title)
                .bold()
            
            Divider()
            
            Button(action: {}) {
                Label("Settings", systemImage: "gear")
            }
            
            Button(action: {
                UserSession.logout()
            }) {
                Label("Log Out", systemImage: "arrowshape.turn.up.left")
            }
            
            Spacer()
        }
        .padding()
        .frame(width: UIScreen.main.bounds.width * 0.7)
        .background(.white)
        .cornerRadius(20)
        .shadow(radius: 5)
        .offset(x: showMenu ? 0 : UIScreen.main.bounds.width)
        .animation(.easeInOut, value: showMenu)
    }
}
