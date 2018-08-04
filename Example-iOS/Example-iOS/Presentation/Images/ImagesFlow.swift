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
    private let imageLoader: ImageLoader

    private let navigationController: UINavigationController
    private let imagesViewController: ImagesViewController

    init(container: DependencyInjectionContainer, imagesService: ImagesService, imageLoader: ImageLoader) {
        self.container = container
        self.imagesService = imagesService
        self.imageLoader = imageLoader

        navigationController = UINavigationController()
        navigationController.tabBarItem = UITabBarItem(title: "Images", image: nil, selectedImage: nil)

        imagesViewController = UIStoryboard(name: "Main", bundle: nil).instantiate()
        container.resolve(imagesViewController)
        imagesViewController.input = ImagesViewController.Input(images: imagesService.images)
        imagesViewController.output = ImagesViewController.Output(selectImage: gallery)

        navigationController.setViewControllers([ imagesViewController ], animated: false)
    }

    private weak var galleryViewController: GalleryViewController?

    private func gallery(images: [URL], index: Int, image: UIImage?) {
        let imageLoader: ImageLoader = self.imageLoader

        let media = images.enumerated().map { item -> GalleryMedia in
            // swiftlint:disable:next trailing_closure
            .image(GalleryMedia.Image(
                index: item.offset,
                previewImage: item.offset == index ? image : nil,
                fullImage: nil,
                fullImageLoader: { completion in
                    imageLoader.load(url: item.element, size: .zero, mode: .original) { result in
                        completion(result.map(success: { .success($0.image) }, failure: { .failure($0) }))
                    }
                }
            ))
        }

        let controller = GalleryViewController(spacing: 20)
        controller.closeTitle = "Close"
        controller.items = media
        controller.initialIndex = index
        controller.transitionController = ZoomTransitionController()
        controller.initialControlsVisibility = true
        controller.statusBarStyle = .default
        controller.setupAppearance = { appearance in
            switch appearance {
                case .gallery(let controller):
                    controller.view.backgroundColor = .white
                    controller.initialControlsVisibility = true
                case .image(let controller):
                    controller.view.backgroundColor = .white
                    controller.loadingIndicatorView.color = .orange
                    controller.titleView.backgroundColor = .white
                    controller.closeButton.setTitleColor(.orange, for: .normal)
                case .video(let controller):
                    controller.view.backgroundColor = .white
            }
        }
        controller.pageChanged = { currentIndex in
            self.imagesViewController.currentIndex = currentIndex
        }

        galleryViewController = controller
        navigationController.topViewController?.present(controller, animated: true, completion: nil)
    }
}
