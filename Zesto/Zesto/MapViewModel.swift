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

class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate{
    
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var groceryStores: [GroceryStoreLocation] = []
    @Published var searchText: String = ""
    @Published var locationDenied: Bool = false
    
    private var locationManager: CLLocationManager?
    
    override init()
    {
        super.init()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        requestLocationPermission()
    }
    
    func requestLocationPermission()
    {
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined
        {
            locationManager?.requestWhenInUseAuthorization()
        }
        else if status == .denied || status == .restricted
        {
            locationDenied = true
        }
        else
        {
            locationManager?.startUpdatingLocation()
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        if status == .authorizedWhenInUse || status == .authorizedAlways
        {
            locationDenied = false
            locationManager?.startUpdatingLocation()
        }
        else if status == .denied || status == .restricted
        {
            locationDenied = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        if let location = locations.last
        {
            print("User location updated: \(location.coordinate)")
            userLocation = location.coordinate
            // Stop updating once we have a location.
            locationManager?.stopUpdatingLocation()
            // Perform an initial search for grocery stores.
            performSearch(query: "grocery store")
        }
    }
    
    
    func performSearch(query: String)
    {
        guard let userLocation = userLocation
        else
        {
            print("User location not available. Cannot perform search.")
            return
        }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        
        // Define a 5-mile region (approximately 8046 meters).
        let region = MKCoordinateRegion(center: userLocation, latitudinalMeters: 8046, longitudinalMeters: 8046)
        request.region = region
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            DispatchQueue.main.async
            {
                if let items = response?.mapItems
                {
                    print("Found \(items.count) items")
                    self?.groceryStores = items.prefix(10).map { GroceryStoreLocation(mapItem: $0) }
                }
                else
                {
                    if let error = error
                    {
                        print("Search error: \(error.localizedDescription)")
                    }
                    else
                    {
                        print("No items found")
                    }
                    self?.groceryStores = []
                }
            }
        }
    }
}
