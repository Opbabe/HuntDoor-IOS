import SwiftUI
import MapKit
import CoreLocation

struct AMapView: View {
    @State private var cameraPosition: MapCameraPosition = .region(.myRegion)
    @Namespace private var locationSpace
    @State private var searchText: String = ""
    @State private var showSearch: Bool = false
    @State private var searchResults: [MKMapItem] = []
    @State private var mapSelection: MKMapItem?
    @State private var showDetails: Bool = false
    @State private var routeDisplaying: Bool = false
    @State private var route: MKRoute?
    @State private var routeDestination: MKMapItem?

    var body: some View {
        NavigationStack {
            Map(position: $cameraPosition, selection: $mapSelection, scope: locationSpace) {
                Annotation("Location", coordinate: .myLocation) {
                    ZStack {
                        Circle()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.blue)
                    }
                }
                .annotationTitles(.hidden)
                
                ForEach(searchResults, id: \.self) { mapItem in
                    if routeDisplaying {
                        if mapItem == routeDestination {
                            let placemark = mapItem.placemark
                            Marker(placemark.name ?? "Place", coordinate: placemark.coordinate)
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
            .overlay(alignment: .bottomTrailing) {
                VStack(spacing: 15) {
                    MapCompass(scope: locationSpace)
                    MapUserLocationButton(scope: locationSpace)
                }
            }
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, isPresented: $showSearch)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbar(routeDisplaying ? .hidden : .visible, for: .navigationBar)

            .sheet(isPresented: $showDetails) {
                // MapDetailsView() or some other content
            } content: {
                MapDetails()
                    .presentationDetents([.height(300)])
                    .presentationBackgroundInteraction(.enabled(upThrough:
                            .height(300)))
                    .presentationCornerRadius(25)
                    .interactiveDismissDisabled(true)
            }
        }
        .onSubmit(of: .search) {
            Task {
                guard !searchText.isEmpty else { return }
                await searchPlaces()
            }
        }
        .onChange(of: showSearch, initial: false) {
            if !showSearch {
                //Clearing Search Results
                searchResults.removeAll(keepingCapacity: false)
                //showDetails = false
            }
        }
        
        .onChange(of: mapSelection) { oldValue, newValue in
            showDetails = newValue != nil
        }
    }
    
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

    func searchPlaces() async {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = .myRegion
        
        let results = try? await MKLocalSearch(request: request).start()
        searchResults = results?.mapItems ?? []
        // Implement handling of `results` here.
    }
    
    func fetchRoute() {
        if let mapSelection = mapSelection {
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: .myLocation))
            request.destination = mapSelection
            request.transportType = .walking  // Set transport type to walking

            Task {
                do {
                    let result = try await MKDirections(request: request).calculate()
                    if let firstRoute = result.routes.first {
                        withAnimation(.easeIn) {
                            route = firstRoute
                            routeDestination = mapSelection
                            routeDisplaying = true
                            showDetails = false
                        }
                    }
                } catch {
                    print("Failed to fetch directions:", error)
                }
            }
        }
    }
}

struct AMapView_Previews: PreviewProvider {
    static var previews: some View {
        AMapView()
    }
}

extension CLLocationCoordinate2D {
    static var myLocation: CLLocationCoordinate2D {
        return .init(latitude: 37.33629807996933, longitude: -121.88149806067068)
    }
}

extension MKCoordinateRegion {
    static var myRegion: MKCoordinateRegion {
        return .init(center: .myLocation, latitudinalMeters: 500, longitudinalMeters: 500)
    }
}



