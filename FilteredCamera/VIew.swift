//
//  View.swift
//  FilteredCamera
//
//  Created by Stanislav Matvichuck on 16.07.2023.
//

import UIKit

final class View: UIView {
    private static let buttonSize = 64.0
    private static let buttonsSpacing = 10.0

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

    let filters: UIStackView = {
        let parent = UIStackView(frame: .zero)
        parent.translatesAutoresizingMaskIntoConstraints = false
        parent.spacing = View.buttonsSpacing

        let space = UIView(frame: .zero)
        space.translatesAutoresizingMaskIntoConstraints = false
        space.setContentHuggingPriority(.defaultLow, for: .horizontal)

        parent.addArrangedSubview(space)

        return parent
    }()

    init(buttons: [String], selectedButtonIndex: Int) {
        super.init(frame: .zero)
        configure(buttons: buttons, selectedButtonIndex)
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

    func update(selectedFilterIndex: Int) {
        removeSelectionFromAllFilters()

        filters.arrangedSubviews[selectedFilterIndex].backgroundColor = .green
    }

    // MARK: - Private
    private func configureLayout() {
        addSubview(accessDeniedLabel)
        addSubview(stream)
        addSubview(filters)

        NSLayoutConstraint.activate([
            accessDeniedLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            accessDeniedLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            accessDeniedLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9),

            stream.centerXAnchor.constraint(equalTo: centerXAnchor),
            stream.centerYAnchor.constraint(equalTo: centerYAnchor),
            stream.widthAnchor.constraint(equalTo: widthAnchor),
            stream.heightAnchor.constraint(equalTo: heightAnchor),

            filters.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9),
            filters.centerXAnchor.constraint(equalTo: centerXAnchor),
            filters.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
        ])

        stream.contentMode = .scaleAspectFill
    }

    private func configureAppearance() {
        backgroundColor = .gray
    }

    private func configure(buttons: [String], _ selectedButtonIndex: Int) {
        for title in buttons.reversed() {
            let button = Self.makeFilterButton(text: title)
            filters.insertArrangedSubview(button, at: 0)
        }

        for (index, view) in filters.arrangedSubviews.enumerated() {
            if index == selectedButtonIndex {
                view.backgroundColor = .green
            }
        }
    }

    private static func makeFilterButton(text: String) -> UIButton {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: Self.buttonsSpacing, bottom: 0, right: Self.buttonsSpacing)
        button.heightAnchor.constraint(equalToConstant: Self.buttonSize).isActive = true
        button.layer.cornerRadius = 10
        button.backgroundColor = .white
        button.setTitle(text, for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.titleLabel?.textAlignment = .center
        return button
    }

    private func removeSelectionFromAllFilters() {
        for view in filters.arrangedSubviews where view is UIButton {
            view.backgroundColor = .white
        }
    }
}
