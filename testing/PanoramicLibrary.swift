//
//  PanoramicLibrary.swift
//  X
//
//  Created by Eric Nguyen on 5/5/24.
//

import SwiftUI

class PanoramicLibrary {
    var images: [PanoramicImage]

    init(_ images: [PanoramicImage]) {
        self.images = images
        self.images.append(PanoramicImage(image: UIImage(named: "IMG_1440")!, images: []))
        self.images.append(PanoramicImage(image: UIImage(named: "IMG_1439")!, images: []))
        self.images[0].add(self.images[1])
        self.images[1].add(self.images[0])
    }
    
    func walkTo(_ i: Int) {
    }
    
    func add(_ pImage: PanoramicImage) {
        if images.count < 5 {
            images.append(pImage)
        }
        
    }
}

