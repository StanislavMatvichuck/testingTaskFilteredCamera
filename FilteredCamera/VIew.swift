//
//  View.swift
//  FilteredCamera
//
//  Created by Stanislav Matvichuck on 16.07.2023.
//

import UIKit

final class View: UIView {
    init() {
        super.init(frame: .zero)
        configureAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureAppearance() {
        backgroundColor = .red
    }
}
