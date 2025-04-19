//
//  MainView.swift
//  Zesto
//
//  Created by Saisrivathsan Manikandan on 4/2/25.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var userSession: UserSessionManager
    // Use the instance provided by ZestoApp
    @EnvironmentObject var inventoryViewModel: InventoryViewModel
    
    // Retrieve the ModelContext from the environment.
    @Environment(\.modelContext) var context
    
    @StateObject var homeViewModel = HomeViewManager()
    @StateObject var scanViewModel = ScanViewModel()
    
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
               
                
                // Chat view for appState.topID == 3:
                    else if appState.topID == 3 {
                        ChatView(inventoryViewModel: inventoryViewModel,
                                 userSession: userSession,
                                 context: context)
                        .environmentObject(appState)
                    }
                    else if appState.topID == 4{
                        ProfileView()
                    }
                    else if appState.topID == 5{
                        ProfileEditView()
                    }
                    else if appState.topID == 6 {
                        BookmarkView()
                    }
                    else if appState.topID == 7 {
                        LikeView()
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
        .environmentObject(InventoryViewModel())
        .environmentObject(UserRecipeManager())
}
