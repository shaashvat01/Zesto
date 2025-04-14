//
//  UserSessionManager.swift
//  Zesto
//
//  Created by Saisrivathsan Manikandan on 4/7/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

enum SetupStatus {
    case unknown
    case incomplete
    case complete
}

class UserSessionManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoggedIn: Bool = false
    @Published var setupStatus: SetupStatus = .unknown
    @Published var userModel: UserModel?

    init() {
        self.currentUser = Auth.auth().currentUser
        self.isLoggedIn = currentUser != nil

        if isLoggedIn {
            checkIfSetupIsDone()
        }

        Auth.auth().addStateDidChangeListener { _, user in
            self.currentUser = user
            self.isLoggedIn = user != nil

            if self.isLoggedIn {
                self.checkIfSetupIsDone()
            } else {
                self.setupStatus = .unknown
                self.userModel = nil
            }
        }
    }

    func checkIfSetupIsDone() {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.setupStatus = .incomplete
            return
        }

        Firestore.firestore().collection("users").document(uid).getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                let isComplete = data?["setupComplete"] as? Bool ?? false
                self.setupStatus = isComplete ? .complete : .incomplete
                
                if let userData = data {
                    self.userModel = UserModel(
                        id: uid,
                        email: userData["email"] as? String ?? "",
                        firstName: userData["firstName"] as! String,
                        lastName: userData["lastName"] as! String,
                        username: userData["username"] as? String ?? "",
                        displayName: userData["displayName"] as? String,
                        dateOfBirth: (userData["dateOfBirth"] as? Timestamp)?.dateValue(),
                        dietaryPreferences: userData["dietaryPreferences"] as? [String] ?? [],
                        createdAt: (userData["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                    )
                }
                
            } else {
                self.setupStatus = .incomplete
            }
        }
    }

    func logout() {
        do {
            try Auth.auth().signOut()
            self.currentUser = nil
            self.isLoggedIn = false
            self.setupStatus = .unknown
            self.userModel = nil
        } catch {
            print("Logout error: \(error.localizedDescription)")
        }
    }
}
