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

        imagesViewController = UIStoryboard(name: "Main", bundle: nil).instantiate()

        navigationController = UINavigationController(rootViewController: imagesViewController)
        navigationController.tabBarItem = UITabBarItem(title: "Images", image: nil, selectedImage: nil)

        container.resolve(imagesViewController)
        imagesViewController.input = ImagesViewController.Input(images: imagesService.images)
        imagesViewController.output = ImagesViewController.Output(selectImage: gallery)
    }

    private func gallery(images: [URL], index: Int, image: UIImage?) {
        let imageLoader: ImageLoader = self.imageLoader

        let media = images.enumerated().map { item -> GalleryMedia in
            .image(GalleryMedia.Image(
                previewImage: item.offset == index ? image : nil,
                previewImageLoader: { size, completion in
                    imageLoader.load(url: item.element, size: size, mode: .fill) { result in
                        completion(result.map(success: { .success($0.image) }, failure: { .failure($0) }))
                    }
                },
                fullImage: nil,
                fullImageLoader: { completion in
                    imageLoader.load(url: item.element, size: .zero, mode: .original) { result in
                        completion(result.map(success: { .success($0.image) }, failure: { .failure($0) }))
                    }
                }
            ))
        }

        let previewView = createGalleryPreview()

        let controller = GalleryViewController(spacing: 20)
        controller.items = media
        controller.initialIndex = index
        controller.transitionController = ZoomTransitionController()
        controller.sharedControls = true
        controller.availableControls = [ .close, .share ]
        controller.initialControlsVisibility = true
        controller.statusBarStyle = .default
        controller.viewerForItem = { item in
            switch item {
                case .image:
                    return GalleryImageViewController()
                case .video:
                    return GalleryVideoViewController()
            }
        }
        controller.setupAppearance = { appearance in
            switch appearance {
                case .gallery(let controller):
                    controller.initialControlsVisibility = true
                    controller.view.backgroundColor = .white
                    controller.titleView.backgroundColor = .white
                    controller.closeButton.setTitleColor(.orange, for: .normal)
                    controller.shareButton.setTitleColor(.orange, for: .normal)

                    previewView.translatesAutoresizingMaskIntoConstraints = false
                    controller.view.addSubview(previewView)
                    NSLayoutConstraint.activate([
                        previewView.leadingAnchor.constraint(equalTo: controller.view.leadingAnchor),
                        previewView.trailingAnchor.constraint(equalTo: controller.view.trailingAnchor),
                        previewView.bottomAnchor.constraint(equalTo: controller.bottomLayoutGuide.topAnchor),
                        previewView.heightAnchor.constraint(equalToConstant: 80),
                    ])
                    previewView.items = controller.items
                case .item(let controller):
                    controller.view.backgroundColor = .white
                    controller.loadingIndicatorView.color = .orange
                    controller.titleView.backgroundColor = .white
                    controller.closeButton.setTitleColor(.orange, for: .normal)
                    controller.shareButton.setTitleColor(.orange, for: .normal)
            }
        }
        previewView.selectAction = { [weak controller, weak previewView] index in
            controller?.move(to: index, animated: true)
            previewView?.selectItem(at: index, animated: true)
        }
        controller.pageChanged = { [weak self] currentIndex in
            self?.imagesViewController.currentIndex = currentIndex
            previewView.selectItem(at: currentIndex, animated: true)
        }
        controller.viewAppeared = { controller in
            previewView.selectItem(at: controller.currentIndex, animated: true)
        }
        controller.controlsVisibilityChanged = { controlsVisibility in
            previewView.alpha = controlsVisibility ? 1 : 0
        }

        navigationController.topViewController?.present(controller, animated: true, completion: nil)
    }

    private func createGalleryPreview() -> GalleryPreviewCollectionView {
        let previewView = GalleryPreviewCollectionView()
        previewView.layout.itemSize = CGSize(width: 48, height: 64)
        previewView.layout.minimumInteritemSpacing = 4
        previewView.layout.minimumLineSpacing = 4
        previewView.layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        previewView.backgroundColor = .clear
        previewView.clipsToBounds = false
        previewView.cellSetup = { cell in
            cell.clipsToBounds = false
            cell.contentView.clipsToBounds = false

            if cell.selectedBackgroundView == nil {
                let view = UIView()
                view.clipsToBounds = false
                view.backgroundColor = .white
                view.layer.shadowRadius = 8
                view.layer.shadowOffset = CGSize(width: 0, height: 4)
                view.layer.shadowColor = UIColor.black.cgColor
                view.layer.shadowOpacity = 0.5
                cell.selectedBackgroundView = view
            }
        }
        return previewView
    }
}
