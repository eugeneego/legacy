//
// MediaViewController
// Example-iOS
//
// Created by Eugene Egorov on 20 July 2018.
// Copyright (c) 2018 Eugene Egorov. All rights reserved.
//

import UIKit
import Legacy

class MediaViewController: ViewController, ImageLoaderDependency,
        UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ZoomTransitionDelegate {
    var imageLoader: ImageLoader!
    var input: Input!
    var output: Output!

    struct Input {
        var media: (_ completion: @escaping (Result<[Media], MediaError>) -> Void) -> Void
    }

    struct Output {
        var selectMedia: (_ media: [Media], _ index: Int, _ image: UIImage?) -> Void
    }

    @IBOutlet private var collectionView: UICollectionView!

    private var media: [Media] = []
    private var firstTime: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.registerReusableCell(MediaCell.id)
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
        input.media { [weak self] result in
            guard let `self` = self else { return }

            self.media = result.value ?? []
            self.collectionView.reloadData()
        }
    }

    // MARK: - Collection View

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return media.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(MediaCell.id, indexPath: indexPath)
        switch media[indexPath.item] {
            case .image(let url):
                cell.set(imageUrl: url, video: false, imageLoader: imageLoader)
            case .video(_, let url):
                cell.set(imageUrl: url, video: true, imageLoader: imageLoader)
        }
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let inset = (collectionViewLayout as? UICollectionViewFlowLayout).map { layout in
            layout.sectionInset.left + layout.sectionInset.right + layout.minimumInteritemSpacing
        } ?? 0
        let width = (collectionView.bounds.width - inset) / 2
        return CGSize(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)

        guard let cell = collectionView.cellForItem(at: indexPath) as? MediaCell else { return }

        output.selectMedia(media, indexPath.item, cell.imageView.image)
        currentIndex = indexPath.item
    }

    // MARK: - Zoom Transition

    let zoomTransition: ZoomTransition? = nil
    let zoomTransitionInteractionController: UIViewControllerInteractiveTransitioning? = nil

    var currentIndex: Int = 0

    var zoomTransitionAnimatingView: UIView? {
        guard let cell = collectionView.cellForItem(at: IndexPath(item: currentIndex, section: 0)) as? MediaCell else { return nil }

        let frame = cell.imageView.convert(cell.imageView.bounds, to: nil)
        let imageView = UIImageView(image: cell.imageView.image)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.frame = frame
        imageView.backgroundColor = .clear
        return imageView
    }

    func zoomTransitionHideViews(hide: Bool) {
        guard let cell = collectionView.cellForItem(at: IndexPath(item: currentIndex, section: 0)) as? MediaCell else { return }

        cell.imageView.isHidden = hide
    }

    func zoomTransitionDestinationFrame(for view: UIView, frame: CGRect) -> CGRect {
        let attributes = collectionView.collectionViewLayout.layoutAttributesForItem(at: IndexPath(item: currentIndex, section: 0))
        let frame = collectionView.convert(attributes?.frame ?? .zero, to: nil)
        return frame
    }
}
