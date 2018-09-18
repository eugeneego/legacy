//
// GalleryPreviewCollectionCell
// Legacy
//
// Copyright (c) 2018 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import UIKit

open class GalleryPreviewCollectionCell: GalleryBasePreviewCollectionCell {
    public let imageView: UIImageView = UIImageView()
    public let videoView: UIView = UIView()
    public let videoIconView: UIImageView = UIImageView()

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

        contentView.addSubview(videoView)
        videoView.clipsToBounds = true
        videoView.layer.cornerRadius = 12
        videoView.backgroundColor = UIColor(white: 0, alpha: 0.4)

        videoView.addSubview(videoIconView)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        videoView.translatesAutoresizingMaskIntoConstraints = false
        videoIconView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            videoView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            videoView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            videoView.widthAnchor.constraint(equalToConstant: 24),
            videoView.heightAnchor.constraint(equalToConstant: 24),
            videoIconView.centerXAnchor.constraint(equalTo: videoView.centerXAnchor, constant: 1),
            videoIconView.centerYAnchor.constraint(equalTo: videoView.centerYAnchor),
            videoIconView.widthAnchor.constraint(equalToConstant: 12),
            videoIconView.heightAnchor.constraint(equalToConstant: 12),
        ])
    }

    override open func set(item: GalleryMedia, setup: ((GalleryBasePreviewCollectionCell) -> Void)?) {
        super.set(item: item, setup: setup)

        let image: UIImage?
        let loader: GalleryMedia.PreviewImageLoader?
        let isVideo: Bool
        switch item {
            case .image(let data):
                image = data.previewImage
                loader = data.previewImageLoader
                isVideo = false
            case .video(let data):
                image = data.previewImage
                loader = data.previewImageLoader
                isVideo = true
        }

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

        videoView.isHidden = !isVideo

        setup?(self)
    }

    open override func prepareForReuse() {
        super.prepareForReuse()

        imageView.image = nil
        imageId = nil
    }
}
