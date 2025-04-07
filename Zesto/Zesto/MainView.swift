//
//  MainView.swift
//  Zesto
//
//  Created by Saisrivathsan Manikandan on 4/2/25.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var appState: AppState
    @StateObject var homeViewModel =  HomeViewManager()
    
    // Our single scanViewModel
    @StateObject var scanViewModel = ScanViewModel()
    
    @StateObject var inventoryViewModel = InventoryViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            TopBar()
            Spacer()
            
            if appState.topID == 0 {
                HomePage(homeManager: homeViewModel)
                
            }
            else if appState.topID == 1 {
                ScanView(viewModel: scanViewModel, inventoryVM: inventoryViewModel)
            }
            else if appState.topID == 2{
                InventoryView(viewModel: inventoryViewModel)
            }
            
            Spacer()
            BottomBar()
        }
        .ignoresSafeArea(.all)
    }
}



#Preview {
    MainView()
        .environmentObject(AppState())
}
