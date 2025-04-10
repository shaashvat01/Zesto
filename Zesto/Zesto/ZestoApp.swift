//
//  ZestoApp.swift
//  Zesto
//
//  Created by Shaashvat Mittal on 3/9/25.
//

import SwiftUI
import Firebase
import FirebaseFirestore

class AppState: ObservableObject {
    @Published var path = NavigationPath()
    @Published var hideTopBar: Bool = false
    @Published var topID: Int = 0
    @Published var hideBottomBar: Bool = false
}

@main
struct ZestoApp: App {
    init() {
        FirebaseApp.configure()
    }

    @StateObject var appState = AppState()
    @StateObject var userSession = UserSessionManager()

    var body: some Scene {
        WindowGroup {
            if userSession.isLoggedIn {
                switch userSession.setupStatus {
                case .unknown:
                    ZStack {
                        Color(.systemBackground).ignoresSafeArea()
                        ProgressView("Loading...")
                    }

                case .complete:
                    MainView()
                        .modelContainer(for: [InventoryItem.self, ShoppingListItem.self])
                        .environmentObject(appState)
                        .environmentObject(userSession)

                case .incomplete:
                    ProfileSetupView()
                        .environmentObject(userSession)
                }
            } else {
                LoginView()
                    .environmentObject(userSession)
            }
        }
    }
}
