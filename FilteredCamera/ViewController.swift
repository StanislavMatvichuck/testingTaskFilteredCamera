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

    lazy var streamConfigurator: VideoStreamConfigurator = {
        let configurator = VideoStreamConfigurator()
        configurator.delegate = self
        return configurator
    }()

    override func loadView() { view = rootView }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        streamConfigurator.startDisplaying()
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
