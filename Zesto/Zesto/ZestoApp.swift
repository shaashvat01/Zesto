//
//  ZestoApp.swift
//  Zesto
//
//  Created by Shaashvat Mittal on 3/9/25.
//

import SwiftUI

class AppState: ObservableObject {
    @Published var hideTopBar: Bool = false
    @Published var topID: Int?
}

@main
struct ZestoApp: App {
    @StateObject var appState = AppState()
    var body: some Scene {
        WindowGroup {
            MainView()
                .modelContainer(for: [InventoryItem.self])
                .environmentObject(appState)
        }
    }
}
