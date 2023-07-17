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
    weak var delegate: DisplayingVideoStream?
    private let queue = DispatchQueue(label: "VideoStream", qos: .userInitiated)
    private let session = AVCaptureSession()
    private let filter = ImageFilter()

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
        DispatchQueue.main.async { [weak self] in
            guard let self, let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            self.delegate?.readyToDisplay(image: self.filter.apply(CIImage(cvImageBuffer: imageBuffer)))
        }
    }
}
