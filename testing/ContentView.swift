import SwiftUI
import MapKit

struct ContentView: View {
    @State var level = 1 // Changed from private to public
    @State private var showGuessResult = false
    @State private var guessResultTitle = ""
    @State private var showHintModal = true
    @State private var region: MKCoordinateRegion
    @State private var userGuessLocation: CLLocationCoordinate2D?
    @State private var annotations: [LocationAnnotation] = []

    @State private var showMapView = false

    let locations = [
        CLLocationCoordinate2D(latitude: 37.33629807996933, longitude: -121.88149806067068), // Student Union
        CLLocationCoordinate2D(latitude: 37.335289, longitude: -121.884695) // MLK Library
    ]

    init() {
        _region = State(initialValue: MKCoordinateRegion(center: locations[0], span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)))
    }

    var body: some View {
        VStack {
            Text("Here is level 1 hint!").font(.headline).padding()
            Text("Level \(level)").font(.subheadline).padding()

            CustomMapView(region: $region, annotations: $annotations, onTap: { coordinate in
                self.placeGuess(coordinate)
            })

            Button("Guess Location") {
                if let userGuessLocation = userGuessLocation {
                    calculateDistanceFromGuessToActual(guessLocation: userGuessLocation)
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(userGuessLocation == nil)
            .alert(isPresented: $showGuessResult) {
                Alert(title: Text(guessResultTitle), dismissButton: .default(Text("Next Level")) {
                    goToNextLevel()
                })
            }

            Button("Need a hint?") {
                self.showHintModal = true
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)

            Button("Open Map") {
                showMapView = true
            }
            .padding()
            .background(Color.purple)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .sheet(isPresented: $showHintModal) {
            HintModalView(imageName: level == 1 ? "StudentUnionpic" : "mlkLib", showModal: $showHintModal, level: level)
        }
        .sheet(isPresented: $showMapView) {
            AMapView()
        }
    }

    func placeGuess(_ coordinate: CLLocationCoordinate2D) {
        annotations.removeAll(where: { $0.name == "Your Guess" })
        let newAnnotation = LocationAnnotation(name: "Your Guess", coordinate: coordinate)
        annotations.append(newAnnotation)
        userGuessLocation = coordinate
    }

    func calculateDistanceFromGuessToActual(guessLocation: CLLocationCoordinate2D) {
        let guessLocation = CLLocation(latitude: guessLocation.latitude, longitude: guessLocation.longitude)
        let actualLocation = CLLocation(latitude: locations[level - 1].latitude, longitude: locations[level - 1].longitude)
        let distance = guessLocation.distance(from: actualLocation)
        if distance < 50 {
            guessResultTitle = "Correct! You're just \(Int(distance)) meters away!"
        } else {
            guessResultTitle = "Not quite. You're \(Int(distance)) meters away."
        }
        showGuessResult = true
    }

    func goToNextLevel() {
        if level < locations.count {
            level += 1
            region = MKCoordinateRegion(center: locations[level - 1], span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003))
            userGuessLocation = nil
            annotations.removeAll()
            showHintModal = true
        }
    }
}

struct LocationAnnotation: Identifiable {
    let id = UUID()
    var name: String
    var coordinate: CLLocationCoordinate2D
}

struct CustomMapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var annotations: [LocationAnnotation]
    var onTap: (CLLocationCoordinate2D) -> Void

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        let longTapGesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleLongTapGesture(_:)))
        mapView.addGestureRecognizer(longTapGesture)
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setRegion(region, animated: true)
        uiView.removeAnnotations(uiView.annotations)
        let newAnnotations = annotations.map { location in
            let mkAnnotation = MKPointAnnotation()
            mkAnnotation.coordinate = location.coordinate
            mkAnnotation.title = location.name
            return mkAnnotation
        }
        uiView.addAnnotations(newAnnotations)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onTap: onTap)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var onTap: (CLLocationCoordinate2D) -> Void

        init(onTap: @escaping (CLLocationCoordinate2D) -> Void) {
            self.onTap = onTap
        }

        @objc func handleLongTapGesture(_ gesture: UILongPressGestureRecognizer) {
            if gesture.state == .began {
                let locationInView = gesture.location(in: gesture.view)
                let coordinate = (gesture.view as! MKMapView).convert(locationInView, toCoordinateFrom: gesture.view)
                onTap(coordinate)
            }
        }
    }
}

struct HintModalView: View {
    var imageName: String
    @Binding var showModal: Bool
    var level: Int

    var body: some View {
        VStack {
            Text(level == 1 ? "Hey welcome! here is your hint for level 1" : "Here is the hint for level 2!").font(.headline).padding()
            Image(imageName).resizable().aspectRatio(contentMode: .fit).padding()
            Button("Close") {
                self.showModal = false
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}




