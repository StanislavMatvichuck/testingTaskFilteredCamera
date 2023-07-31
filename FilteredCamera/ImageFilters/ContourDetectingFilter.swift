//
//  ContourDetectingFilter.swift
//  FilteredCamera
//
//  Created by Stanislav Matvichuck on 21.07.2023.
//

import CoreImage
import Foundation
import UIKit
import Vision

protocol ContourDetectingDelegate {
    func display(path: CGPath, count: Int)
}

class ContourDetectingFilter: ImageFiltering {
    var description: String { "Contour detecting" }

    weak var delegate: (AnyObject & ContourDetectingDelegate)?

    func apply(_ image: CIImage) -> CIImage {
        guard let filter = CIFilter(
            name: "CIGloom",
            parameters: [
                "inputImage": image,
                "inputRadius": 8.0,
                "inputIntensity": 1.0
            ]
        ) else { fatalError("filter creation error") }

        let visionInputImage = filter.outputImage!
        let observationRequestHandler = VNImageRequestHandler(
            ciImage: image,
            orientation: .rightMirrored,
            options: [:]
        )

        let contourDetectionRequest = VNDetectContoursRequest { [weak self] request, error in
            guard error == nil else { fatalError("\(error!.localizedDescription)") }
            guard
                let self,
                let observation = (request.results as? [VNContoursObservation])?.first
            else { return }

            DispatchQueue.main.async {
                self.delegate?.display(
                    path: observation.normalizedPath,
                    count: observation.contourCount
                )
            }
        }

        do {
            contourDetectionRequest.maximumImageDimension = 300
//            contourDetectionRequest.contrastAdjustment = 3.0
            try observationRequestHandler.perform([contourDetectionRequest])
        } catch let error as NSError {
            print("Failed to perform image request: \(error)")
        }

        return image
    }
}
