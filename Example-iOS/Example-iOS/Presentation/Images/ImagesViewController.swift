//
// ImagesViewController
// Example-iOS
//
// Created by Eugene Egorov on 20 July 2018.
// Copyright (c) 2018 Eugene Egorov. All rights reserved.
//

import UIKit
import Legacy

class ImagesViewController: UIViewController, ImageLoaderDependency, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,
        ZoomTransitionDelegate {
    var imageLoader: ImageLoader!
    var input: Input!
    var output: Output!

    struct Input {
        var images: (_ completion: @escaping (Result<[URL], ImagesError>) -> Void) -> Void
    }

    struct Output {
        var selectImage: (_ images: [URL], _ index: Int, _ image: UIImage?) -> Void
    }

    @IBOutlet private var collectionView: UICollectionView!

    private var images: [URL] = []
    private var firstTime: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.registerReusableCell(ImageCell.id)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if firstTime {
            firstTime = false
            update()
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    private func update() {
        input.images { [weak self] result in
            guard let `self` = self else { return }

            self.images = result.value ?? []
            self.collectionView.reloadData()
        }
    }

    // MARK: - Collection View

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(ImageCell.id, indexPath: indexPath)
        cell.set(imageUrl: images[indexPath.item], imageLoader: imageLoader)
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let inset: CGFloat
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            inset = layout.sectionInset.left + layout.sectionInset.right + layout.minimumInteritemSpacing
        } else {
            inset = 0
        }

        let width = (collectionView.bounds.width - inset) / 2
        return CGSize(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)

        guard let cell = collectionView.cellForItem(at: indexPath) as? ImageCell else { return }

        output.selectImage(images, indexPath.item, cell.imageView.image)
        currentIndex = indexPath.item
    }

    // MARK: - Zoom Transition

    let zoomTransition: ZoomTransition? = nil
    let zoomTransitionInteractionController: UIViewControllerInteractiveTransitioning? = nil

    var currentIndex: Int = 0

    var zoomTransitionAnimatingView: UIView? {
        guard let cell = collectionView.cellForItem(at: IndexPath(item: currentIndex, section: 0)) as? ImageCell else { return nil }

        let frame = cell.imageView.convert(cell.imageView.bounds, to: nil)
        let imageView = UIImageView(image: cell.imageView.image)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.frame = frame
        imageView.backgroundColor = .clear
        return imageView
    }

    func zoomTransitionHideViews(hide: Bool) {
        guard let cell = collectionView.cellForItem(at: IndexPath(item: currentIndex, section: 0)) as? ImageCell else { return }

        cell.imageView.isHidden = hide
    }

    func zoomTransitionDestinationFrame(for view: UIView, frame: CGRect) -> CGRect {
        let attributes = collectionView.collectionViewLayout.layoutAttributesForItem(at: IndexPath(item: currentIndex, section: 0))
        let frame = collectionView.convert(attributes?.frame ?? .zero, to: nil)
        return frame
    }
}
