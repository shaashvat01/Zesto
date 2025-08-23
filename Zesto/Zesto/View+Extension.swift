//
//  View+Extension.swift
//  Zesto
//
//  Created by Saisrivathsan Manikandan on 8/23/25.
//

import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )
    }
}
