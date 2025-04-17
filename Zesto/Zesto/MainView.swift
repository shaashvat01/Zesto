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
    @State private var showMenu: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack{
                VStack(spacing: 0) {
                    TopBar(showMenu: $showMenu)
                    Spacer()
                    
                    if appState.topID == 0 {
                        ZStack{
                            HomePage(homeManager: homeViewModel)
                            if showMenu {
                                SlideInMenu(showMenu: $showMenu)
                                    .transition(.move(edge: .trailing))
                                    .zIndex(1)
                            }
                        }
                        
                    }
                    else if appState.topID == 1 {
                        ScanView(viewModel: scanViewModel, inventoryVM: inventoryViewModel)
                    }
                    else if appState.topID == 2{
                        InventoryView(viewModel: inventoryViewModel)
                    }
                    else if appState.topID == 4{
                        ProfileView()
                    }
                    else if appState.topID == 5{
                        ProfileEditView()
                    }
                    
                    Spacer()
                    BottomBar()
                    
                    
                }
                
                
                
                
                
            }
            .animation(.easeInOut, value: showMenu)
            .edgesIgnoringSafeArea(.all)
        }
        
    }
}




#Preview {
    MainView()
        .environmentObject(AppState())
        .environmentObject(UserSessionManager())
        .environmentObject(UserRecipeManager())
}
