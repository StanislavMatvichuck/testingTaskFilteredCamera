//
//  ViewController.swift
//  FilteredCamera
//
//  Created by Stanislav Matvichuck on 16.07.2023.
//

import AVFoundation
import UIKit

final class ViewController: UIViewController {
    let rootView = View()

    override func loadView() { view = rootView }
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureCapturePermissions()
    }

    private func configureCapturePermissions() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)

        switch status {
        case .denied:
            displayDeniedAlert()
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

        rootView.allowCapturing(for: session)

        session.startRunning()
    }

    private func displayDeniedAlert() {
        let alert = UIAlertController(
            title: "Camera access denied",
            message: "Please allow camera usage in settings",
            preferredStyle: .alert
        )

        present(alert, animated: true)
    }
}
