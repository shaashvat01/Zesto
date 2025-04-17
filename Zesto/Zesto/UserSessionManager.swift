//
//  UserSessionManager.swift
//  Zesto
//
//  Created by Saisrivathsan Manikandan on 4/7/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

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
                        dietaryPreferences: userData["dietaryRestrictions"] as? [String] ?? [],
                        createdAt: (userData["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                        profileImageURL: {
                                if let urlString = userData["profileImageUrl"] as? String {
                                    return URL(string: urlString)
                                }
                                return nil
                            }()
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
    
    func saveProfileChanges(firstName: String, lastName: String, username: String, dietaryPreferences: [String], profileImage: UIImage?, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userID = self.userModel?.id else {
            completion(.failure(NSError(domain: "InvalidUserID", code: 0, userInfo: nil)))
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userID)

        if let profileImage = profileImage, let imageData = profileImage.jpegData(compressionQuality: 0.8) {
            let storageRef = Storage.storage().reference().child("profileImages/\(UUID().uuidString).jpg")
            storageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                storageRef.downloadURL { url, error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }

                    let imageUrl = url?.absoluteString ?? ""
                    self.updateFirestore(userRef: userRef, firstName: firstName, lastName: lastName, username: username, dietaryPreferences: dietaryPreferences, imageUrl: imageUrl, completion: completion)
                }
            }
        } else {
            let existingUrl = self.userModel?.profileImageURL?.absoluteString ?? ""
            self.updateFirestore(userRef: userRef, firstName: firstName, lastName: lastName, username: username, dietaryPreferences: dietaryPreferences, imageUrl: existingUrl, completion: completion)
        }
    }

    private func updateFirestore(userRef: DocumentReference, firstName: String, lastName: String, username: String, dietaryPreferences: [String], imageUrl: String, completion: @escaping (Result<Void, Error>) -> Void) {

        let updatedData: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "username": username,
            "dietaryRestrictions": dietaryPreferences,
            "profileImageUrl": imageUrl
        ]

        userRef.updateData(updatedData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                self.checkIfSetupIsDone()  // Refresh local model
                completion(.success(()))
            }
        }
    }

}
