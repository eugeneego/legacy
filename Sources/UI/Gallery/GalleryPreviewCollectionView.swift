//
// GalleryPreviewCollectionView
// Legacy
//
// Copyright (c) 2018 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import UIKit

open class GalleryPreviewCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    open let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()

    open var items: [GalleryMedia] = [] {
        didSet {
            reloadData()
        }
    }

    open private(set) var currentIndex: Int = -1
    open var selectAction: ((Int) -> Void)?
    open var cellSetup: ((GalleryPreviewCollectionCell) -> Void)?

    public init() {
        super.init(frame: .zero, collectionViewLayout: layout)

        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        collectionViewLayout = layout
        setup()
    }

    open func setup() {
        registerReusableCell(GalleryPreviewCollectionCell.id)

        allowsSelection = true
        allowsMultipleSelection = false

        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 48, height: 64)
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 4
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

        dataSource = self
        delegate = self
    }

    open func selectItem(at index: Int, animated: Bool) {
        currentIndex = index
        selectItem(at: IndexPath(item: index, section: 0), animated: animated, scrollPosition: .centeredHorizontally)
    }

    // MARK: - Collection View

    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = items[indexPath.item]
        let previewImage: UIImage?
        let previewLoader: GalleryMedia.PreviewImageLoader?
        switch item {
            case .image(let image):
                previewImage = image.previewImage
                previewLoader = image.previewImageLoader
            case .video(let video):
                previewImage = video.previewImage
                previewLoader = video.previewImageLoader
        }

        let cell = collectionView.dequeueReusableCell(GalleryPreviewCollectionCell.id, indexPath: indexPath)
        cell.set(image: previewImage, loader: previewLoader, setup: cellSetup)
        return cell
    }

    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectAction?(indexPath.item)
        currentIndex = indexPath.item
    }
}
