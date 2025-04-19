//
//  ProfileView.swift
//  Zesto
//
//  Created by Saisrivathsan Manikandan on 4/14/25.
//

import SwiftUI

struct ProfileView: View {
    @State private var profileImage: UIImage? = nil
    @State private var showImagePicker = false
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var userSession: UserSessionManager
    @EnvironmentObject var recipeManager: UserRecipeManager
    
    @State var pageNumber = 0
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(alignment: .center, spacing: 16) {
                
                if let imageUrl = userSession.userModel?.profileImageURL {
                    if let cachedImage = userSession.userModel?.profileImage {
                        cachedImage
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    } else {
                        AsyncImage(url: imageUrl) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                                    .shadow(radius: 5)
                                    .onAppear {
                                        userSession.userModel?.profileImage = image
                                    }
                            case .failure(_):
                                Image(systemName: "person.crop.circle.badge.exclam")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                                    .shadow(radius: 5)
                            case .empty:
                                ProgressView()
                            @unknown default:
                                EmptyView()
                            }
                        }
                        
                    }
                }
                else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray.opacity(0.7))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    if let user = userSession.userModel{
                        Text("\(user.firstName) \(user.lastName)")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                        Text("@\(user.username)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    else{
                        Text("John Doe")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                        Text("@johndoe")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                }
                
                Spacer()
            }
            .padding()
            //                .background(.ultraThinMaterial)
            //                .cornerRadius(20)
            //                .shadow(radius: 5)
            
           // Options List
            VStack(spacing: 16) {
                Button(action: {
                    appState.topID = 6
                }) {
                    HStack {
                        Text("Your Bookmarks")
                            .foregroundColor(.black)
                            .font(.headline)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(14)
                    .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                }
                
                Button(action: {
                    appState.topID = 7
                }) {
                    HStack {
                        Text("Your Likes")
                            .foregroundColor(.black)
                            .font(.headline)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(14)
                    .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                }

                
                    
                    
                    
//                    HStack {
//                        Text("Your Likes")
//                            .foregroundColor(.black)
//                            .font(.headline)
//                        Spacer()
//                        Image(systemName: "chevron.right")
//                            .foregroundColor(.gray)
//                    }
//                    .padding()
//                    .background(Color.white.opacity(0.9))
//                    .cornerRadius(14)
//                    .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                    
                    HStack {
                        Text("Settings")
                            .foregroundColor(.black)
                            .font(.headline)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(14)
                    .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                
                
                
            }
         
            // Log Out Button
            Button(action: {
                recipeManager.clearData()
                userSession.logout()
            }) {
                Text("Log Out")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(14)
            }
            .shadow(radius: 5)
            .padding(.top, 32)
            
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .padding(20)
        .cornerRadius(25)
        .onAppear {
            appState.hideTopBar = false
            appState.hideBottomBar = false
            appState.topID =  4
        }
        
        
    }
        
}



#Preview {
    ProfileView()
        .environmentObject(UserSessionManager())
        .environmentObject(AppState())
}


