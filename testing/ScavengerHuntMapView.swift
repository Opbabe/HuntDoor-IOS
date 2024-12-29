//
//  ScavengerHuntMapView.swift
//  testing
//
//  Created by Eric Nguyen on 4/17/24.
//

import SwiftUI
import MapKit
import CoreLocation

struct ScavengerHuntMapView: View {
    @State private var cameraPosition: MapCameraPosition = .region(myRegion)
    @State private var searchText: String = ""
    @State private var showSearch: Bool = false
    @State private var searchResults = [MKMapItem] = []
    @State private var mapSelection: MKMapItem?
    @State private var showDetails = false
    @State private var getDirections = false
    @State private var routeDisplaying = false
    @State private var route: MKRoute?
    @State private var routeDestination: MKMapItem?
    @State private var showLocationSearchView = false
    var body: some View {
        NavigationStack {
            Map(position: $cameraPosition, selection: $mapSelection) {
                Annotation("Location", coordinate: .myLocation) {
                    ZStack {
                        Circle()
                            .frame(width: 32, height: 32)
                            .foregroundColor(.blue)
                    }
                }
                ForEach(searchResults, id: \.self) {mapItem in
                    if routeDisplaying {
                        if mapItem == routeDestination {
                            let placemark = mapItem.placemark
                            Marker(placemark.name ?? "Place", coordinate:
                                   placemark.coordinate)
                                    .tint(.blue)
                        }
                    } else {
                        let placemark = mapItem.placemark
                        Marker(placemark.name ?? "Place", coordinate: placemark.coordinate)
                            .tint(.blue)
                    }
                }
                
                if let route {
                    MapPolyline(route.polyline)
                        .stroke(.blue, lineWidth: 7)
                }
                
                UserAnnotation()
            }
            
            .mapControls {
                MapCompass()
                MapUserLocationButton()
                MapPitchButton()
            }
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
            //Search Bar
            .searchable(text: $searchText, isPresented: $showSearch)
            //Toolbar
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbar(routeDisplaying ? .hidden : .visible, for: .navigationBar)
            .sheet(isPresented: $showDetails) {
                withAnimation(.snappy) {
                    if let boundingRect = route?.polyline.boundingMapRect,
                       routeDisplaying {
                        cameraPosition = .rect(boundingRect)
                    }
                }
            } content: {
                MapDetails()
                    .presentationDetents([.height(300)])
                    .presentationBackgroundInteraction(.enabled(upThrough:
                            .height(300)))
                    .presentationCornerRadius(25)
                    .interactiveDismissDisabled(true)
            }
            .safeAreaInset(edge: .bottom) {
                if routeDisplaying {
                    Button("End Route") {
                        withAnimation(.snappy) {
                            routeDisplaying = false
                            showDetails = true
                            mapSelection = routeDestination
                            routeDestination = nil
                            route = nil
                            cameraPosition = .region(.myRegion)
                        }
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(.red.gradient, in: .rect(cornerRadius: 15))
                    .padding()
                    .background(.ultraThinMaterial)
                }
            }
        }
        .onSubmit(of: .search) {
            Task {
                guard searchText.isEmpty else {return }
                await searchPlaces
            }
        }
        .onChange(of: showSearch, initial: false) {
            if !showSearch {
                //Clearing Search Results
                searchResults.removeAll(keepingCapacity: false)
                showDetails = false
            }
        }
        .onChange(of: mapSelection) { oldValue, newValue in
            showDetails = newValue != nil
        }
        
    }
    //Map Details View
    @ViewBuilder
    func MapDetails() -> some View {
        VStack(spacing: 15) {
            Button("Get Directions", action: fetchRoute)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(.blue.gradient, in: .rect(cornerRadius: 15))
        }
        .padding(15)
    }
}

struct ScavengerHuntMapView_Previews: PreviewProvider {
    static var previews: some View {
        ScavengerHuntMapView()
    }
}

extension CLLocationCoordinate2D {
    static var myLocation: CLLocationCoordinate2D {
        return .init(latitude: 37.3346, longitude: -122.0090)
    }
}

extension MKCoordinateRegion {
    static var myRegion: MKCoordinateRegion {
        return .init(center:.myLocation, latitudinalMeters: 10000, longitudinalMeters: 10000)
    }
}

extension ScavengerHuntMapView {
    func searchPlaces() async {
        let request  = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = .myRegion
        
        let results = try? await MKLocalSearch(request: request).start()
        searchResults = results?.mapItems ?? []
    }
    
    func fetchRoute() {
        if let mapSelection {
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: .init(coordinate: .myLocation))
            request.destination = mapSelection
            Task {
                let result = try? await MKDirections(request: request).calculate()
                route = result?.routes.first
                routeDestination = mapSelection
                
                withAnimation(.easeIn) {
                    routeDisplaying = true
                    showDetails = false
                    
                }
            }
        }
    }
     
}
