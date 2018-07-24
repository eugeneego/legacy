//
// ImagesFlow
// Example-iOS
//
// Created by Eugene Egorov on 19 July 2018.
// Copyright (c) 2018 Eugene Egorov. All rights reserved.
//

import UIKit
import Legacy

class ImagesFlow {
    var viewController: UIViewController {
        return navigationController
    }

    private let container: DependencyInjectionContainer
    private let imagesService: ImagesService

    private let navigationController: UINavigationController
    private let imagesViewController: ImagesViewController

    init(container: DependencyInjectionContainer, imagesService: ImagesService) {
        self.container = container
        self.imagesService = imagesService

        imagesViewController = UIStoryboard(name: "Main", bundle: nil).instantiate()
        container.resolve(imagesViewController)
        // swiftlint:disable:next trailing_closure
        imagesViewController.input = ImagesViewController.Input(
            images: { completion in
            }
        )
        // swiftlint:disable:next trailing_closure
        imagesViewController.output = ImagesViewController.Output(
            selectImage: { url, imageView in
            }
        )

        navigationController = UINavigationController()
        navigationController.tabBarItem = UITabBarItem(title: "Images", image: nil, selectedImage: nil)
        navigationController.setViewControllers([ imagesViewController ], animated: false)
    }
}
