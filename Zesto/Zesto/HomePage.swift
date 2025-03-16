//
//  HomePage.swift
//  Zesto
//
//  Created by Saisrivathsan Manikandan on 3/14/25.
//

import SwiftUI

struct HomePage: View {
    var body: some View {
        NavigationView
        {
            VStack{
                TopBar()
                
                VStack{
                    
                }
                
                BottomBar()
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    HomePage()
}
