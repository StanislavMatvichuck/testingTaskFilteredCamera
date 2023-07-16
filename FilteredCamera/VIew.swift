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

    init() {
        super.init(frame: .zero)
        configureAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public
    func allowCapturing(for session: AVCaptureSession) {
        videoPreviewLayer.session = session
        videoPreviewLayer.videoGravity = .resizeAspectFill
    }

    // MARK: - Private
    private func configureAppearance() {
        backgroundColor = .red
    }
}
