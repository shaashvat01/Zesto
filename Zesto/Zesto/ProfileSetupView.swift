//
//  ProfileSetupView.swift
//  Zesto
//
//  Created by Saisrivathsan Manikandan on 4/7/25.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

let dietaryOptions = [
    "Vegetarian", "Vegan", "Gluten-Free", "Dairy-Free",
    "Nut Allergy", "Halal", "Kosher", "Peanut Allergy",
    "Lactose Intolerant", "Shellfish Allergy"
]

let lifestyleOptions = [
    "Vegetarian",
    "Vegan",
    "Pescatarian",
    "Paleo",
    "Keto",
    "Low-Carb",
    "Raw Food",
    "Whole30",
    "Flexitarian"
]

let healthRestrictions = [
    "Gluten-Free",
    "Dairy-Free",
    "Lactose Intolerant",
    "Low FODMAP",
    "Low Sodium",
    "Low Sugar",
    "No Added Sugar",
    "Diabetic-Friendly",
    "Cholesterol-Conscious",
    "Heart-Healthy"
]

let allergies = [
    "Nut Allergy",
    "Peanut Allergy",
    "Tree Nut Allergy",
    "Shellfish Allergy",
    "Fish Allergy",
    "Egg Allergy",
    "Soy Allergy",
    "Wheat Allergy",
    "Sesame Allergy",
    "Corn Allergy",
    "Mustard Allergy",
    "Gluten Allergy",
    "Sulfite Sensitivity",
    "Food Dye Allergy"
]

let culturalReligiousRestrictions = [
    "Halal",
    "Kosher",
    "Jain Vegetarian",
    "Hindu Vegetarian",
    "Buddhist Vegetarian",
    "No Beef",
    "No Pork"
]

let otherRestrictions = [
    "Alcohol-Free",
    "Caffeine-Free",
    "MSG-Free"
]


struct ProfileSetupView:View {
    @EnvironmentObject var userSession: UserSessionManager
    @State private var dateOfBirth: Date = Date()
    @State private var showDatePicker: Bool = false
    @State private var showDietSheet = false
    
    @State private var stageNum: Int = 0

    @State private var selectedRestrictions: Set<String> = []

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        return formatter
    }
    
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.green.opacity(0.3), .mint.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                Text("Profile Set Up")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                    .padding(.top, 10)
                
                VStack(spacing: 20) {
                    
                    ZStack {
                        // The bar segments
                        HStack(spacing: 0) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(stageNum >= 0 ? Color.green : Color.white)
                                .frame(width: 100, height: 10)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.green, lineWidth: 2))
                            
//                            Circle()
//                                .frame(width: 30, height: 30)
//                                .foregroundColor(.white)
//                                .shadow(radius: 5)

                            RoundedRectangle(cornerRadius: 10)
                                .fill(stageNum >= 1 ? Color.green : Color.white)
                                .frame(width: 100, height: 10)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.green, lineWidth: 2))

                            RoundedRectangle(cornerRadius: 10)
                                .fill(stageNum >= 2 ? Color.green : Color.white)
                                .frame(width: 100, height: 10)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.green, lineWidth: 2))
                        }

                        // The stage markers (circles)
//                        HStack {
//                            Spacer()
//                            
//                            
//                            Circle()
//                                .frame(width: 30, height: 30)
//                                .foregroundColor(.white)
//                                .shadow(radius: 5)
//                            Spacer()
//                            Circle()
//                                .frame(width: 30, height: 30)
//                                .foregroundColor(.white)
//                                .shadow(radius: 5)
//                            Spacer()
//                        }
//                        .frame(width: 300) // Matches total bar width
                    }
                    
                    Spacer()
                    
                    if(stageNum == 0){
                        Button(action: {
                            showDatePicker = true
                        }) {
                            HStack {
                                Text("Date of Birth")
                                    .foregroundColor(.black.opacity(0.6))
                                
                                Spacer()
                                
                                Text(dateFormatter.string(from: dateOfBirth))
                                    .foregroundColor(.black)
                            }
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(12)
                            .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                        }
                    }
                    else if(stageNum == 1){
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
                    }
                    else{
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .foregroundColor(.white)
                    }
                    
                   
                    
                    Spacer()
                    
                    
                    
                    HStack{
                        
                        Button(action: {
                            if(stageNum > 0){
                                stageNum -= 1
                            }
                        }) {
                            Text("Back")
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
                        
                        Button(action: {
                            if(stageNum < 2){
                                stageNum += 1
                            }
                        }) {
                            Text("Next")
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
                    }
                    if(stageNum == 2){
                        Button(action: {
                            let db = Firestore.firestore()
                                if let userID = Auth.auth().currentUser?.uid {
                                    db.collection("users").document(userID).updateData([
                                        "dateOfBirth": Timestamp(date: dateOfBirth),
                                        "dietaryRestrictions": Array(selectedRestrictions),
                                        "setupComplete": true
                                    ]) { error in
                                        if let error = error {
                                            print("Error updating setup info: \(error.localizedDescription)")
                                        } else {
                                            print("User setup info saved!")
                                        }
                                    }
                                } else {
                                    print("No user is currently signed in.")
                                }
                            
                        }) {
                            Text("Confirm")
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
                    }

                    
                
                    
                }
                
            }
            .padding(30)
            .background(.ultraThinMaterial)
            .cornerRadius(25)
            .shadow(radius: 10)
            .padding(.horizontal, 20)
        }
        .sheet(isPresented: $showDatePicker) {
                    VStack {
                        DatePicker("Select your date of birth", selection: $dateOfBirth, in: ...Date(), displayedComponents: .date)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .padding()
                        
                        Button("Done") {
                            showDatePicker = false
                        }
                        .padding()
                    }
                    .presentationDetents([.height(300)])
                }
    }
}

struct DietarySelectionSheet: View {
    @Binding var selected: Set<String>
    @Binding var isPresented: Bool

    let sections: [(title: String, options: [String])] = [
        ("Lifestyle", lifestyleOptions),
        ("Health Restrictions", healthRestrictions),
        ("Allergies", allergies),
        ("Cultural/Religious", culturalReligiousRestrictions),
        ("Other", otherRestrictions)
    ]

    var body: some View {
        NavigationView {
            List {
                ForEach(sections, id: \.title) { section in
                    Section(header: Text(section.title).font(.headline)) {
                        ForEach(section.options, id: \.self) { option in
                            MultipleSelectionRow(title: option, isSelected: selected.contains(option)) {
                                if selected.contains(option) {
                                    selected.remove(option)
                                } else {
                                    selected.insert(option)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Dietary Preferences")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        isPresented.toggle()
                    }
                }
            }
        }
    }
}

struct MultipleSelectionRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.green)
                }
            }
        }
    }
}

struct WrapTagsView: View {
    let tags: [String]

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 8) {
            ForEach(tags, id: \.self) { tag in
                Text(tag)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.green.opacity(0.2))
                    .foregroundColor(.black)
                    .cornerRadius(20)
                    .font(.caption)
            }
        }
    }
}

    


#Preview {
    ProfileSetupView()
        .environmentObject(UserSessionManager())
}
