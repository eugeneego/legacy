//
// ImageCell
// Example-iOS
//
// Created by Eugene Egorov on 20 July 2018.
// Copyright (c) 2018 Eugene Egorov. All rights reserved.
//

import UIKit
import Legacy

class ImageCell: UICollectionViewCell {
    @IBOutlet private var imageView: NetworkImageView!

    func set(imageUrl: URL?, imageLoader: ImageLoader) {
        imageView.imageLoader = imageLoader
        imageView.imageUrl = imageUrl
    }
}
