//
//  View.swift
//  FilteredCamera
//
//  Created by Stanislav Matvichuck on 16.07.2023.
//

import UIKit

final class View: UIView {
    let accessDeniedLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .red
        label.text = "Please visit settings and allow camera access to enable stream filtering"
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    let stream: UIImageView = {
        let image = UIImageView(frame: .zero)
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
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
    func accessDenied() {
        accessDeniedLabel.isHidden = false
    }

    func update(image: UIImage) {
        stream.image = image
        accessDeniedLabel.isHidden = true
    }

    // MARK: - Private
    private func configureLayout() {
        addSubview(accessDeniedLabel)
        addSubview(stream)

        NSLayoutConstraint.activate([
            accessDeniedLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            accessDeniedLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            accessDeniedLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9),
            stream.centerXAnchor.constraint(equalTo: centerXAnchor),
            stream.centerYAnchor.constraint(equalTo: centerYAnchor),
            stream.widthAnchor.constraint(equalTo: widthAnchor),
            stream.heightAnchor.constraint(equalTo: heightAnchor),
        ])

        stream.contentMode = .scaleAspectFill
    }

    private func configureAppearance() {
        backgroundColor = .gray
    }
}
