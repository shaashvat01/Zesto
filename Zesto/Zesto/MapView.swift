//
//  MapView.swift
//  Zesto
//
//  Created by Shaashvat Mittal on 4/13/25.
//

import SwiftUI
import MapKit

struct MapView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = MapViewModel()
    
    // Default region; will be updated once we have the user’s location.
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.0090),
        latitudinalMeters: 20000,
        longitudinalMeters: 20000
    )
    
    var body: some View {
        ZStack {
            // Main Map with markers for each grocery store
            Map(coordinateRegion: $region, annotationItems: viewModel.groceryStores) { store in
                MapMarker(coordinate: store.mapItem.placemark.coordinate, tint: .red)
            }
            .ignoresSafeArea()
            // Whenever userLocation changes, update the region to center on it
            .onReceive(viewModel.$userLocation) { newValue in
                if let userLoc = newValue
                {
                    region = MKCoordinateRegion(
                        center: userLoc,
                        latitudinalMeters: 8046 * 2,
                        longitudinalMeters: 8046 * 2
                    )
                }
            }
            
            // top overlay: Back button and search bar
            VStack
            {
                HStack(spacing: 8)
                {
                    Button(action:
                    {
                        dismiss()
                    })
                    {
                        Image(systemName: "chevron.left")
                            .padding(10)
                            .background(Color.white.opacity(0.8))
                            .clipShape(Circle())
                    }
                    
                    TextField("Search nearby stores", text: $viewModel.searchText, onCommit: {
                        viewModel.performSearch(query: viewModel.searchText)
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.vertical, 8)
                }
                .padding(.horizontal, 16)
                .zIndex(1)  // Ensure it appears above the map
                Spacer()
            }
            
            // Bottom overlay: a vertical list of nearby grocery stores
            VStack
            {
                Spacer()
                VStack
                {
                    if (viewModel.groceryStores.isEmpty)
                    {
                        Text("No stores found")
                            .foregroundColor(.gray)
                            .padding()
                    }
                    else
                    {
                        List(viewModel.groceryStores) { store in
                            StoreRowView(store: store)
                        }
                        .listStyle(.insetGrouped)
                    }
                }
                .background(Color.white)
                .frame(maxHeight: UIScreen.main.bounds.height * 0.4)
            }
        }
        // Alert if location permission is denied
        .alert(isPresented: $viewModel.locationDenied)
        {
            Alert(title: Text("Location Permission Denied"),
                  message: Text("Please enable location services in settings to view nearby grocery stores."),
                  dismissButton: .default(Text("OK"), action: {
                      dismiss()
            }))
        }
    }
}

struct StoreRowView: View
{
    let store: GroceryStoreLocation
    var body: some View
    {
        HStack
        {
            VStack(alignment: .leading, spacing: 4)
            {
                // Store name as the headline
                Text(store.mapItem.name ?? "Unnamed Store")
                    .font(.headline)
                
                // City
                if let city = store.mapItem.placemark.locality {
                    Text("City: \(city)")
                }
                
                // Country
                if let country = store.mapItem.placemark.country {
                    Text("Country: \(country)")
                }
            }
            Spacer()
            
            // Chevron on the right
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .contentShape(Rectangle())  // Make entire row tappable
        .onTapGesture {
            // Tap opens this location in Apple Maps
            store.mapItem.openInMaps(launchOptions: nil)
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
