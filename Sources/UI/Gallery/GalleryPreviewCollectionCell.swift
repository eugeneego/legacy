//
// GalleryPreviewCollectionCell
// Legacy
//
// Copyright (c) 2018 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import UIKit

open class GalleryPreviewCollectionCell: UICollectionViewCell {
    public static let id: Reusable<GalleryPreviewCollectionCell> = .fromClass()

    open let imageView: UIImageView = UIImageView()

    private var imageId: String?

    public override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    private func setup() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(imageView)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill

        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }

    open func set(image: UIImage?, loader: GalleryMedia.PreviewImageLoader?, setup: ((GalleryPreviewCollectionCell) -> Void)?) {
        setup?(self)

        let uuid = UUID().uuidString
        imageId = uuid

        if let image = image {
            imageView.image = image
        } else if let loader = loader {
            loader(imageView.bounds.size) { [weak self] result in
                guard let `self` = self, self.imageId == uuid else { return }

                self.imageView.image = result.value
            }
        } else {
            imageView.image = nil
        }
    }

    open override func prepareForReuse() {
        super.prepareForReuse()

        imageView.image = nil
        imageId = nil
    }
}
