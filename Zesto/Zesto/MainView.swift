//
//  MainView.swift
//  Zesto
//
//  Created by Saisrivathsan Manikandan on 4/2/25.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var appState: AppState
    @State var menuID: Int = 0
    @StateObject var homeViewModel =  HomeViewManager()
    
    // Our single scanViewModel
    @StateObject var scanViewModel = ScanViewModel()
    
    @StateObject var inventoryViewModel = InventoryViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            
            
            if menuID == 0 {
                TopBar(topID: $menuID)
                Spacer()
                HomePage(homeManager: homeViewModel)
            }
            else if menuID == 1 {
                TopBar(topID: $menuID)
                Spacer()
                ScanView(viewModel: scanViewModel, inventoryVM: inventoryViewModel)
            }
            else if menuID == 2{
                TopBar(topID: $menuID)
                Spacer()
                InventoryView(viewModel: inventoryViewModel)
            }
            
            Spacer()
            BottomBar(menuID: $menuID)
        }
        .ignoresSafeArea(.all)
    }
}



#Preview {
    MainView()
        .environmentObject(AppState())
}
