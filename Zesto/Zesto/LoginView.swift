//
//  LoginView.swift
//  Zesto
//
//  Created by Saisrivathsan Manikandan on 4/7/25.
//

//

import SwiftUI
import Firebase
import FirebaseAuth

struct LoginView: View {
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var userName: String = ""
    
    @State private var mail: String = ""
    @State private var password: String = ""
    @State private var passwordConfirm: String = ""
    @State private var errorMessage: String = ""
    @State var isSignUp: Bool = false
    @EnvironmentObject var session: UserSessionManager
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [.green.opacity(0.3), .mint.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Frosted Glass Form Card
            VStack(spacing: 24) {
                Text(isSignUp ? "Create Account" : "Log In")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                    .padding(.top, 20)

                VStack(spacing: 16) {
                    if(isSignUp){
                        TextField("First Name", text: $firstName)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(12)
                            .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                            .foregroundColor(.black)
                        
                        TextField("Last Name", text: $lastName)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(12)
                            .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                            .foregroundColor(.black)
                        
                        TextField("Username", text: $userName)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(12)
                            .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                            .foregroundColor(.black)
                    }
                    
                    // Email Field
                    TextField("Email", text: $mail)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(12)
                        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                        .foregroundColor(.black)
                    
                    // Password Field
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(12)
                        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                        .foregroundColor(.black)
                    
                    if(isSignUp){
                        SecureField("Confirm Password", text: $passwordConfirm)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(12)
                            .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                            .foregroundColor(.black)
                    }
                }
                
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)

                // Login / Signup Button
                Button(action: {
                    isSignUp ? signup() : login()
                }) {
                    Text(isSignUp ? "Sign Up" : "Login")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(gradient: Gradient(colors: [.green, .mint]),
                                           startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(14)
                }
                .shadow(radius: 5)

                // Toggle Login/Signup
                HStack(spacing: 5) {
                    Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                        .foregroundColor(.black.opacity(0.7))
                    
                    Button(action: {
                        withAnimation(.easeInOut) {
                            isSignUp.toggle()
                        }
                    }) {
                        Text(isSignUp ? "Log in" : "Sign up")
                            .foregroundColor(.green)
                            .fontWeight(.medium)
                            .underline()
                    }
                }
            }
            .padding(30)
            .background(.ultraThinMaterial)
            .cornerRadius(25)
            .shadow(radius: 10)
            .padding(.horizontal, 20)
        }
    }

    func signup() {
        // Validate password match
        guard password == passwordConfirm else {
            errorMessage = "Passwords do not match!"
            return
        }

        let db = Firestore.firestore()

        // Check if username exists
        db.collection("users").whereField("username", isEqualTo: userName).getDocuments { (querySnapshot, error) in
            if let error = error {
                self.errorMessage = "Error checking username: \(error.localizedDescription)"
                return
            }

            guard querySnapshot?.isEmpty == true else {
                self.errorMessage = "Username is already taken!"
                return
            }

            // Check if email already exists
            db.collection("users").whereField("email", isEqualTo: mail).getDocuments { (querySnapshot, error) in
                if let error = error {
                    self.errorMessage = "Error checking email: \(error.localizedDescription)"
                    return
                }

                guard querySnapshot?.isEmpty == true else {
                    self.errorMessage = "Email is already registered!"
                    return
                }

                // Create Firebase Auth user
                Auth.auth().createUser(withEmail: mail, password: password) { (result, error) in
                    if let error = error {
                        self.errorMessage = "Signup error: \(error.localizedDescription)"
                        return
                    }

                    guard let user = result?.user else {
                        self.errorMessage = "Signup failed: User not created."
                        return
                    }

                    let userRef = db.collection("users").document(user.uid)

                    userRef.setData([
                        "firstName": firstName,
                        "lastName": lastName,
                        "username": userName,
                        "email": mail,
                        "createdAt": Timestamp()
                    ]) { err in
                        if let err = err {
                            self.errorMessage = "Error saving user data: \(err.localizedDescription)"
                        } else {
                            self.errorMessage = ""
                            print("User signed up and data saved successfully!")
                        }
                    }
                }
            }
        }
    }



    func login() {
        Auth.auth().signIn(withEmail: mail , password: password) { (result, error) in
            if let error = error {
                print("Login error: \(error.localizedDescription)")
                errorMessage = error.localizedDescription
            } else {
                print("Logged in")
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(UserSessionManager())
}
