//
//  ContentView.swift
//  testing
//
//  Created by Linh Ngoc My Truong on 2/6/24.
//

import SwiftUI
import MapKit

struct ContentView: View {
    let tower = CLLocationCoordinate2D(
        latitude: 37.33543869042343,
        longitude: -121.8835121183419)
    let library = CLLocationCoordinate2D(
        latitude: 37.33560929984678,
        longitude: -121.88501415529467)
    let studentUnion = CLLocationCoordinate2D(
        latitude: 37.33629807996933,
        longitude: -121.88149806067068)
    
    @State private var showPickerModal = false // State to control visibility of the modal
    
    var body: some View {
        VStack {
            Map() {
                Marker("Tower Lawn", coordinate: tower).tint(.blue)
                Marker("MLK Library", coordinate: library).tint(.yellow)
                Marker("Student Union", coordinate: studentUnion)
            }
            
            Button(action: {
                // Show the modal with the Picker
                self.showPickerModal = true
            }) {
                Text("Play Game")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
        }
        .sheet(isPresented: $showPickerModal) {
            // Modal content
            LocationPickerModalView(showModal: $showPickerModal)
        }
    }
}

struct LocationPickerModalView: View {
    @Binding var showModal: Bool
    let locations = ["Tower Lawn", "MLK Library", "Student Union"]
    @State private var selectedLocation = "Tower Lawn"
    @State private var isCorrect = false
    @State private var hasSelectionBeenMade = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Select a location")
                .font(.headline)
            Text("North West")
                .font(.headline)
            
            Picker("Select a location", selection: $selectedLocation) {
                ForEach(locations, id: \.self) { location in
                    Text(location).tag(location)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .onChange(of: selectedLocation) { newValue in
                isCorrect = (newValue == "MLK Library")
                hasSelectionBeenMade = true
            }
            
            if hasSelectionBeenMade {
                Text("\(selectedLocation)")
                    .padding()
                    .background(isCorrect ? Color.green : Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(5)
            }
            
            Button("Done") {
                showModal = false
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
        .edgesIgnoringSafeArea(.all)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
