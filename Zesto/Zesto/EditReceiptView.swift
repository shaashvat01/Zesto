//
//  EditReceiptItemView.swift
//  Zesto
//
//  Created by Shaashvat Mittal on 4/2/25.
//

import SwiftUI

struct EditReceiptView: View {
    @Binding var item: ReceiptItem
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView
        {
            Form
            {
                Section(header: Text("Edit Item"))
                {
                    TextField("Name", text: $item.name)
                    TextField("Quantity", value: $item.quantity, format: .number)
                    TextField("Price", value: $item.price, format: .currency(code: "USD"))
                }
            }
            .navigationTitle("Edit Item")
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
    }
}
