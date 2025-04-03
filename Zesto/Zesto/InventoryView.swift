//
//  InventoryView.swift
//  Zesto
//
//  Created by Shaashvat Mittal on 4/3/25.
//

// InventoryView.swift
import SwiftUI

struct InventoryView: View {
    var body: some View {
        VStack {
            Text("Inventory Screen")
                .font(.title)
                .padding()
            
            // In the future, you can show the stored items,
            // or do something else with them
            Spacer()
        }
        .navigationTitle("My Inventory")
        .navigationBarTitleDisplayMode(.inline)
    }
}

