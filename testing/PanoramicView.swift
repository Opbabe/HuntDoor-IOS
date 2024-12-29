//
//  PanoramicView.swift
//  X
//
//  Created by Nick Tran on 5/4/24.
//

import SwiftUI

struct PanoramicView: View {
   // let image: UIImage
   // var images: [String]
    
    @State private var location: CGPoint = .zero
    //let pImage: PanoramicImage
   // let library: PanoramicLibrary
    let pImage: PanoramicImage
    @State private var walked: Bool = false
    @State private var walkDirection: Int = 0
    var body: some View {
        
        
        ScrollView(.horizontal) {
            
            SwiftUI.Group {
                VStack {
                    if walked {
                        PanoramicView(pImage: pImage.images[walkDirection])
                    } else {
                        Image(uiImage: self.pImage.image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: pImage.image.size.width)
                            .onTapGesture { location in
                                self.location = location
                                print("Tapped at \(location)")
                                if location.x < 818.75 {
                                    print("1")
                                    walkDirection = 0;
                                    walked.toggle()
                                } else if location.x < 2*818.75 {
                                    print("2")
                                } else if location.x < 3*818.75 {
                                    print("3")
                                } else {
                                    print("4")
                                }
                            }
                    }
                }
            }
            }
    }
}


