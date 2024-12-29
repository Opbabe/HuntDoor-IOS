


import SwiftUI

class PanoramicImage {
    var image: UIImage
    var images: [PanoramicImage]

    init(image: UIImage, images: [PanoramicImage]) {
        self.image = image
        self.images = images
    }
    
    
    func add(_ pImage: PanoramicImage) {
        if images.count < 5 {
            images.append(pImage)
        }
        
    }
}
