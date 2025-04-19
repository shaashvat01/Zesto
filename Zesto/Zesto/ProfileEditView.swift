//
//  ProfileEditView.swift
//  Zesto
//
//  Created by Saisrivathsan Manikandan on 4/16/25.
//

import SwiftUI
import PhotosUI



struct ProfileEditView: View {
    @EnvironmentObject var userSession: UserSessionManager
    @EnvironmentObject var appState: AppState
    
    @State private var profileImage: UIImage?
    @State private var selectedItem: PhotosPickerItem?
    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var username: String = ""
    @State private var dietaryPreferences: [String] = []
    
    @State private var isSaving = false
    @State private var saveError: String?
    
    @State private var showDietSheet = false
    @State private var selectedRestrictions: Set<String> = []

    var body: some View {
        ScrollView{
            VStack(spacing: 20) {
                // Profile Image
                
                if let profileImage = profileImage {
                    Image(uiImage: profileImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
                else{
                    if let image = userSession.userModel?.profileImage {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    } else if let url = userSession.userModel?.profileImageURL {
                        AsyncImage(url: url) { image in
                            image.resizable()
                        }placeholder: {
                            ProgressView()
                        }
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                        
                    } else {
                        Image(systemName: "person.crop.circle.fill.badge.plus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                    }
                }

                
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Text("Change Profile Picture")
                        .foregroundColor(.black)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .shadow(radius: 2)
                }
                .onChange(of: selectedItem) { newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            self.profileImage = uiImage
                        }
                    }
                }
                
                // Text Fields styled
                VStack(alignment: .leading, spacing: 8) {
                    Text("First Name")
                        .foregroundColor(.black.opacity(0.6))
                        .font(.subheadline)
                    
                    TextField("First Name", text: $firstName)
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(12)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    Text("Last Name")
                        .foregroundColor(.black.opacity(0.6))
                        .font(.subheadline)
                    
                    TextField("Last Name", text: $lastName)
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(12)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Username")
                        .foregroundColor(.black.opacity(0.6))
                        .font(.subheadline)
                        
                    
                    TextField("Username", text: $username)
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(12)
                }
                
                
                
                
                // Dietary Preferences Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Dietary Restrictions")
                        .foregroundColor(.black.opacity(0.6))
                        .font(.subheadline)
                    
                    Button(action: {
                        showDietSheet.toggle()
                    }) {
                        HStack {
                            Text("Select Dietary Restrictions")
                                .foregroundColor(selectedRestrictions.isEmpty ? .gray : .black)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(12)
                        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                    }
                    
                    // Display selected restrictions
                    if !selectedRestrictions.isEmpty {
                        WrapTagsView(tags: Array(selectedRestrictions))
                    }
                }
                .sheet(isPresented: $showDietSheet) {
                    DietarySelectionSheet(selected: $selectedRestrictions, isPresented: $showDietSheet)
                }
                
                // Save Button
                Button(action: saveProfile) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Text("Save Changes")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(gradient: Gradient(colors: [.green, .mint]), startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(14)
                    }
                }
                .disabled(isSaving)
                .shadow(radius: 5)
                
                // Error Message
                if let error = saveError {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                }
                
            }
            .padding()
            .onAppear {
                appState.hideBottomBar = true
                if let user = userSession.userModel {
                    self.firstName = user.firstName
                    self.lastName = user.lastName
                    self.username = user.username
                    self.dietaryPreferences = user.dietaryPreferences
                    selectedRestrictions = Set(user.dietaryPreferences)
                }
            }
        }
    }

    private func saveProfile() {
        isSaving = true
        saveError = nil

        userSession.saveProfileChanges(
            firstName: firstName,
            lastName: lastName,
            username: username,
            dietaryPreferences: Array(selectedRestrictions),
            profileImage: profileImage
        ) { result in
            DispatchQueue.main.async {
                isSaving = false
                switch result {
                case .success:
                    print("Profile updated.")
                    appState.topID = 4
                    if let uiImage = profileImage {
                        userSession.userModel?.profileImage = Image(uiImage: uiImage)
                    }
                case .failure(let error):
                    saveError = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    ProfileEditView()
        .environmentObject(UserSessionManager())
        .environmentObject(AppState())
}


