//
//  ProfileEditView.swift
//  Zesto
//
//  Created by Saisrivathsan Manikandan on 4/16/25.
//

import SwiftUI
import PhotosUI

//struct ProfileEditView: View {
//    @EnvironmentObject var userSession: UserSessionManager
//    @EnvironmentObject var appState: AppState
//    
//    @State private var profileImage: UIImage?
//    @State private var selectedItem: PhotosPickerItem?
//    
//    @State private var firstName: String = ""
//    @State private var lastName: String = ""
//    @State private var username: String = ""
//    @State private var dietaryPreferences: [String] = []
//    
//    @State private var isSaving = false
//    @State private var saveError: String?
//
//    var body: some View {
//        VStack(spacing: 20) {
//            // Profile Image
//            if let image = profileImage {
//                Image(uiImage: image)
//                    .resizable()
//                    .scaledToFill()
//                    .frame(width: 100, height: 100)
//                    .clipShape(Circle())
//                    .shadow(radius: 5)
//            } else if let url = userSession.userModel?.profileImageURL {
//                AsyncImage(url: url) { image in
//                    image.resizable()
//                } placeholder: {
//                    ProgressView()
//                }
//                .scaledToFill()
//                .frame(width: 100, height: 100)
//                .clipShape(Circle())
//                .shadow(radius: 5)
//            } else {
//                Image(systemName: "person.crop.circle.fill.badge.plus")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 100, height: 100)
//                    .foregroundColor(.gray)
//            }
//
//            // Photos Picker
//            PhotosPicker(selection: $selectedItem, matching: .images) {
//                Text("Change Profile Picture")
//                    .padding(.horizontal)
//                    .padding(.vertical, 8)
//                    .background(Color.white.opacity(0.9))
//                    .cornerRadius(10)
//                    .shadow(radius: 2)
//            }
//            .onChange(of: selectedItem) { newItem in
//                Task {
//                    if let data = try? await newItem?.loadTransferable(type: Data.self),
//                       let uiImage = UIImage(data: data) {
//                        self.profileImage = uiImage
//                    }
//                }
//            }
//
//            // Editable Fields
//            TextField("First Name", text: $firstName)
//                .textFieldStyle(.roundedBorder)
//
//            TextField("Last Name", text: $lastName)
//                .textFieldStyle(.roundedBorder)
//
//            TextField("Username", text: $username)
//                .textFieldStyle(.roundedBorder)
//
//            // Save Button
//            Button(action: saveProfile) {
//                if isSaving {
//                    ProgressView()
//                } else {
//                    Text("Save Changes")
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                }
//            }
//            .disabled(isSaving)
//
//            // Error Message
//            if let error = saveError {
//                Text("Error: \(error)")
//                    .foregroundColor(.red)
//            }
//
//        }
//        .padding()
//        .onAppear {
//            appState.hideBottomBar = true
//            
//            if let user = userSession.userModel {
//                self.firstName = user.firstName
//                self.lastName = user.lastName
//                self.username = user.username
//                self.dietaryPreferences = user.dietaryPreferences
//            }
//        }
//    }
//
//    private func saveProfile() {
//        isSaving = true
//        saveError = nil
//
//        userSession.saveProfileChanges(
//            firstName: firstName,
//            lastName: lastName,
//            username: username,
//            dietaryPreferences: dietaryPreferences,
//            profileImage: profileImage
//        ) { result in
//            DispatchQueue.main.async {
//                isSaving = false
//                switch result {
//                case .success:
//                    print("Profile updated.")
//                case .failure(let error):
//                    saveError = error.localizedDescription
//                }
//            }
//        }
//    }
//
//}

struct ProfileEditView: View {
    //@EnvironmentObject var userSession: UserSessionManager
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var username: String = ""
    @State private var dietaryPreferences: Set<String> = []
    @State private var profileImage: UIImage? = nil
    @State private var showDietSheet = false // For showing the dietary selection sheet
    @State private var selectedItem: PhotosPickerItem?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Edit Profile")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .padding(.top, 20)
            
            TextField("First Name", text: $firstName)
                .padding()
                .background(Color.white.opacity(0.9))
                .cornerRadius(12)
            
            TextField("Last Name", text: $lastName)
                .padding()
                .background(Color.white.opacity(0.9))
                .cornerRadius(12)
            
            TextField("Username", text: $username)
                .padding()
                .background(Color.white.opacity(0.9))
                .cornerRadius(12)
            
            Button(action: {
                showDietSheet.toggle()
            }) {
                HStack {
                    Text("Select Dietary Restrictions")
                        .foregroundColor(dietaryPreferences.isEmpty ? .gray : .black)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white.opacity(0.9))
                .cornerRadius(12)
                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
            }

            if !dietaryPreferences.isEmpty {
                WrapTagsView(tags: Array(dietaryPreferences))
            }
            
            PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                Text("Add Profile Picture")
                    .foregroundColor(.black)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(10)
                    .shadow(radius: 2)
            }
            
            Button(action: saveProfile) {
                Text("Save Changes")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(LinearGradient(gradient: Gradient(colors: [.green, .mint]), startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(14)
            }
            .shadow(radius: 5)
        }
        .padding()
        .sheet(isPresented: $showDietSheet) {
            DietarySelectionSheet(selected: $dietaryPreferences, isPresented: $showDietSheet)
        }
    }

    private func saveProfile() {
        // Implement the save profile logic
        print("Saving profile with: \(firstName), \(lastName), \(username), \(dietaryPreferences)")
    }
}


#Preview {
    ProfileEditView()
}


