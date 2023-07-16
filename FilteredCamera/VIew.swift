//
//  View.swift
//  FilteredCamera
//
//  Created by Stanislav Matvichuck on 16.07.2023.
//

import AVFoundation
import UIKit

final class View: UIView {
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }

    private var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }

    let accessDeniedLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Please visit settings and allow camera access to enable stream filtering"
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    init() {
        super.init(frame: .zero)
        configureLayout()
        configureAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public
    func allowCapturing(for session: AVCaptureSession) {
        videoPreviewLayer.session = session
        accessDeniedLabel.isHidden = true
    }

    func accessDenied() {
        accessDeniedLabel.isHidden = false
    }

    // MARK: - Private
    private func configureLayout() {
        addSubview(accessDeniedLabel)

        NSLayoutConstraint.activate([
            accessDeniedLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            accessDeniedLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            accessDeniedLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9),
        ])

        videoPreviewLayer.videoGravity = .resizeAspectFill
    }

    private func configureAppearance() {
        backgroundColor = .red
    }
}
