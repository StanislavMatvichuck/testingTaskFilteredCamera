//
//  ViewController.swift
//  FilteredCamera
//
//  Created by Stanislav Matvichuck on 16.07.2023.
//

import AVFoundation
import UIKit

final class ViewController: UIViewController {
    let rootView: View
    let streamConfigurator: VideoStreamConfigurator
    let filtersList: FiltersList

    init() {
        let contourDetectingFilter = ContourDetectingFilter()

        let filtersList = FiltersList([
            NoneFilter(),
            GaussianBlurFilter(),
            GrayColorFilter(),
            PixellateFilter(),
            PngMaskFilter(),
            contourDetectingFilter
        ])

        let configurator = VideoStreamConfigurator(filter: filtersList.activeFilter)
        let view = View(
            buttons: filtersList.availableFiltersNames,
            selectedButtonIndex: filtersList.selectedFilterIndex
        )
        contourDetectingFilter.delegate = view

        self.streamConfigurator = configurator
        self.rootView = view
        self.filtersList = filtersList

        super.init(nibName: nil, bundle: nil)
        configurator.delegate = self
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func loadView() { view = rootView }
    override func viewDidLoad() {
        configureButtonsHandlers()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        streamConfigurator.startDisplaying()
    }

    private func configureButtonsHandlers() {
        for view in rootView.filters.arrangedSubviews {
            guard let button = view as? UIButton else { return }
            button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        }
    }

    @objc func handleTap(_ button: UIButton) {
        guard
            let name = button.titleLabel?.text,
            let newSelectedFilterIndex = filtersList.index(forFilterName: name),
            let filter = filtersList.filter(byName: name)
        else { return }

        streamConfigurator.update(filter: filter)
        rootView.update(selectedFilterIndex: newSelectedFilterIndex)
    }
}

extension ViewController: DisplayingVideoStream {
    func readyToDisplay(image: UIImage) {
        rootView.update(image: image)
    }

    func accessDenied() {
        rootView.accessDenied()
    }
}
