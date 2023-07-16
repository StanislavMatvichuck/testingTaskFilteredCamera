//
//  VideoStreamConfigurator.swift
//  FilteredCamera
//
//  Created by Stanislav Matvichuck on 16.07.2023.
//

import AVFoundation
import Foundation

protocol DisplayingVideoStream: AnyObject {
    func readyToDisplay(session: AVCaptureSession)
    func accessDenied()
}

class VideoStreamConfigurator {
    weak var delegate: DisplayingVideoStream?

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
        let videoDevice = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .unspecified
        )

        let session = AVCaptureSession()
        session.beginConfiguration()

        guard
            let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!),
            session.canAddInput(videoDeviceInput),
            session.canAddOutput(output)
        else { return }

        session.addInput(videoDeviceInput)
        session.addOutput(output)
        session.sessionPreset = .high
        session.commitConfiguration()

        delegate?.readyToDisplay(session: session)

        session.startRunning()
    }
}
