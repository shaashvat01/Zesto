//
//  HomeViewManager.swift
//  Zesto
//
//  Created by Saisrivathsan Manikandan on 3/15/25.
//

import Foundation
import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit
import SwiftUICore

let insightCardColors: [Color] = [
    Color.blue,
    Color.green,
    Color.orange,
    Color.red,
    Color.purple,
    Color.teal,
    Color.pink,
    Color.yellow,
    Color.indigo,
    Color.mint,
    Color.cyan,
    Color.brown
]

struct ImageResponse: Codable {
    let image_url: String
}

extension UIImage {
    func upscale(scale: CGFloat) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.lanczosScaleTransform()
        let ciImage = CIImage(image: self)

        filter.inputImage = ciImage
        filter.scale = Float(scale)  // Scale factor (e.g., 2.0 for 2x upscaling)

        guard let outputImage = filter.outputImage,
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }
}

class HomeViewManager: ObservableObject {
    @Published var recommendCards: [RecommendCardHome] = []
    @Published var insightCards: [InsightsCardHome] = []
    @Published var popularCards: [PopularDishesCardHome] = []
    
    let baseURL = "https://bobo999.pythonanywhere.com/get_image?dish="
    
    init() {
        let mealTimes = ["Breakfast", "Lunch", "Dinner", "Snack"]
        let dishNames = ["Big Mac", "Beef Rendang", "Chakchouka", "Bakewell tart", "French Onion Soup", "Potato Salad (Olivier Salad)"
        ]
        // Generate 4 random recommended cards with image fetching
        for index in 1...4 {
            let randomMealTime = mealTimes[index-1]
            let randomDish = dishNames.randomElement() ?? "Dish"

            addRecommendCard(mealTime: randomMealTime, dishName: randomDish, imageURL: nil)
        }

        // Generate 4 random AI insights
        let insightMessages = [
            "Try reducing sugar for better health!",
            "Eating more greens improves digestion.",
            "Protein helps build muscle efficiently.",
            "Stay hydrated for optimal performance!"
        ]
        for _ in 1...4 {
            let randomMessage = insightMessages.randomElement() ?? "Eat healthy!"
            addInsightCard(message: randomMessage)
        }

        // Generate 4 random popular dishes with image fetching
        for _ in 1...4 {
            let randomDish = dishNames.randomElement() ?? "Dish"

            addPopularCard(dishName: randomDish, imageURL: nil) // Fetches from API if nil
        }
    }
    //func to fetch full recipe model
    func fetchRecipeMealDB(for dishName: String, completion: @escaping (RecipeModel?) -> Void) {
        let placeholderURL = URL(string: "https://via.placeholder.com/150")!
        let baseURL = "https://www.themealdb.com/api/json/v1/1/search.php?s="

        guard let encodedDish = dishName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)\(encodedDish)") else {
            print("❌ Invalid URL for dish: \(dishName)")
            completion(nil)
            return
        }

        print("🌍 Fetching recipe from: \(url)")

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Error fetching data: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("❌ No data received for recipe request.")
                completion(nil)
                return
            }

            do {
                let response = try JSONDecoder().decode(MealDBResponse.self, from: data)
                guard let meal = response.meals?.first else {
                    completion(nil)
                    return
                }

                // Use Mirror to get ingredients and measurements
                let mirror = Mirror(reflecting: meal)
                var ingredients: [String] = []

                for i in 1...20 {
                    let ingredientLabel = "strIngredient\(i)"
                    let measureLabel = "strMeasure\(i)"

                    let ingredient = mirror.children.first { $0.label == ingredientLabel }?.value as? String
                    let measure = mirror.children.first { $0.label == measureLabel }?.value as? String

                    if let ingredient = ingredient?.trimmingCharacters(in: .whitespacesAndNewlines),
                       !ingredient.isEmpty,
                       ingredient.lowercased() != "null" {
                        let cleanMeasure = measure?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                        ingredients.append("\(cleanMeasure) \(ingredient)".trimmingCharacters(in: .whitespaces))
                    }
                }

                let tags = meal.strTags?.components(separatedBy: ",") ?? []
                let instructions = meal.strInstructions
                    .components(separatedBy: .newlines)
                    .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
                let imageURL = URL(string: meal.strMealThumb) ?? placeholderURL

                let recipe = RecipeModel(
                    name: meal.strMeal,
                    tags: tags,
                    ingredients: ingredients,
                    instructions: instructions,
                    imageURL: imageURL
                )

                DispatchQueue.main.async {
                    completion(recipe)
                }

            } catch {
                print("❌ Failed to decode JSON: \(error)")
                completion(nil)
            }
        }.resume()
    }

    
    // image URL fetch for MealDB service [Currently only returns URL BUT CAN RETURN ENTIRE RECIPIE OBJECT]
    func fetchImageMealDB(for dishName: String, completion: @escaping (String?) -> Void) {
        let placeholderURL = "https://via.placeholder.com/150"
        let baseURL = "https://www.themealdb.com/api/json/v1/1/search.php?s="

        guard let encodedDish = dishName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)\(encodedDish)") else {
            print("❌ Invalid URL for dish: \(dishName)")
            completion(placeholderURL)
            return
        }

        print("🌍 Fetching image from: \(url)")

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Error fetching image: \(error.localizedDescription)")
                completion(placeholderURL)
                return
            }

            guard let data = data else {
                print("❌ No data received for image request.")
                completion(placeholderURL)
                return
            }

            do {
                let response = try JSONDecoder().decode(MealDBResponse.self, from: data)
                let imageUrl = response.meals?.first?.strMealThumb ?? placeholderURL

                print("✅ Successfully fetched image URL: \(imageUrl)")

                DispatchQueue.main.async {
                    completion(imageUrl)
                }
            } catch {
                print("❌ Failed to decode JSON: \(error)")
                completion(placeholderURL)
            }
        }.resume()
    }
    
    // WebScraper URL fetch service
    func fetchImage(for dishName: String, completion: @escaping (String?) -> Void) {
        let placeholderURL = "https://via.placeholder.com/150"

        guard let encodedDish = dishName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)\(encodedDish)") else {
            print("❌ Invalid URL for dish: \(dishName)")
            completion(placeholderURL)
            return
        }

        print("🌍 Fetching image from: \(url)")

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Error fetching image: \(error.localizedDescription)")
                completion(placeholderURL)
                return
            }

            guard let data = data else {
                print("❌ No data received for image request.")
                completion(placeholderURL)
                return
            }

            do {
                let imageResponse = try JSONDecoder().decode(ImageResponse.self, from: data)
                let imageUrl = imageResponse.image_url
                
                print("✅ Successfully fetched image URL: \(imageUrl)")
                
                DispatchQueue.main.async {
                    self.objectWillChange.send()
                    completion(imageUrl)
                }
            } catch {
                print("❌ Failed to decode JSON: \(error)")
                completion(placeholderURL)
            }
        }.resume()
    }
    
    func addRecommendCard(mealTime: String, dishName: String, imageURL: String?){
        if (imageURL != nil){
            self.recommendCards.append(RecommendCardHome(mealTime: mealTime, dishName: dishName, imageURL: imageURL))
        }
        else{
            fetchRecipeMealDB(for: dishName) { recipe in
                guard let recipe = recipe else {
                    print("❌ Failed to fetch recipe for \(dishName)")
                    return
                }

                DispatchQueue.main.async {
                    self.objectWillChange.send()
                    self.recommendCards.append(
                        RecommendCardHome(
                            mealTime: mealTime,
                            dishName: dishName,
                            imageURL: recipe.imageURL.absoluteString,
                            RecipeModel: recipe
                        )
                    )
                }
            }
        }
        
    }
    
    func addInsightCard(message: String){
        let randomColor = insightCardColors[Int.random(in: 0..<insightCardColors.count)]
        self.insightCards.append(InsightsCardHome(message: message,Color: randomColor))
    }
    
    func addPopularCard(dishName: String, imageURL: String?){
        if (imageURL != nil){
            self.popularCards.append(PopularDishesCardHome(dishName: dishName, imageURL: imageURL))
        }
        else{
            fetchRecipeMealDB(for: dishName) { recipe in
                guard let recipe = recipe else {
                    print("❌ Failed to fetch recipe for \(dishName)")
                    return
                }

                DispatchQueue.main.async {
                    self.objectWillChange.send()
                    self.popularCards.append(
                        PopularDishesCardHome(
                            dishName: dishName,
                            imageURL: recipe.imageURL.absoluteString,
                            RecipeModel: recipe
                        )
                    )
                }
            }
            
        }
    }
    
    func getRecommendCard(index: Int) -> RecommendCardHome?{
        if index >= self.recommendCards.count {
            return nil
        }
        return self.recommendCards[index]
    }
    
    func getInsightCard(index: Int) -> InsightsCardHome?{
        if index >= self.insightCards.count {
            return nil
        }
        return self.insightCards[index]
    }
    
    func getPopularCard(index: Int) -> PopularDishesCardHome?{
        if index >= self.popularCards.count {
            return nil
        }
        return self.popularCards[index]
    }
    
    func getRecommendCards() -> [RecommendCardHome]{
        return self.recommendCards
    }
    
    func getInsightCards() -> [InsightsCardHome]{
        return self.insightCards
    }
    
    func getPopularCards() -> [PopularDishesCardHome]{
        return self.popularCards
    }
    
    func clearAllCards(){
        self.recommendCards.removeAll()
        self.insightCards.removeAll()
        self.popularCards.removeAll()
    }
}
