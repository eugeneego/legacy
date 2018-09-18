//
// MediaCell
// Example-iOS
//
// Created by Eugene Egorov on 20 July 2018.
// Copyright (c) 2018 Eugene Egorov. All rights reserved.
//

import UIKit
import Legacy

class MediaCell: UICollectionViewCell {
    static let id: Reusable<MediaCell> = .fromClass()

    let imageView: NetworkImageView = NetworkImageView()
    private let videoView: UIView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    private func setup() {
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        contentView.addSubview(imageView)

        videoView.layer.cornerRadius = 24
        videoView.clipsToBounds = true
        videoView.backgroundColor = UIColor(white: 0, alpha: 0.4)
        contentView.addSubview(videoView)

        let videoIconView = UIImageView()
        videoIconView.contentMode = .center
        videoIconView.image = UIImage(named: "icon-play")
        videoIconView.tintColor = .white
        videoView.addSubview(videoIconView)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        videoView.translatesAutoresizingMaskIntoConstraints = false
        videoIconView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            videoView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            videoView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            videoView.widthAnchor.constraint(equalToConstant: 48),
            videoView.heightAnchor.constraint(equalToConstant: 48),
            videoIconView.centerXAnchor.constraint(equalTo: videoView.centerXAnchor, constant: 3),
            videoIconView.centerYAnchor.constraint(equalTo: videoView.centerYAnchor),
        ])
    }

    func set(imageUrl: URL?, video: Bool, imageLoader: ImageLoader) {
        imageView.imageLoader = imageLoader
        imageView.imageUrl = imageUrl
        videoView.isHidden = !video
    }
}
