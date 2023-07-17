//
//  VideoStreamConfigurator.swift
//  FilteredCamera
//
//  Created by Stanislav Matvichuck on 16.07.2023.
//

import AVFoundation
import CoreImage
import Foundation

protocol DisplayingVideoStream: AnyObject {
    func accessDenied()
    func readyToDisplay(image: CIImage)
}

class VideoStreamConfigurator: NSObject {
    weak var delegate: DisplayingVideoStream?
    private let queue = DispatchQueue(label: "VideoStream", qos: .userInitiated)
    private let session = AVCaptureSession()

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
        session.sessionPreset = .high
        session.commitConfiguration()

        queue.async { self.session.startRunning() }
    }
}

extension VideoStreamConfigurator: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        DispatchQueue.main.async { [weak self] in
            let image = CIImage(cvImageBuffer: imageBuffer)
            let rotatedImage = image.transformed(by: CGAffineTransform(rotationAngle: 3 * .pi / 2))
            self?.delegate?.readyToDisplay(image: rotatedImage)
        }
    }
}
