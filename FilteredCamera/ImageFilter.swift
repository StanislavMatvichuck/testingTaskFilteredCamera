//
//  File.swift
//  FilteredCamera
//
//  Created by Stanislav Matvichuck on 17.07.2023.
//

import CoreImage
import UIKit

struct ImageFilter {
    private static let size = UIScreen.main.bounds.size

    func apply(_ image: CIImage) -> UIImage {
        guard let filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputImage": image]) else { fatalError("filter creation error") }
        filter.setDefaults()

        let filteredImage = filter.outputImage!.cropped(to: image.extent)
        let rotatedImage = filteredImage.transformed(by: CGAffineTransform(rotationAngle: 3 * .pi / 2))
        let scaledImage = rotatedImage.transformToOrigin(withSize: Self.size)

        return UIImage(ciImage: scaledImage)
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
