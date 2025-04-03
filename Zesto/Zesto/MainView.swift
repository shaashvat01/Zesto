//
//  MainView.swift
//  Zesto
//
//  Created by Saisrivathsan Manikandan on 4/2/25.
//

import SwiftUI

struct MainView: View {
    @State var menuID: Int = 0;
    @StateObject var homeViewModel: HomeViewManager = HomeViewManager()
    var body: some View {
        VStack(spacing: 0){
            TopBar()
            
            Spacer()
            
            if(menuID == 0){
                HomePage(homeManager: homeViewModel)
            }
            else if(menuID == 1){
                ScanView()
            }
            
            
            Spacer()
            
            BottomBar(menuID: $menuID)
        }
        .ignoresSafeArea(.all)
        
        
        
    }
}

#Preview {
    MainView()
}
