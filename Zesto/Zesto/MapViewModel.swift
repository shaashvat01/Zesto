//
//  MapViewModel.swift
//  Zesto
//
//  Created by Shaashvat Mittal on 4/13/25.
//

import Foundation
import CoreLocation
import MapKit
import Combine

class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var groceryStores: [GroceryStoreLocation] = []
    @Published var searchText: String = ""
    @Published var locationDenied: Bool = false
    @Published var showLocationSettingsAlert: Bool = false
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        requestLocationPermission()
    }
    
    func requestLocationPermission() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationDenied = false
            showLocationSettingsAlert = false
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            locationDenied = true
            showLocationSettingsAlert = true
        @unknown default:
            locationDenied = true
            showLocationSettingsAlert = true
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        requestLocationPermission()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        print("User location updated: \(location.coordinate)")
        userLocation = location.coordinate
        // Stop updating once we have a location
        locationManager.stopUpdatingLocation()
        // Perform an initial search for grocery stores
        performSearch(query: "grocery store")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
        locationDenied = true
    }
    
    func performSearch(query: String) {
        guard let userLocation = userLocation else {
            print("User location not available. Cannot perform search.")
            return
        }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        
        // Define a 5-mile region (approximately 8046 meters)
        let region = MKCoordinateRegion(
            center: userLocation,
            latitudinalMeters: 8046,
            longitudinalMeters: 8046
        )
        request.region = region
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            DispatchQueue.main.async {
                if let items = response?.mapItems {
                    print("Found \(items.count) items")
                    self?.groceryStores = items.prefix(10).map { GroceryStoreLocation(mapItem: $0) }
                } else {
                    self?.groceryStores = []
                    if let error = error {
                        print("Search error: \(error.localizedDescription)")
                    } else {
                        print("No items found")
                    }
                }
            }
        }
    }
}
