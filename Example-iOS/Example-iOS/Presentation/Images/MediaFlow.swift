//
// MediaFlow
// Example-iOS
//
// Created by Eugene Egorov on 19 July 2018.
// Copyright (c) 2018 Eugene Egorov. All rights reserved.
//

import UIKit
import Legacy

class MediaFlow {
    var viewController: UIViewController {
        return navigationController
    }

    private let container: DependencyInjectionContainer
    private let mediaService: MediaService
    private let imageLoader: ImageLoader

    private let navigationController: UINavigationController
    private let mediaViewController: MediaViewController

    init(container: DependencyInjectionContainer, mediaService: MediaService, imageLoader: ImageLoader) {
        self.container = container
        self.mediaService = mediaService
        self.imageLoader = imageLoader

        mediaViewController = UIStoryboard(name: "Main", bundle: nil).instantiate()

        navigationController = UINavigationController(rootViewController: mediaViewController)
        navigationController.tabBarItem = UITabBarItem(title: "Media", image: nil, selectedImage: nil)

        container.resolve(mediaViewController)
        mediaViewController.input = MediaViewController.Input(media: mediaService.media)
        mediaViewController.output = MediaViewController.Output(selectMedia: gallery)
    }

    private func gallery(media: [Media], index: Int, image: UIImage?) {
        let imageLoader: ImageLoader = self.imageLoader

        let media = media.enumerated().map { item -> GalleryMedia in
            switch item.element {
                case .image(let url):
                    return .image(GalleryMedia.Image(
                        previewImage: item.offset == index ? image : nil,
                        previewImageLoader: { size, completion in
                            imageLoader.load(url: url, size: size, mode: .fill) { result in
                                completion(result.map(success: { .success($0.image) }, failure: { .failure($0) }))
                            }
                        },
                        fullImage: nil,
                        fullImageLoader: { completion in
                            imageLoader.load(url: url, size: .zero, mode: .original) { result in
                                completion(result.map(success: { .success($0.image) }, failure: { .failure($0) }))
                            }
                        }
                    ))
                case .video(let url, let thumbnail):
                    return .video(GalleryMedia.Video(
                        url: nil,
                        previewImage: item.offset == index ? image : nil,
                        previewImageLoader: thumbnail.map { thumbnail in
                            return { size, completion in
                                imageLoader.load(url: thumbnail, size: size, mode: .fill) { result in
                                    completion(result.map(success: { .success($0.image) }, failure: { .failure($0) }))
                                }
                            }
                        },
                        videoLoader: { completion in
                            if url.scheme == "app" {
                                let path = url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
                                let localUrl = Bundle.main.url(forResource: path, withExtension: nil)
                                completion(Result(localUrl, MediaError.unknown(nil)))
                            } else if let scheme = url.scheme, let directory = Storage.schemeDirectories[scheme] {
                                let path = url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
                                let localUrl = directory.appendingPathComponent(path)
                                completion(.success(localUrl))
                            } else {
                                completion(.success(url))
                            }
                        }
                    ))
            }
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
                    return GalleryLightVideoViewController()
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
            self?.mediaViewController.currentIndex = currentIndex
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
