//
//  View.swift
//  FilteredCamera
//
//  Created by Stanislav Matvichuck on 16.07.2023.
//

import UIKit

final class View: UIView, ContourDetectingDelegate {
    private static let buttonSize = 64.0
    private static let buttonsSpacing = 10.0

    let accessDeniedLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
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
        let space = UIView(frame: .zero)
        space.translatesAutoresizingMaskIntoConstraints = false
        space.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let parent = UIStackView(frame: .zero)
        parent.translatesAutoresizingMaskIntoConstraints = false
        parent.spacing = View.buttonsSpacing
        parent.addArrangedSubview(space)

        return parent
    }()

    let count: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.text = "0"
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    private var shapeLayer: CAShapeLayer?

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
        shapeLayer?.removeFromSuperlayer()
        shapeLayer = nil
        count.isHidden = false
        filters.arrangedSubviews[selectedFilterIndex].backgroundColor = .green
    }

    /// ContourDetectingDelegate method
    /// - Parameters:
    ///   - path: path to de drawn
    ///   - count: count of displayed paths
    func display(path: CGPath, count: Int) {
        if shapeLayer == nil {
            shapeLayer = makeShapeLayer(cgPath: path)
        } else {
            shapeLayer?.path = transformNormalizedPathToScreenCoordinates(normalizedPath: path, viewBounds: bounds)
            layer.setNeedsDisplay()
        }

        self.count.text = "\(count)"
    }

    // MARK: - Private
    private func configureLayout() {
        let filtersScroll = UIScrollView(frame: .zero)
        filtersScroll.translatesAutoresizingMaskIntoConstraints = false
        filtersScroll.addSubview(filters)

        addSubview(accessDeniedLabel)
        addSubview(stream)
        addSubview(filtersScroll)
        addSubview(count)

        NSLayoutConstraint.activate([
            accessDeniedLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            accessDeniedLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            accessDeniedLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9),

            stream.centerXAnchor.constraint(equalTo: centerXAnchor),
            stream.centerYAnchor.constraint(equalTo: centerYAnchor),
            stream.widthAnchor.constraint(equalTo: widthAnchor),
            stream.heightAnchor.constraint(equalTo: heightAnchor),

            count.centerXAnchor.constraint(equalTo: centerXAnchor),
            count.centerYAnchor.constraint(equalTo: centerYAnchor),

            filtersScroll.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9),
            filtersScroll.heightAnchor.constraint(equalTo: filters.heightAnchor),
            filtersScroll.centerXAnchor.constraint(equalTo: centerXAnchor),
            filtersScroll.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),

            filters.leadingAnchor.constraint(equalTo: filtersScroll.contentLayoutGuide.leadingAnchor),
            filters.trailingAnchor.constraint(equalTo: filtersScroll.contentLayoutGuide.trailingAnchor),
            filters.topAnchor.constraint(equalTo: filtersScroll.contentLayoutGuide.topAnchor),
            filters.bottomAnchor.constraint(equalTo: filtersScroll.contentLayoutGuide.bottomAnchor),
            filters.heightAnchor.constraint(equalTo: filtersScroll.frameLayoutGuide.heightAnchor),
        ])
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

    private func makeShapeLayer(cgPath: CGPath) -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = bounds
        shapeLayer.lineWidth = 2.0
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = UIColor.green.cgColor
        shapeLayer.path = transformNormalizedPathToScreenCoordinates(normalizedPath: cgPath, viewBounds: bounds)
        layer.addSublayer(shapeLayer)
        return shapeLayer
    }

    private func transformNormalizedPathToScreenCoordinates(normalizedPath: CGPath, viewBounds: CGRect) -> CGPath {
        let boundingBox = normalizedPath.boundingBox

        print("boundingBox.width \(boundingBox.width)")
        print("boundingBox.height \(boundingBox.height)")

        print("viewBounds.width \(viewBounds.width)")
        print("viewBounds.height \(viewBounds.height)")

        let scaleX = viewBounds.width / boundingBox.width
        let scaleY = viewBounds.height / boundingBox.height

        let translateX = (viewBounds.width - boundingBox.width * scaleX) / 2.0
        let translateY = (viewBounds.height - boundingBox.height * scaleY) / 2.0

        var transform = CGAffineTransform.identity
        transform = transform.scaledBy(x: scaleX, y: scaleY)
        transform = transform.translatedBy(x: translateX, y: translateY)

        if let transformedPath = normalizedPath.copy(using: &transform) {
            return transformedPath
        } else {
            return normalizedPath
        }
    }
}
