//
//  VideoStreamConfigurator.swift
//  FilteredCamera
//
//  Created by Stanislav Matvichuck on 16.07.2023.
//

import AVFoundation
import CoreImage
import Foundation
import UIKit

protocol DisplayingVideoStream: AnyObject {
    func readyToDisplay(image: UIImage)
    func accessDenied()
}

class VideoStreamConfigurator: NSObject {
    private static let size = UIScreen.main.bounds.size

    weak var delegate: DisplayingVideoStream?
    private let queue = DispatchQueue(label: "VideoStream", qos: .userInitiated)
    private let session = AVCaptureSession()
    private var filter: ImageFiltering

    init(delegate: DisplayingVideoStream? = nil, filter: ImageFiltering) {
        self.delegate = delegate
        self.filter = filter
    }

    // MARK: - Public
    func startDisplaying() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)

        switch status {
        case .denied:
            delegate?.accessDenied()
        case .authorized:
            configureCaptureSession()
        default:
            requestCaptureAuthorization()
        }
    }

    func update(filter: ImageFiltering) {
        self.filter = filter
    }

    // MARK: - Private
    private func requestCaptureAuthorization() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] accessGranted in
            guard accessGranted, let self else { return }
            self.configureCaptureSession()
        }
    }

    private func configureCaptureSession() {
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: queue)

        let videoDevice = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .unspecified
        )

        guard
            let videoDevice,
            let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
            session.canAddInput(videoDeviceInput),
            session.canAddOutput(output)
        else { return }

        session.beginConfiguration()
        session.addInput(videoDeviceInput)
        session.addOutput(output)
        session.sessionPreset = .hd1920x1080
        session.commitConfiguration()

        queue.async { self.session.startRunning() }
    }
}

extension VideoStreamConfigurator: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let image = CIImage(cvImageBuffer: imageBuffer)
        let filteredImage = filter.apply(image).cropped(to: image.extent)
        let rotatedImage = filteredImage.transformed(by: CGAffineTransform(rotationAngle: 3 * .pi / 2))
        let scaledImage = rotatedImage.transformToOrigin(withSize: Self.size)

        DispatchQueue.main.async { [weak self] in
            self?.delegate?.readyToDisplay(image: UIImage(ciImage: scaledImage))
        }
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
