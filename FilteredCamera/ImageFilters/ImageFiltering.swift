//
//  ImageFiltering.swift
//  FilteredCamera
//
//  Created by Stanislav Matvichuck on 17.07.2023.
//

import CoreImage

protocol ImageFiltering: CustomStringConvertible {
    func apply(_: CIImage) -> CIImage
}

struct GrayColorFilter: ImageFiltering {
    var description: String { "Gray color" }

    func apply(_ image: CIImage) -> CIImage {
        guard let filter = CIFilter(name: "CIPhotoEffectTonal", parameters: ["inputImage": image]) else { fatalError("filter creation error") }

        filter.setDefaults()

        guard let result = filter.outputImage else { fatalError("image filtering error") }

        return result
    }
}

struct GaussianBlurFilter: ImageFiltering {
    var description: String { "Gaussian blur" }

    func apply(_ image: CIImage) -> CIImage {
        guard let filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputImage": image]) else { fatalError("filter creation error") }

        filter.setDefaults()

        guard let result = filter.outputImage else { fatalError("image filtering error") }

        return result
    }
}

struct NoneFilter: ImageFiltering {
    var description: String { "None" }

    func apply(_ image: CIImage) -> CIImage {
        return image
    }
}

extension CIImage {
    func transformToOrigin(withSize size: CGSize) -> CIImage {
        let originX = extent.origin.x
        let originY = extent.origin.y
        let scaleX = size.width / extent.width
        let scaleY = size.height / extent.height
        let scale = max(scaleX, scaleY)
        return transformed(by: CGAffineTransform(translationX: -originX, y: -originY)).transformed(by: CGAffineTransform(scaleX: scale, y: scale))
    }
}
