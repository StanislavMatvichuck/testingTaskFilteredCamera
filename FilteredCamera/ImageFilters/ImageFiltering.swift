//
//  ImageFiltering.swift
//  FilteredCamera
//
//  Created by Stanislav Matvichuck on 17.07.2023.
//

import CoreImage
import UIKit

protocol ImageFiltering: CustomStringConvertible {
    func apply(_: CIImage) -> CIImage
}

struct PngMaskFilter: ImageFiltering {
    var description: String { "Png mask" }

    func apply(_ image: CIImage) -> CIImage {
        let maskSource = UIImage(named: "Mask")!

        let rotation = CGAffineTransform(rotationAngle: 1 * .pi / 2)
        let translate = CGAffineTransform(translationX: 1920, y: 0)

        let maskImage = CIImage(cgImage: maskSource.cgImage!)
        let rotatedMaskImage = maskImage.transformed(by: rotation.concatenating(translate))

        guard let inversionFilter = CIFilter(name: "CIColorInvert", parameters: ["inputImage": image]) else { fatalError("filter creation error") }
        let invertedImage = inversionFilter.outputImage!

        guard let filter = CIFilter(
            name: "CIBlendWithMask",
            parameters: [
                "inputImage": image,
                "inputBackgroundImage": invertedImage,
                "inputMaskImage": rotatedMaskImage,
            ]
        ) else { fatalError("filter creation error") }

        filter.setDefaults()

        guard let result = filter.outputImage else { fatalError("image filtering error") }

        return result
    }
}

struct PixellateFilter: ImageFiltering {
    var description: String { "Pixellate" }

    func apply(_ image: CIImage) -> CIImage {
        guard let filter = CIFilter(name: "CIPixellate", parameters: ["inputImage": image]) else { fatalError("filter creation error") }

        filter.setDefaults()

        guard let result = filter.outputImage else { fatalError("image filtering error") }

        return result
    }
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
