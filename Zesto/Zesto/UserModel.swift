//
//  UserModel.swift
//  Zesto
//
//  Created by Saisrivathsan Manikandan on 4/9/25.
//

import Foundation

struct UserModel: Identifiable, Codable {
    var id: String
    var email: String
    var firstName: String
    var lastName: String
    var username: String
    var displayName: String?
    var dateOfBirth: Date?
    var dietaryPreferences: [String]
    var createdAt: Date
}
