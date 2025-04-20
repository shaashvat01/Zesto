//
//  UserRecipeManager.swift
//  Zesto
//
//  Created by Saisrivathsan Manikandan on 4/16/25.
//

import Foundation
import SwiftUI
import Combine
import Firebase
import FirebaseAuth

class UserRecipeManager: ObservableObject {
    @Published var likes: [RecipeModel] = []
    @Published var bookmarks: [RecipeModel] = []

    private var listenerLikes: ListenerRegistration?
    private var listenerBookmarks: ListenerRegistration?

    init() {
        setupListeners()
    }

    deinit {
        listenerLikes?.remove()
        listenerBookmarks?.remove()
    }

    private func setupListeners() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        listenerLikes = Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("likes")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error listening to likes: \(error.localizedDescription)")
                    return
                }

                self.likes = snapshot?.documents.compactMap { doc in
                    self.decodeRecipe(from: doc.data())
                } ?? []
            }

        listenerBookmarks = Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("bookmarks")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error listening to bookmarks: \(error.localizedDescription)")
                    return
                }

                self.bookmarks = snapshot?.documents.compactMap { doc in
                    self.decodeRecipe(from: doc.data())
                } ?? []
            }
    }

    private func decodeRecipe(from data: [String: Any]) -> RecipeModel? {
        guard let name = data["name"] as? String,
              let tags = data["tags"] as? [String],
              let ingredients = data["ingredients"] as? [String],
              let instructions = data["instructions"] as? [String],
              let urlString = data["imageURL"] as? String,
              let imageURL = URL(string: urlString) else {
            return nil
        }

        return RecipeModel(
            name: name,
            tags: tags,
            ingredients: ingredients,
            instructions: instructions,
            imageURL: imageURL
        )
    }

    func uploadRecipe(_ recipe: RecipeModel, to collection: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let recipeData: [String: Any] = [
            "name": recipe.name,
            "tags": recipe.tags,
            "ingredients": recipe.ingredients,
            "instructions": recipe.instructions,
            "imageURL": recipe.imageURL.absoluteString
        ]

        Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection(collection)
            .document(recipe.id.uuidString)
            .setData(recipeData) { error in
                if let error = error {
                    print("Error saving to \(collection): \(error.localizedDescription)")
                } else {
                    print("Recipe saved to \(collection)!")
                    DispatchQueue.main.async {
                        if (collection == "likes" && self.likes.isEmpty) ||
                           (collection == "bookmarks" && self.bookmarks.isEmpty) {
                            self.refreshListeners()
                        }
                    }
                }
            }
    }


    
    func removeRecipeByName(_ recipe: RecipeModel, from collection: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let query = Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection(collection)
            .whereField("name", isEqualTo: recipe.name)

        query.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching recipe for deletion: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents, !documents.isEmpty else {
                print("No recipe with name \(recipe.name) found in \(collection).")
                return
            }

            for doc in documents {
                doc.reference.delete { error in
                    if let error = error {
                        print("Error deleting \(recipe.name) from \(collection): \(error.localizedDescription)")
                    } else {
                        print("Recipe '\(recipe.name)' removed from \(collection).")
                    }
                }
            }
        }
    }


    // Convenience wrappers
    func addLike(_ recipe: RecipeModel) {
        uploadRecipe(recipe, to: "likes")
    }

    func removeLike(_ recipe: RecipeModel) {
        removeRecipeByName(recipe, from: "likes")
    }

    func addBookmark(_ recipe: RecipeModel) {
        uploadRecipe(recipe, to: "bookmarks")
    }

    func removeBookmark(_ recipe: RecipeModel) {
        removeRecipeByName(recipe, from: "bookmarks")
    }
    
    
    func isRecipeLiked(_ recipe: RecipeModel) -> Bool {
        return likes.contains { $0.name == recipe.name }
    }

    func isRecipeBookmarked(_ recipe: RecipeModel) -> Bool {
        return bookmarks.contains { $0.name == recipe.name }
    }
    
    func clearData() {
        likes = []
        bookmarks = []
        listenerLikes?.remove()
        listenerBookmarks?.remove()
    }

    func refreshListeners() {
        listenerLikes?.remove()
        listenerBookmarks?.remove()
        setupListeners()
    }


}
