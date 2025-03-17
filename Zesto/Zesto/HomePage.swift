//
//  HomePage.swift
//  Zesto
//
//  Created by Saisrivathsan Manikandan on 3/14/25.
//

import SwiftUI

struct HomePage: View {
    var body: some View {
        NavigationStack
        {
            VStack{
                TopBar()
                
                VStack{
                    
                }
                
                BottomBar()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    HomePage()
}
